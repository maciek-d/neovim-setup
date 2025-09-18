return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  version = false, -- Never set this value to "*"! Never!
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    -- add any opts here
    instructions_file = "avante.md",
    provider = "claude",
    providers = {
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-20250514",
      },
    },
    windows = {
      width = 70, -- percentage of the editor width
      sidebar_header = {
        align = "center",
        rounded = true,
      },
    },
  },
  config = function(_, opts)
    require("avante").setup(opts)

    -- helper: move a mapping if it exists (works for Lua callbacks or string rhs)
    local function move_map(mode, from, to)
      local m = vim.fn.maparg(from, mode, false, true)
      if not m or vim.tbl_isempty(m) then return end

      local rhs = m.callback or m.rhs
      if not rhs then return end

      local new_opts = {
        silent = m.silent == 1,
        expr = m.expr == 1,
        desc = m.desc,
      }
      -- NOTE: vim.keymap.set is noremap=true by default; if the original was recursive, preserve that
      if m.noremap == 0 then new_opts.remap = true end

      vim.keymap.set(mode, to, rhs, new_opts)
      vim.keymap.del(mode, from)
    end

    -- Only move the **Avante** leader-a maps you showed (leave lone `<leader>a` for Harpoon alone)
    local pairs_to_move = {
      { "n", "<leader>aB", "<leader>cB" },
      { "n", "<leader>ah", "<leader>ch" },
      { "n", "<leader>a?", "<leader>c?" },
      { "n", "<leader>aR", "<leader>cR" },
      { "n", "<leader>as", "<leader>cs" },
      { "n", "<leader>aC", "<leader>cC" },
      { "n", "<leader>ad", "<leader>cd" },
      { "n", "<leader>at", "<leader>ct" },
      { "n", "<leader>af", "<leader>cf" },
      { "n", "<leader>ar", "<leader>cr" },
      { "n", "<leader>aS", "<leader>cS" },
      { "v", "<leader>ae", "<leader>ce" },
      { "v", "<leader>an", "<leader>cn" },
      { "n", "<leader>an", "<leader>cn" },
      { "v", "<leader>az", "<leader>cz" },
      { "n", "<leader>az", "<leader>cz" },
      { "v", "<leader>aa", "<leader>ca" },
      { "n", "<leader>aa", "<leader>ca" },
    }

    for _, t in ipairs(pairs_to_move) do
      move_map(t[1], t[2], t[3])
    end
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    -- optional providers for pickers / inputs
    "echasnovski/mini.pick",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
    "ibhagwan/fzf-lua",
    "stevearc/dressing.nvim",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
    "zbirenbaum/copilot.lua",
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = { insert_mode = true },
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = { file_types = { "markdown", "Avante" } },
      ft = { "markdown", "Avante" },
    },
  },
}

