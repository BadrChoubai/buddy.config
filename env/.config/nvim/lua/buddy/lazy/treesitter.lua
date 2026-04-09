return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        commit = "4916d6592ede8c07973490d9322f187e07dfefac",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                -- A list of parser names, or "all"
                ensure_installed = {
                    "vimdoc", "javascript", "go", "lua", "jsdoc", "bash", "c_sharp",
                },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
                auto_install = true,

                indent = { enable = true },
            })

            local excluded = { html = true }

            vim.api.nvim_create_autocmd('FileType', {
                pattern = '*',
                callback = function(args)
                    local ft = vim.bo[args.buf].filetype
                    if excluded[ft] then
                        return
                    end

                    local max_filesize = 100 * 1024
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
                    if ok and stats and stats.size > max_filesize then
                        return
                    end

                    pcall(vim.treesitter.start)
                end,
            })

            vim.filetype.add({ extension = { templ = "templ" } })
        end
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require 'treesitter-context'.setup {
                enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
                multiwindow = false,      -- Enable multiwindow support.
                max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
                min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
                line_numbers = true,
                multiline_threshold = 20, -- Maximum number of lines to show for a single context
                trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
                mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
                -- Separator between context and content. Should be a single character string, like '-'.
                -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
                separator = nil,
                zindex = 20,     -- The Z-index of the context window
                on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
            }
        end
    }
}
