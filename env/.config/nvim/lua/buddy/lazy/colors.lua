function ColorMyPencils(color)
	color = color or "default"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end


return {
    {
        "loctvl842/monokai-pro.nvim",
        lazy = false,
        opts = {},
        config = function()
            require("monokai-pro")
            ColorMyPencils()
        end
    },
}
