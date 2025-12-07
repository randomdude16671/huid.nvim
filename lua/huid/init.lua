local util = require("huid.util")
local fs = require("huid.fs")
local M = {}

---@class HuidDefaultConfig
local default_config = {
	---@type boolean
	caching = true,
	---@type boolean
	auto_index = false,
	---@type boolean
	debug = false,
}

---@type HuidDefaultConfig
M.options = {}

---@param opts HuidDefaultConfig
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", default_config, opts or {})

	vim.api.nvim_create_user_command("ConvertTodoToTask", function()
		require("huid.navigation").convert()
	end, {})

	vim.api.nvim_create_user_command("NewTask", function()
		vim.ui.input({ prompt = "Enter the Task Description, With the priority next to it" }, function(input)
			local huid = util.generate_huid()
			local pattern = "(.-)(%d+)$" -- non-greedy match until digits at end
			local description, priority_str = input:match(pattern)
			if not description or not priority_str then
				vim.notify("ERR: the request doesn't match the proper requested data.", vim.log.levels.ERROR)
				return
			end
			fs.make_new(description, tonumber(priority_str, 10), huid)
		end)
	end, {})
end

return M
