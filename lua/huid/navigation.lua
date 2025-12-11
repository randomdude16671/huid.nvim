local util = require("huid.util")
local fs = require("huid.fs")
local integrations = require("huid").integrations

local M = {}

function M.list()
	local existing = fs.list_existing()
	if existing ~= nil then
		if #existing == 0 then
			vim.notify("No tasks to list", vim.log.levels.ERROR)
			return
		end
		local entries = {}
		for _, task in ipairs(existing) do
			if
				integrations.snacks
				and not integrations.mini_pick
				and not integrations.fzf_lua
				and not integrations.telescope
			then
				table.insert(entries, {
					text = task.desc,
					file = task.file_path,
					dir = false,
				})
				require("snacks").picker({
					title = "huid.nvim",
					items = entries,
				})
			elseif integrations.fzf_lua then
				table.insert(entries, task.file_path)
				require("fzf-lua").fzf_exec(entries, { prompt = "huid.nvim" })
			elseif integrations.telescope then
				local pickers = require("telescope.pickers")
				local finders = require("telescope.finders")
				local conf = require("telescope.config").values

				local function huid_picker()
					table.insert(entries, {
						text = task.desc,
						file = task.file_path,
						dir = false,
					})

					pickers
						.new({}, {
							prompt_title = "huid.nvim",

							finder = finders.new_table({
								results = entries,
								entry_maker = function(entry)
									return {
										value = entry,
										display = entry.text,
										ordinal = entry.text,
										path = entry.file,
									}
								end,
							}),

							sorter = conf.generic_sorter({}),
						})
						:find()
				end
				huid_picker()
			elseif integrations.mini_pick then
				local MiniPick = require("mini.pick")
				table.insert(entries, task.file_path)
				MiniPick.start({ source = { items = entries } })
			else
				vim.notify("No picker!", vim.log.levels.ERROR)
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
