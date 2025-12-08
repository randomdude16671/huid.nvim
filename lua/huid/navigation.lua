local util = require("huid.util")
local fs = require("huid.fs")

local M = {}

function M.list()
	local existing = fs.list_existing()
	if existing ~= nil then
		if #existing == 0 then
			vim.notify("No tasks to list", vim.log.levels.ERROR)
			return
		end
		for _, task in ipairs(existing) do
			if require("huid").options.picker == require("huid").pickers.snacks then
				local entries = {}
				table.insert(entries, {
					text = task.desc,
					file = task.file_path,
					dir = false,
				})
				require("snacks").picker({
					title = "huid.nvim",
					items = entries,
				})
			else
				vim.notify("ERR: not implemented for other pickers!", vim.log.levels.ERROR)
				return
			end
		end
	else
		vim.notify("ERR: couldn't list existing", vim.log.levels.ERROR)
	end
end

function M.convert()
	local line = vim.api.nvim_get_current_line()
	local pattern = "(.*)TODO:(.*)"
	if line:match(pattern) then
		vim.ui.input({ prompt = "Enter the priority" }, function(input)
			if not input then
				vim.notify("ERR: priority input cancelled", vim.log.levels.ERROR)
				return
			end
			local huid = util.generate_huid() -- generate huid immediately to avoid race conditions and inconsistent shitze.
			local comment_string, msg = string.match(line, pattern)
			if not comment_string or not msg then
				vim.notify("ERR: couldn't parse TODO comment", vim.log.levels.ERROR)
				return
			end
			fs.make_new(msg, tonumber(input, 10), huid)
			vim.api.nvim_set_current_line(comment_string .. "TASK(" .. huid .. "):" .. msg)
		end)
	else
		vim.notify("ERR: current line doesn't match", vim.log.levels.ERROR)
		return
	end
end

return M
