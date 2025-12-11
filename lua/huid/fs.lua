local util = require("huid.util")

local uv = vim.uv

local M = {}

---@param vcs_dirname string
---@param start string?
function M.setup_dir(vcs_dirname, start)
	start = start or uv.cwd()
	local vcs_dir_abs = util.find_dir(vcs_dirname, start)
	if vcs_dir_abs ~= nil then
		local parent = vcs_dir_abs:match("(.*/)")
		if not parent then
			vim.notify("ERR: couldn't extract parent directory from VCS path", vim.log.levels.ERROR)
			return
		end

		if not util.is_dir(parent) then
			vim.notify("Failed to find parent of the VCS directory", vim.log.levels.ERROR)
			return
		end

		uv.fs_mkdir(parent .. "/tasks", tonumber("755", 8))
	else
		vim.notify("ERR: failed to get version control directory (" .. vcs_dirname .. ")", vim.log.levels.ERROR)
		return
	end
end

---@return table|nil
function M.list_existing()
	local tasks_dir = util.find_tasks_dir(uv.cwd())
	if tasks_dir == nil then
		vim.notify("ERR: couldn't find tasks directory", vim.log.levels.ERROR)
		return
	end

	---@type string[]
	local tasks = {}
	for name, _ in vim.fs.dir(tasks_dir) do
		local task_file = tasks_dir .. "/" .. name .. "/TASK.md"
		local file = io.open(task_file, "r")
		if file ~= nil then
			local task = file:read("*l")
			if task then
				table.insert(tasks, { desc = tostring(task):sub(3), file_path = task_file }) -- :sub(3) to skip first 2 characters.
			else
				vim.notify("ERR: couldn't read content from file: " .. task_file, vim.log.levels.ERROR)
				file:close()
				return
			end
			file:close()
		else
			vim.notify("ERR: couldn't read file: " .. task_file, vim.log.levels.ERROR)
			return
		end
	end

	return tasks
end

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
