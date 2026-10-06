return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "leoluz/nvim-dap-go",
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
        },

        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            ------------------------------------------------------------------
            -- BASIC UI
            ------------------------------------------------------------------
            dapui.setup()

            ------------------------------------------------------------------
            -- GO DEBUGGER
            ------------------------------------------------------------------
            require("dap-go").setup({
                dap_configurations = {
                    {
                        type = "go",
                        name = "Debug file",
                        request = "launch",
                        program = "${fileDirname}",
                    },
                },
            })

            ------------------------------------------------------------------
            -- ARM ASSEMBLY DEBUGGER (GDB via QEMU's gdbstub, cpptools adapter)
            ------------------------------------------------------------------
            -- Matches your Makefile's `debug` target: `qemu-arm -g 1234 ./rover`
            -- opens a GDB stub on :1234; we point cpptools' bundled GDB client
            -- at it instead of spawning your tmux `debug` session.
            --
            -- ONE-TIME SETUP: run :MasonInstall cpptools
            -- (installs OpenDebugAD7, the DAP<->GDB/MI bridge VS Code's C/C++
            -- extension also uses; it's more reliably tested against remote
            -- gdbservers/qemu stubs than GDB's own --interpreter=dap mode.)
            local cpptools_path = vim.fn.stdpath("data") ..
                "/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7"

            dap.adapters.cppdbg = {
                id = "cppdbg",
                type = "executable",
                command = cpptools_path,
            }

            dap.configurations.asm = {
                {
                    name = "Attach to QEMU gdbstub (:1234)",
                    type = "cppdbg",
                    request = "launch",                   -- "launch" here just means "start a GDB session"; MIMode+miDebuggerServerAddress make it attach remotely instead of running locally
                    MIMode = "gdb",
                    miDebuggerPath = "arm-linux-gnu-gdb", -- matches your Makefile's $(GDB)
                    miDebuggerServerAddress = "localhost:1234",
                    program = function()
                        -- Prompts each session so it works across different
                        -- assignments/Makefiles without hardcoding a binary name.
                        -- Defaults to the current directory's name, matching
                        -- your Makefile's $(TARGET) = rover convention.
                        local guess = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
                        return vim.fn.input("Path to ELF binary: ", vim.fn.getcwd() .. "/" .. guess, "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopAtEntry = true,
                    setupCommands = {
                        { text = "-enable-pretty-printing", ignoreFailures = true },
                    },
                },
            }

            -- Starts `make debug-stub` in a background job, waits for the
            -- gdbstub to accept connections on :1234, then launches the DAP
            -- session so nvim-dap's GDB client is the one attaching.
            -- The Makefile needs a target that runs QEMU without a client, e.g.:
            --   debug-stub: $(TARGET)
            --   	qemu-arm -g 1234 ./$(TARGET)
            local qemu_job = nil

            local function stop_qemu()
                if qemu_job then
                    vim.fn.jobstop(qemu_job)
                    qemu_job = nil
                end
            end

            -- qemu-user's gdbstub accepts exactly one connection, so a test
            -- connect would use it up; look for a LISTEN socket instead
            -- (port 1234 = 04D2, state 0A = LISTEN).
            local function stub_listening()
                for _, path in ipairs({ "/proc/net/tcp", "/proc/net/tcp6" }) do
                    local f = io.open(path, "r")
                    if f then
                        local data = f:read("*a")
                        f:close()
                        if data:find(":04D2 [%x:]+ 0A ") then
                            return true
                        end
                    end
                end
                return false
            end

            local function wait_for_stub(attempts, on_ready)
                if stub_listening() then
                    on_ready()
                elseif attempts > 1 and qemu_job then
                    vim.defer_fn(function() wait_for_stub(attempts - 1, on_ready) end, 100)
                else
                    stop_qemu()
                    vim.notify("QEMU gdbstub not listening on :1234", vim.log.levels.ERROR)
                end
            end

            local function start_qemu_and_debug()
                stop_qemu()
                qemu_job = vim.fn.jobstart("make debug-stub", {
                    cwd = vim.fn.getcwd(),
                    on_exit = function() qemu_job = nil end,
                })
                if qemu_job <= 0 then
                    qemu_job = nil
                    vim.notify("Failed to run `make debug-stub`", vim.log.levels.ERROR)
                    return
                end
                -- Retry for up to ~5s (100ms apart)
                wait_for_stub(50, dap.continue)
            end

            vim.keymap.set("n", "<leader>da", start_qemu_and_debug, { desc = "Start QEMU stub + attach debugger" })

            ------------------------------------------------------------------
            -- BASIC KEYMAPS
            ------------------------------------------------------------------

            -- Breakpoint
            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
            vim.keymap.set("n", "<leader>dt", function()
                dap.terminate()
                dapui.close()
                stop_qemu()
            end)

            -- Start / Continue
            vim.keymap.set("n", "<F5>", dap.continue)

            -- Step controls
            vim.keymap.set("n", "<F10>", dap.step_over)
            vim.keymap.set("n", "<F11>", dap.step_into)
            vim.keymap.set("n", "<F12>", dap.step_out)

            -- UI toggle
            vim.keymap.set("n", "<leader>du", dapui.toggle)

            ------------------------------------------------------------------
            -- AUTO OPEN / CLOSE UI
            ------------------------------------------------------------------
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end

            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
                stop_qemu()
            end

            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
                stop_qemu()
            end
        end,
    },
}
