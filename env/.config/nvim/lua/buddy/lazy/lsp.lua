return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },


    config = function()
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities())

        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "gopls",
            },
            handlers = {
                function(server_name) -- default handler
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end
            }
        })
    end
}
