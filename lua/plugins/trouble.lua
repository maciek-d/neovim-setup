return {
  "folke/trouble.nvim",
  config = function()
    require("trouble").setup {
      icons = {},
    }
    vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { silent = true, noremap = true })
  end,
}

