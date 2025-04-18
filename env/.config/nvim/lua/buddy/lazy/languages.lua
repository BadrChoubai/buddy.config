return {
  "ray-x/go.nvim",
  config = function()
    require("go").setup()

    -- Run gofmt + goimports on save

    local format_sync_grp = vim.api.nvim_create_augroup("goimports", {})
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      callback = function()
       require('go.format').goimports()
      end,
      group = format_sync_grp,
    })
  end,
}

