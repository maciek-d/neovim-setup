return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/playground",
        "nvim-treesitter/nvim-treesitter-context",
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = function()
        -- Install parsers synchronously (only applied to `ensure_installed`)
        require("nvim-treesitter.install").update({ with_sync = true })
    end,
    config = function()
        require 'nvim-treesitter.configs'.setup {
            -- A list of parser names, or "all"
            ensure_installed = { "vimdoc", "javascript", "typescript", "c", "lua", "rust", "php", "python" },
            auto_install = true,
            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            highlight = { enable = true, additional_vim_regex_highlighting = false },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@block.outer", -- Select around any block
                        ["if"] = "@block.inner", -- Select inside any block
                    },
                },
            },
        }
    end,
}
