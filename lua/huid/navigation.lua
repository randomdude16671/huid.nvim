-- TOOD: add some UI options in this module.

local util = require("huid.util")
local fs = require("huid.fs")

local M = {}

function M.list()
	local existing = fs.list_existing()
	if existing ~= nil then
	-- TODO: implement list picking functionality
	else
		vim.notify("ERR: couldn't list existing", vim.log.levels.ERROR)
		return
	end
end

function M.convert()
	local line = vim.api.nvim_get_current_line()
	local pattern = "(.*)TODO:(.*)"
	if line:match(pattern) then
		vim.ui.input({ prompt = "Enter the priority" }, function(input)
			local huid = util.generate_huid() -- generate huid immediately to avoid race conditions and inconsistent shitze.
			local comment_string, msg = string.match(line, pattern)
			fs.make_new(msg, tonumber(input, 10), huid)
			vim.api.nvim_set_current_line(comment_string .. "TASK(" .. huid .. "):" .. msg)
		end)
	else
		vim.notify("ERR: current line doesn't match", vim.log.levels.ERROR)
		return
	end
end

return M
