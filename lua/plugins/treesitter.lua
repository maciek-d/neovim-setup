return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    dependencies = {
        "nvim-treesitter/nvim-treesitter-context",
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    config = function()
        require('treesitter-context').setup({
            enable = true,
            max_lines = 3,
            multiline_threshold = 3,
            trim_scope = 'outer',
            mode = 'cursor',
            separator = nil
        })

        vim.api.nvim_create_autocmd('FileType', {
            callback = function(ev)
                local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
                pcall(vim.treesitter.start)
                require('nvim-treesitter').install({ lang })
            end,
        })

        require('nvim-treesitter-textobjects').setup({
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    ["af"] = "@block.outer",
                    ["if"] = "@block.inner",
                },
            },
        })

        vim.filetype.add({
            extension = { jsonl = "json" }
        })
    end,
}
