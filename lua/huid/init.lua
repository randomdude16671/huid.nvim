local util = require("huid.util")
local fs = require("huid.fs")
local M = {}

---@class HuidDefaultConfig
local default_config = {
	-- TODO: implement configuration options
}

---@type HuidDefaultConfig
M.options = {}

---@param opts HuidDefaultConfig
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", default_config, opts or {})

	-- Convert a TODO comment into a TASK(<HUID>) comment.
	vim.api.nvim_create_user_command("ConvertTodo", function()
		require("huid.navigation").convert()
	end, {})

	--[[ 
    Pick a task through a specified fuzzy picker or go to the default one if only one is present
    TODO: (yes this isn't in production in my own configuration yet) implement fuzzy picker picking
  --]]
	vim.api.nvim_create_user_command("PickTasks", function()
		require("huid.navigation").list()
	end, {})

	--[[ 
    Make a new task
    TODO: auto comment ability
  --]]
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
			vim.api.nvim_set_current_line("TASK(" .. huid .. "): " .. description)
		end)
	end, {})
end

return M
