local uv = vim.uv

local M = {}

---@param msg string
---@param debug boolean
function M.debug(msg, debug)
	if debug then
		vim.notify(msg, vim.log.levels.DEBUG)
	end
end

---@return string
function M.generate_huid()
	return tostring(os.date("!%Y%d%m-%H%M%S"))
end

---@return boolean|nil
---@param path string
function M.is_dir(path)
	local stat = uv.fs_stat(path)
	return stat and stat.type == "directory"
end

---@return string|nil
---@param dirname string
---@param start string?
function M.find_dir(dirname, start)
	local dir = start or uv.cwd()
	local home = os.getenv("HOME") or "~"
	while dir and dir ~= home do
		local candidate = dir .. "/" .. dirname
		if M.is_dir(candidate) then
			return candidate
		end

		local parent = dir:match("(.*)/")
		if not parent or parent == dir or parent == "" then
			break
		end
		dir = parent:gsub("/$", "")
	end
	local home_candidate = home .. "/" .. dirname
	if M.is_dir(home_candidate) then
		return home_candidate
	end

	return nil
end

---@return string|nil
---@param start string?
-- technically deprecated.
function M.find_tasks_dir(start)
	start = start or uv.cwd()
	return M.find_dir("tasks", start)
end

return M
