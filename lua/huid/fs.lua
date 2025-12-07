local util = require("huid.util")

local uv = vim.uv

local M = {}

---@param msg string
---@param priority integer
---@param huid string
function M.make_new(msg, priority, huid)
	local tasks_dir = util.find_tasks_dir(uv.cwd())
	if tasks_dir == nil then
		vim.notify("ERR: tasks dir not found", vim.log.levels.ERROR)
		return
	end
	local huid_task_path = tasks_dir .. "/" .. huid
	uv.fs_mkdir(huid_task_path, tonumber("755", 8))

	local file = io.open(huid_task_path .. "/TASK.md", "w")
	if file == nil then
		print("Error opening file through io.open")
		return
	end
	local content = "# " .. msg .. "\n\n" .. "- STATUS: open\n" .. "- PRIORITY: " .. tostring(priority)
	file:write(content)
	file:close()
end

return M
