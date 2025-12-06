local uv = vim.uv

local M = {}

---@param msg string
---@param debug boolean
function M.debug(msg, debug)
	if debug then
		vim.notify(msg, vim.log.levels.DEBUG)
	end
end

---@param str string
---@param pattern string
function M.matches(str, pattern)
	if str:match(pattern) then
		return true
	else
		return false
	end
end

function M.generate_huid()
	return os.date("!%Y%d%m-%H%M%S")
end

---@return boolean|nil
---@param path string
function M.is_dir(path)
	local stat = uv.fs_stat(path)
	return stat and stat.type == "directory"
end

---@return string|nil
---@param start string?
function M.find_tasks_dir(start)
	local dir = start or uv.cwd()
	local home = os.getenv("HOME") or "~"

	while dir and dir ~= home do
		local candidate = dir .. "/tasks"
		if M.is_dir(candidate) then
			return candidate
		end

		local parent = dir:match("(.*/)")
		if not parent or parent == dir then
			break
		end
		dir = parent:gsub("/$", "")
	end

	local home_candidate = home .. "/tasks"
	if M.is_dir(home_candidate) then
		return home_candidate
	end

	return nil
end

return M
