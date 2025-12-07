-- TODO: error check uv.fs_mkdir calls in this file
local util = require("huid.util")

local uv = vim.uv

local M = {}

-- TODO: make this function not depend on Git
function M.setup_dir()
	local _git_dir = util.find_dir(".git", uv.cwd())
	if _git_dir ~= nil then
		local parent = _git_dir:match("(.*/)")

		if not util.is_dir(parent) then
			vim.notify("Failed to find parent of the Git directory")
			return
		end
		uv.fs_mkdir(parent .. "/tasks", tonumber("755", 8))
	else
		vim.notify("ERR: failed to get version control directory (.git)", vim.levels.ERROR)
		return
	end
end

---@return string[]|nil
function M.list_existing()
	local tasks_dir = util.find_tasks_dir(uv.cwd())
	if tasks_dir == nil then
		vim.notify("ERR: couldn't find tasks directory", vim.levels.log.ERROR)
		return
	end

	---@type string[]
	local tasks = {}
	for name, _ in vim.fs.dir(tasks_dir) do
		local task_file = tasks_dir .. "/" .. name .. "/TASK.md"
		local file = io.open(task_file, "r")
		if file ~= nil then
			local task = file:read("*l")
			table.insert(tasks, tostring(task):sub(3)) -- :sub(3) to skip first 2 characters.
			file:close()
		else
			vim.notify("ERR: couldn't read file: " .. task_file, vim.log.levels.ERROR)
			return
		end
	end

	if tasks ~= {} then
		return tasks
	end
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
