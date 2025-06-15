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
                -- diff
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

                -- git diff
                vim.keymap.set("n", "<leader>d", function()
                    local status_win = vim.api.nvim_get_current_win()
                    local status_buf = vim.api.nvim_win_get_buf(status_win)
                    local status_cur = vim.api.nvim_win_get_cursor(status_win)

                    local dd = vim.api.nvim_replace_termcodes("dd", true, false, true)
                    vim.api.nvim_feedkeys(dd, "m", false)

                    vim.schedule(function()
                        if vim.api.nvim_win_is_valid(status_win)
                            and vim.bo[status_buf].filetype == "fugitive" then
                            vim.api.nvim_win_close(status_win, true)
                        end

                        vim.api.nvim_create_autocmd("BufWinLeave", {
                            buffer = 0,
                            once = true,
                            callback = function()
                                -- defer opening the :Git window to avoid E1159
                                vim.defer_fn(function()
                                    vim.cmd("Git")
                                    vim.schedule(function()
                                        local win = vim.api.nvim_get_current_win()
                                        if vim.api.nvim_win_is_valid(win) then
                                            vim.api.nvim_win_set_cursor(win, status_cur)
                                        end
                                    end)
                                end, 30) -- small delay (30ms) to let window close finish
                            end,
                        })
                    end)
                end, { buffer = true, noremap = true, silent = true })
            end,
        })
    end,
}
