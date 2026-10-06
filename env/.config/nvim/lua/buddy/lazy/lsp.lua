return {
    "neovim/nvim-lspconfig",
    dependencies = {
        -- LSP + installer
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",

        -- Completion
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",

        -- Formatting + UI
        "stevearc/conform.nvim",
        "j-hui/fidget.nvim",
    },

    config = function()
        ------------------------------------------------------------------
        -- LSP capabilities (nvim-cmp aware)
        ------------------------------------------------------------------
        local capabilities = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            require("cmp_nvim_lsp").default_capabilities()
        )

        ------------------------------------------------------------------
        -- Diagnostics UI
        ------------------------------------------------------------------
        vim.diagnostic.config({
            float = {
                focusable = false,
                border = "rounded",
                source = "always",
            },
        })

        ------------------------------------------------------------------
        -- Mason
        ------------------------------------------------------------------
        require("mason").setup()
        require("fidget").setup({})

        ------------------------------------------------------------------
        -- Server configs (vim.lsp.config, merged on top of nvim-lspconfig)
        ------------------------------------------------------------------
        -- Default for every server
        vim.lsp.config("*", {
            capabilities = capabilities,
        })

        -- Go
        vim.lsp.config("gopls", {
            settings = {
                gopls = {
                    gofumpt = true,
                    analyses = {
                        unusedparams = true,
                        nilness = true,
                    },
                    staticcheck = true,
                },
            },
        })

        -- HTML / CSS
        vim.lsp.config("html", {
            settings = {
                html = {
                    format = { wrapLineLength = 120 },
                    hover = { documentation = true, references = true },
                },
            },
        })
        vim.lsp.config("cssls", {
            settings = {
                css = { validate = true },
                scss = { validate = true },
                less = { validate = true },
            },
        })
        vim.lsp.config("emmet_ls", {
            filetypes = { "html", "css", "scss", "javascriptreact", "typescriptreact" },
        })

        -- Assembly
        vim.lsp.config("asm_lsp", {
            filetypes = { "asm" },
        })

        -- Installs servers and calls vim.lsp.enable() on them (automatic_enable)
        require("mason-lspconfig").setup({
            ensure_installed = {
                "gopls",
                "ts_ls",
                "emmet_ls",
                "cssls",
                "html",
                "asm_lsp"
            },
        })

        ------------------------------------------------------------------
        -- nvim-cmp
        ------------------------------------------------------------------
        local cmp = require("cmp")
        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },

            mapping = cmp.mapping.preset.insert({
                ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),

            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "path" },
            }, {
                { name = "buffer" },
            }),
        })
    end,
}
