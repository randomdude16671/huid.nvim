-- TASK(20251112-154512): Add new issues included into the repo
local util = require("huid.util")
local fs = require("huid.fs")
local M = {}

-- Enums:
---@enum Pickers
local Pickers = {
	snacks = 1,
	telescope = 2,
	fzf_lua = 3,
	mini_pick = 4,
}

M.pickers = Pickers
M.integrations = {}

-- Configuration types:

---@alias WindowBorder
---| "none"
---| "single"
---| "double"
---| "rounded"
---| "solid"
---| "shadow"
---| "bold"

---@alias WindowKind
---| "full"
---| "floating"
---| "vsplit"
---| "hsplit"

---@class HuidWindowConfig
---@field window_kind WindowKind
---@field border_kind WindowBorder

---@class HuidDefaultConfig
---@field vcs_dirname string
---@field picker Pickers?
---@field auto_setup_dir boolean
---@field window HuidWindowConfig

-- Default configuration
---@type HuidDefaultConfig
local default_config = {
	-- The directory to find to place the tasks directory,
	-- found in the project root (required for SetupTaskDirectory)
	vcs_dirname = ".git",

	picker = nil,
	auto_setup_dir = false,

	window = {
		window_kind = "hsplit",
		border_kind = "single",
	},
}

---@type HuidDefaultConfig
M.options = {}

function M.detect_picker()
	local pickers = {
		{ name = "snacks", module = "snacks", integration = "snacks" },
		{ name = "telescope", module = "telescope", integration = "telescope" },
		{ name = "mini_pick", module = "mini.pick", integration = "minipick" },
		{ name = "fzf_lua", module = "fzf-lua", integration = "fzf_lua" },
	}

	for _, picker in ipairs(pickers) do
		local ok, module = pcall(require, picker.module)
		if ok then
			M.integrations[picker.integration] = module
		end
	end
end

---@param opts HuidDefaultConfig?
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", default_config, opts or {})

	M.detect_picker()

	vim.api.nvim_create_user_command("SetupTaskDirectory", function()
		fs.setup_dir(M.options.vcs_dirname)
	end, {})

	-- Convert a TODO comment into a TASK(<HUID>) comment.
	vim.api.nvim_create_user_command("ConvertTodo", function()
		require("huid.navigation").convert()
	end, {})

	-- Pick a task through a specified fuzzy picker or go to the default one if only one is present
	vim.api.nvim_create_user_command("PickTasks", function()
		require("huid.navigation").list()
	end, {})

	-- Make a new task
	vim.api.nvim_create_user_command("NewTask", function()
		vim.ui.input({ prompt = "Enter the Task Description, With the priority next to it" }, function(input)
			if not input then
				vim.notify("ERR: task input cancelled", vim.log.levels.ERROR)
				return
			end

			local huid = util.generate_huid()
			local pattern = "(.-)(%d+)$"
			local description, priority_str = input:match(pattern)

			if not description or not priority_str then
				vim.notify("ERR: the request doesn't match the proper requested data.", vim.log.levels.ERROR)
				return
			end

			fs.make_new(description, tonumber(priority_str, 10), huid)

			local commentstring = vim.api.nvim_get_option_value("commentstring", {})
			if not commentstring then
				vim.notify("ERR: couldn't get commentstring", vim.log.levels.ERROR)
				return
			end

			vim.api.nvim_set_current_line(string.format(commentstring, "TASK(" .. huid .. "): " .. description))
		end)
	end, {})
end

return M
