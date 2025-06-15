return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "ts_ls",
                    "pyright",
                    "bashls",
                    "yamlls",
                },
            })
        end,
    },
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v3.x",
        dependencies = {
            "neovim/nvim-lspconfig",
            "williamboman/mason-lspconfig.nvim",
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "L3MON4D3/LuaSnip" },
        },
        config = function()
            local lsp_zero = require("lsp-zero")

            local cmp = require("cmp")

            -- extend lsp-zero with default cmp capabilities
            require("lsp-zero").extend_cmp()

            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                }),
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                },
            })


            lsp_zero.on_attach(function(_, bufnr)
                local opts = { buffer = bufnr, remap = false }

                local telescope = require("telescope.builtin")

                vim.keymap.set('n', 'gd', function()
                    local util = vim.lsp.util
                    local client = vim.lsp.get_clients({ bufnr = 0 })[1]
                    if not client then return end

                    local enc = client.offset_encoding or 'utf-16'
                    local params = util.make_position_params(0, enc)

                    vim.lsp.buf_request(0, 'textDocument/definition', params, function(_, result)
                        if not result or vim.tbl_isempty(result) then return end

                        if #result == 1 then
                            vim.lsp.buf.definition()
                        else
                            telescope.lsp_definitions({
                                jump_type     = 'never',
                                initial_mode  = 'normal',
                                prompt_title  = '',
                                prompt_prefix = 'Select Definition:>',
                                layout_config = {
                                    prompt_position = 'top',
                                },
                            })
                        end
                    end)
                end, { noremap = true, silent = true, buffer = bufnr })

                vim.keymap.set('n', '<leader>vrr', function()
                    local util = vim.lsp.util
                    local client = vim.lsp.get_clients({ bufnr = 0 })[1]
                    if not client then return end

                    local enc = client.offset_encoding or 'utf-16'
                    local params = util.make_position_params(0, enc)
                    params.context = { includeDeclaration = true }

                    vim.lsp.buf_request(0, 'textDocument/references', params, function(_, result)
                        if not result or vim.tbl_isempty(result) then return end

                        if #result == 1 then
                            vim.lsp.util.jump_to_location(result[1], enc)
                        else
                            telescope.lsp_references({
                                jump_type     = 'never',
                                initial_mode  = 'normal',
                                prompt_title  = '',
                              prompt_prefix = 'Select Reference:>',
                                layout_config = {
                                    prompt_position = 'top',
                                },
                            })
                        end
                    end)
                end, { noremap = true, silent = true, buffer = bufnr })

                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
                vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
                vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
                vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
                vim.keymap.set("n", "<leader>vc", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
                vim.keymap.set("i", "<C-g>", vim.lsp.buf.signature_help, opts)

                vim.keymap.set("n", "<leader>K", function()
                    local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
                    if diagnostics[1] then
                        vim.fn.setreg("+", diagnostics[1].message)
                        print("Error copied: " .. diagnostics[1].message)
                    else
                        print("No error message on this line.")
                    end
                end, { noremap = true, silent = true, buffer = bufnr })
            end)

            local cmp_lsp = require("cmp_nvim_lsp")
            lsp_zero.setup({
                capabilities = cmp_lsp.default_capabilities(),
            })

            vim.diagnostic.config({ virtual_text = true })

            -- diagnostic signs
            local signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end
        end,
    },
}
