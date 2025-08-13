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


autocmd('FileType', {
  group = DefaultGroup,
  pattern = 'dbui',
  callback = function(args)
    vim.keymap.set('n', '<leader>r', function()

      -- Trigger DBUI "select line" (use remaps so DBUI handles it)
      local key = vim.api.nvim_replace_termcodes('<Plug>(DBUI_SelectLine)', true, false, true)
      if vim.fn.maparg('<Plug>(DBUI_SelectLine)', 'n') == '' then
        key = vim.api.nvim_replace_termcodes('<CR>', true, false, true)
      end
      vim.api.nvim_feedkeys(key, 'm', false)

      -- Find a populated SQL window and run :%DB there
      local function find_sql_win()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'sql' then
            local lines = vim.api.nvim_buf_get_lines(buf, 0, 20, false)
            for _, l in ipairs(lines) do
              if l:match('%S') then
                return win, buf
              end
            end
          end
        end
      end

      local deadline = vim.loop.hrtime() + 1e9 -- 1000ms
      local function tick()
        local win, buf = find_sql_win()
        if win and buf then
          vim.api.nvim_win_call(win, function()
            vim.cmd('%DB')
          end)
          return
        end
        if vim.loop.hrtime() < deadline then
          vim.defer_fn(tick, 40)
        end
      end

      -- start polling shortly after DBUI opens the buffer
      vim.defer_fn(tick, 80)
    end, { buffer = args.buf, silent = true, desc = 'DBUI: run query (keep buffers)' })
  end,
})

