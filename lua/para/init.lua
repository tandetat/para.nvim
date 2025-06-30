vim.loader.enable()
local M = {}
--------------------------------------------------------------------------------

---@param userConfig? Para.config
M.setup = function(userConfig)
	require("para.config").setup(userConfig)
	local notes = require("para.notes")

	vim.api.nvim_create_user_command("ParaNewProject", function() notes.new_note("projects") end, {})

	vim.api.nvim_create_user_command("ParaNewArea", function() notes.new_note("areas") end, {})

	vim.api.nvim_create_user_command(
		"ParaNewResource",
		function() notes.new_note("resources") end,
		{}
	)
end

--------------------------------------------------------------------------------
return M
