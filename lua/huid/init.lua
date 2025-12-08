local util = require("huid.util")
local fs = require("huid.fs")
local M = {}

---@enum Pickers
M.pickers = {
	snacks = 1,
	telescope = 2,
	fzf_lua = 3,
	mini_pick = 4,
}

-- TODO: implement more configuration options
---@class HuidDefaultConfig
local default_config = {
	---@type string
	-- The directory to find to place the tasks directory, found in the project root (required for SetupTaskDirectory)
	vcs_dirname = ".git",
	--[[
  TODO: add auto detection of picker
  HAS TO BE SET BY USER CURRENTLY!!
  --]]
	---@type Pickers
	picker = nil,
}

---@type HuidDefaultConfig
M.options = {}

---@param opts HuidDefaultConfig
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", default_config, opts or {})

	vim.api.nvim_create_user_command("SetupTaskDirectory", function()
		fs.setup_dir(M.options.vcs_dirname)
	end, {})

	-- Convert a TODO comment into a TASK(<HUID>) comment.
	vim.api.nvim_create_user_command("ConvertTodo", function()
		require("huid.navigation").convert()
	end, {})

	--[[ 
    Pick a task through a specified fuzzy picker or go to the default one if only one is present
    -- commented out because potentially unsafe
    vim.api.nvim_create_user_command("PickTasks", function()
      require("huid.navigation").list()
    end, {})
  --]]

	-- Make a new task
	vim.api.nvim_create_user_command("NewTask", function()
		vim.ui.input({ prompt = "Enter the Task Description, With the priority next to it" }, function(input)
			if not input then
				vim.notify("ERR: task input cancelled", vim.log.levels.ERROR)
				return
			end
			local huid = util.generate_huid()
			local pattern = "(.-)(%d+)$" -- non-greedy match until digits at end
			local description, priority_str = input:match(pattern)
			if not description or not priority_str then
				vim.notify("ERR: the request doesn't match the proper requested data.", vim.log.levels.ERROR)
				return
			end
			fs.make_new(description, tonumber(priority_str, 10), huid)
			local commentstring = vim.api.nvim_get_option_value("commentstring", {})
			if not commentstring then
				vim.notify("ERR: couldn't get commentstring", vim.log.levels.ERROR)
				return
			end
			vim.api.nvim_set_current_line(
				string.format(
					commentstring,
					"TASK(" .. huid .. "): " .. description
				)
			)
		end)
	end, {})
end

return M
