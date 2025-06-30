local M = {}

local notify = require("para.utils").notify
--------------------------------------------------------------------------------

---@class Para.config
local defaultConfig = {
	vault_dir = nil,
}

M.config = defaultConfig

local function dir_exists(parent, target)
	local dirs = vim.fn.globpath(parent, "*", false, true)
	for _, path in ipairs(dirs) do
		if vim.fn.isdirectory(path) == 1 then
			local name = vim.fn.fnamemodify(path, ":t")
			if name:lower() == target:lower() then return true end
		end
	end
	return false
end
--------------------------------------------------------------------------------

---@param userConfig? Para.config
M.setup = function(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})

	if type(M.config.vault_dir) ~= "string" or M.config.vault_dir == "" then
		notify(
			"[para.nvim] setup failed: you must provide vault_dir, e.g.\n"
				.. "require('para').setup{ vault_dir = '/path/to/your/vault' }",
			"error"
		)
		return
	end
	-- normalize path
	M.config.vault_dir = vim.fn.expand(M.config.vault_dir)

	-- ensure PARA folders exist
	for _, cat in ipairs { "projects", "areas", "resources" } do
		if not dir_exists(M.config.vault_dir, cat) then
			local new_dir = M.config.vault_dir .. "/" .. cat
			vim.fn.mkdir(new_dir, "p")
			notify("[para.nvim] Created: " .. new_dir)
		end
	end
end

--------------------------------------------------------------------------------
return M
