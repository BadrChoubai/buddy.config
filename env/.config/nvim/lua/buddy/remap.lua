vim.g.mapleader = " "
-- vim.keymap.set(mode, mapping, command)
-- disable macro recordings
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "q", "<nop>")
-- open explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
-- format
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
-- move highlighted lines up or down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- in insert mode CTRL+c == esc
vim.keymap.set("i", "<C-c>", "<Esc>")
-- Make file executable
vim.keymap.set("n", "<leader>x", function()
    if vim.bo.filetype == "sh" then
        vim.cmd("!chmod +x %")
    else
        print("not an executable file")
    end
end)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- Explorer in vertical split (right)
vim.keymap.set("n", "<leader>|", "<cmd>vsplit | Ex<CR>", { silent = true })
-- Explorer in horizontal split (bottom)
vim.keymap.set("n", "<leader>%", "<cmd>split | Ex<CR>", { silent = true })
vim.keymap.set('n', '<A-h>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<A-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<A-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<A-l>', '<C-w>l', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fb",
  "<cmd>Telescope buffers ignore_current_buffer=true sort_mru=true<CR>",
  { noremap = true, silent = true, desc = "Buffers" }
)

-- Diagnostics (LSP errors/warnings)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { noremap = true, silent = true, desc = "Show error" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { noremap = true, silent = true, desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { noremap = true, silent = true, desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { noremap = true, silent = true, desc = "Diagnostics to loclist" })
