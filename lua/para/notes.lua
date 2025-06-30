local M = {}

local utils = require("para.utils")
local config = require("para.config").config

local function float_select(choices, on_select)
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.3)
	local height = math.min(#choices, math.floor(vim.o.lines * 0.3))
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	})

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, choices)
	vim.opt_local.modifiable = true
	vim.opt_local.buflisted = true
	vim.opt_local.bufhidden = "wipe"
	vim.opt_local.buftype = "nofile"
	vim.opt_local.swapfile = false

	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<CR>",
		string.format(
			[[
    :lua require("para.notes")._on_select(%d)
  ]],
			buf
		),
		{ noremap = true, silent = true }
	)

	-- allow quitting with q or Esc
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":bd!<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":bd!<CR>", { noremap = true, silent = true })

	vim.api.nvim_win_set_cursor(0, { 1, 0 })

	-- store callback internally (by buffer)
	M._callbacks = M._callbacks or {}
	M._callbacks[buf] = on_select
end

function M._on_select(bufnr)
	local cursor = vim.api.nvim_win_get_cursor(0)
	local line = cursor[1]
	local lines = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)
	local choice = lines[1]
	local cb = M._callbacks and M._callbacks[bufnr]
	if cb then
		local wins = vim.fn.win_findbuf(bufnr)
		for _, w in ipairs(wins) do
			vim.api.nvim_win_close(w, true)
		end
		-- call the callback with the selected folder
		cb(choice)
		M._callbacks[bufnr] = nil
	end
end

function M.new_note(category)
	-- category expects lowercase: "projects", "areas", or "resources"
	if not config.vault_dir or config.vault_dir == "" then
		utils.notify("vault_dir not set, run setup()", "error")
		return
	end

	local cat = category:lower()
	local base = config.vault_dir .. "/" .. cat

	-- gather subfolders (case insensitive)
	local subs = {}
	for _, path in ipairs(vim.fn.globpath(base, "*", false, true)) do
		if vim.fn.isdirectory(path) == 1 then table.insert(subs, vim.fn.fnamemodify(path, ":t")) end
	end

	if #subs == 0 then
		utils.notify("No subfolders in " .. base, "warn")
		return
	end

	float_select(subs, function(sub)
		vim.ui.input({ prompt = "Note title: " }, function(input)
			if not input or input == "" then
				utils.notify("Note creation canceled", "info")
				return
			end
			local fname = input:gsub("%s+", "-"):lower() .. ".md"
			local dest = string.format("%s/%s/%s", config.vault_dir, cat, sub)
			vim.fn.mkdir(dest, "p")
			local file = dest .. "/" .. fname
			vim.cmd("edit " .. vim.fn.fnameescape(file))
			vim.cmd("startinsert")
		end)
	end)
end

return M
