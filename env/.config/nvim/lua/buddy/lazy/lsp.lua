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
    -- Formatting (IDE-style: format on save)
    ------------------------------------------------------------------
    require("conform").setup({
      format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        go = { "gofmt", "goimports" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
      },
    })

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

    require("mason-lspconfig").setup({
      ensure_installed = {
        "gopls",
        "ts_ls",
        "emmet_ls",
        "cssls",
        "html"
      },

      handlers = {
        -- Default handler
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
          })
        end,

        ------------------------------------------------------------------
        -- Go
        ------------------------------------------------------------------
        ["gopls"] = function()
          require("lspconfig").gopls.setup({
            capabilities = capabilities,
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
        end,

        ------------------------------------------------------------------
        -- JavaScript / TypeScript
        ------------------------------------------------------------------
        ["tsserver"] = function()
          require("lspconfig").tsserver.setup({
            capabilities = capabilities,
            settings = {
              completions = {
                completeFunctionCalls = true,
              },
            },
          })
        end,
        ["html"] = function()
          require("lspconfig").html.setup({
            capabilities = capabilities,
            settings = {
              html = {
                format = { wrapLineLength = 120 },
                hover = { documentation = true, references = true },
              },
            },
          })
        end,
        ["cssls"] = function()
          require("lspconfig").cssls.setup({
            capabilities = capabilities,
            settings = {
              css = { validate = true },
              scss = { validate = true },
              less = { validate = true },
            },
          })
        end,
        ["emmet_ls"] = function()
          require("lspconfig").emmet_ls.setup({
            capabilities = capabilities,
            filetypes = { "html", "css", "scss", "javascriptreact", "typescriptreact" },
          })
        end,
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

