local util = require("huid.util")

local uv = vim.uv

local M = {}

---@param msg string
---@param priority integer
function M.make_new(msg, priority, huid)
	local tasks_dir = util.find_tasks_dir(uv.cwd())
	if tasks_dir == nil then
		vim.notify("ERR: tasks dir not found", vim.log.levels.ERROR)
		return
	end
	local huid_task_path = tasks_dir .. "/" .. huid
	uv.fs_mkdir(huid_task_path, tonumber("755", 8))
	uv.fs_open(huid_task_path .. "/TASK.md", "w", tonumber("666", 8), function(err, fd)
		if err then
			print("Error opening file: ", err)
			return
		end

		local content = "# " .. msg .. "\n\n" .. "- STATUS: open\n-PRIORITY: " .. priority .. "\n"
		uv.fs_write(fd, content, -1)
		uv.fs_close(fd)
	end)
end

return M
