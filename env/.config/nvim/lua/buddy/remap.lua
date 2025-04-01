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

-- Split vertically
vim.keymap.set("n", "<leader>%", "<CMD>split<CR>")
-- Split horizontally
vim.keymap.set("n", "<leader>|", "<CMD>vsplit<CR>")

vim.keymap.set('n', '<A-h>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<A-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<A-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<A-l>', '<C-w>l', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)
