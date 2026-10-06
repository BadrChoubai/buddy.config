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

            -- Starts `make debug-stub` (add this target to your Makefile — see below)
            -- in a background job, then launches the DAP session a moment later
            -- so nvim-dap's GDB client is the one attaching, not your tmux one.
            local function start_qemu_and_debug()
                vim.fn.jobstart("make debug-stub", { cwd = vim.fn.getcwd() })
                vim.defer_fn(function()
                    dap.continue()
                end, 500)
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
            end

            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end,
    },
}
