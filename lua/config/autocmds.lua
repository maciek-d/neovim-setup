local augroup = vim.api.nvim_create_augroup
local DefaultGroup = augroup('Default', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

-- Reload module without restarting neovim :lua R("module_name")
function R(name)
    require("plenary.reload").reload_module(name)
end

-- highlight text after copying
autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

-- trim white spaces after save
autocmd({"BufWritePre"}, {
    group = DefaultGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- mt will change the directory in netrw
autocmd("FileType", {
    group = DefaultGroup,
    pattern = "netrw",
    callback = function()
        vim.keymap.set("n", "<leader>m", function()
            vim.cmd("cd %:p:h")
        end, { buffer = true, silent = true })
    end
})

-- display relative numbers in netrw
autocmd('FileType', {
    group = DefaultGroup,
    pattern = 'netrw',
    callback = function()
        vim.defer_fn(function()
            vim.opt_local.number = true
            vim.opt_local.relativenumber = true
        end, 30)
    end,
})

