return {
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set("n", "<leader>gk", vim.cmd.Git)
        local autocmd = vim.api.nvim_create_autocmd
        local group = vim.api.nvim_create_augroup("ThePrimeagen_Fugitive", {})

        autocmd("BufWinEnter", {
            group = group,
            pattern = "*",
            callback = function()
                if vim.bo.ft ~= "fugitive" then return end
                local bufnr = vim.api.nvim_get_current_buf()
                local opts = { buffer = bufnr, remap = false }

                vim.keymap.set("n", "<leader>gi", function()
                    vim.cmd("Git add .")
                end, { noremap = true, silent = true })

                vim.keymap.set("n", "<leader>gu", function()
                    vim.cmd("silent !git reset")
                    vim.cmd("redraw!")
                end, { noremap = true, silent = true })

                vim.keymap.set("n", "<leader>p", function() vim.cmd.Git("push") end, opts)
                -- rebase always
                vim.keymap.set("n", "<leader>P", function() vim.cmd.Git({ "pull", "--rebase" }) end, opts)
                -- NOTE: It allows me to easily set the branch i am pushing and any tracking
                -- needed if i did not set the branch up correctly
                vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts)
            end,
        })
    end,
}
