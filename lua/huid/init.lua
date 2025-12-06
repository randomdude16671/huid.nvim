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
		require("huid.converter").convert(M.options.debug)
	end, {})
	vim.api.nvim_create_user_command("NewTask", function()
		vim.ui.input({ prompt = "Enter the Task Description, With the priority next to it" }, function(input)
			local huid = util.generate_huid()
			local pattern = "\\v(.{-})(d+)" -- here: .{-} == non greedy match for all charcters until first digit
			local captures = vim.fn.matchlist(input, pattern)
			if captures[1] == "" or nil then
				vim.notify("ERR: the request doesn't match the proper requested data.", vim.log.levels.ERROR)
				return
			end
			fs.make_new(captures[2], captures[3], huid)
		end)
	end, {})
end

return M
