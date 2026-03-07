require("buddy.remap")
require("buddy.settings")
require("buddy.lazy_init")

local augroup = vim.api.nvim_create_augroup
local BuddyGroup = augroup('Buddy', {})

local autocmd = vim.api.nvim_create_autocmd

autocmd("VimEnter", {
  group = BuddyGroup,
  callback = function()
    vim.cmd.colorscheme("monokai-pro")
  end,
})

autocmd('LspAttach', {
    group = BuddyGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

autocmd('FileType', {
    group = BuddyGroup,
    pattern = "markdown",
    callback = function()
        -- Writing mode overrides
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.breakindent = true

        vim.opt_local.spell = true
        vim.opt_local.spelllang = { "en_us" }

        vim.opt_local.textwidth = 80
        vim.opt_local.formatoptions:append("t")

        -- Remove code UI noise
        vim.opt_local.colorcolumn = ""
        vim.opt_local.signcolumn = "no"

        -- Optional: friendlier line numbers for writing
        vim.opt_local.relativenumber = false
        vim.opt_local.number = true

        vim.opt_local.cursorline = true
        vim.opt_local.list = false
        vim.opt_local.showmode = false
  end,
})
