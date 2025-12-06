local util = require("huid.util")
local fs = require("huid.fs")

local M = {}

---@param debug boolean
---@return nil
---@diagnostic disable-next-line
function M.convert(debug)
	local cur_line = vim.api.nvim_get_current_line()
	local pattern = "\\v(.+)\\sTODO:(.+)"
	if util.matches(cur_line, pattern) then
		local captures = vim.fn.matchlist(cur_line, pattern)
		local huid = util.generate_huid()
		local converted = captures[2] .. " TASK(" .. huid .. "): " .. captures[3]
		util.debug("HUID debug: current line matches", debug)

		vim.ui.input({ prompt = "Enter the priority" }, function(input)
			fs.make_new(captures[3], tonumber(input), huid)
		end)

		local buf = vim.api.nvim_get_current_buf()
		local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- row is 1-based
		vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { converted })
	else
		util.debug("HUID debug: current line doesn't match, proceeding to error", debug)
		vim.notify("ERR: current line is not a valid TODO comment.")
		return
	end
end

return M
