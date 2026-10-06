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
