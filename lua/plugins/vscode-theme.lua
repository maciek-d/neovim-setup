return {
  {
    "Mofiqul/vscode.nvim",  -- Add the VSCode theme plugin
    priority = 1000,
    config = function()
      -- For dark theme (Neovim's default)
      vim.o.background = 'dark'
      -- For light theme, uncomment the following line:
      -- vim.o.background = 'light'

      local c = require('vscode.colors').get_colors()
      require('vscode').setup({
          transparent = true,          -- Enable transparent background
          italic_comments = true,      -- Enable italic comments
          disable_nvimtree_bg = true,  -- Disable nvim-tree background color
          color_overrides = {
              vscLineNumber = '#FFFFFF',  -- Override line number color
          },
          group_overrides = {
              Cursor = { fg=c.vscDarkBlue, bg=c.vscLightGreen, bold=true },
          },
      })

      -- Load the theme
      require('vscode').load()
    end
  }
}

