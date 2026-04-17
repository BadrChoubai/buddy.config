return {
    "stevearc/conform.nvim",
    config = function()
        require("conform").setup({
            format_on_save = function(bufnr)
                local ft = vim.bo[bufnr].filetype

                -- Disable autoformat for markdown
                if ft == "markdown" then
                    return
                end

                return {
                    timeout_ms = 1000,
                    lsp_fallback = true,
                }
            end,

            formatters_by_ft = {
                go = { "goimports" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                html = { "prettier" },
            },
        })

        vim.keymap.set("n", "<leader>f", function()
            require("conform").format()
        end)
    end,
}
