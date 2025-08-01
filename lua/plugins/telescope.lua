return {
"nvim-telescope/telescope.nvim",
dependencies = { "nvim-lua/plenary.nvim" },
config = function()
    local builtin = require("telescope.builtin")
    local actions = require("telescope.actions")

    require("telescope").setup({
        defaults = {
            layout_strategy = "horizontal",
            layout_config   = {
                width           = 0.95,
                height          = 0.85,
                preview_width   = 0.6,
                prompt_position = "bottom", -- prompt sits at the bottom
            },
            path_display    = { "truncate" }, -- tail-truncate long paths
            winblend        = 5,
            mappings        = {
                -- no <Esc> override → it just drops to Normal mode
                n = { ["q"] = actions.close }, -- 'q' still closes in Normal mode
            },
        },
    })

    -- your key-bindings
    vim.keymap.set("n", "<leader>lf", builtin.find_files, {})
    vim.keymap.set("n", "<C-g>", builtin.git_files, {})
    vim.keymap.set("n", "<leader>ld", function()
        local input = vim.fn.input("Grep > ")
        if not input or input == "" then return end
        require("telescope.builtin").grep_string({ search = input })
    end)
    vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
end,
}
