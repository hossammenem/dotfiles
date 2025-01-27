require("options")
require("mappings")
require("lazy_nvim")

-- vim.cmd[[colorscheme GruvboxDarkHard ]]
vim.cmd[[colorscheme iceberg-dark ]]


if vim.fn.has("persistent_undo") == 1 then
	local target_path = vim.fn.expand('~/.undodir')

	-- create the directory and any parent directories
	-- if the location does not exist.
	if vim.fn.isdirectory(target_path) == 0 then
		vim.fn.mkdir(target_path, "p")
	end

	vim.o.undodir = target_path
	vim.o.undofile = true
end

-- Track window state
local saved_windows = nil

-- Toggle between maximized split and original layout
function ToggleMaximizeSplit()
  if saved_windows then
    -- Restore original windows
    vim.cmd("tabclose")  -- Close temporary tab
    vim.cmd("tabnext " .. saved_windows.prev_tab)  -- Switch back to original tab
    saved_windows = nil
  else
    -- Save current state and maximize
    saved_windows = {
      prev_tab = vim.fn.tabpagenr(),  -- Save current tab number
      prev_wins = vim.api.nvim_tabpage_list_wins(0)  -- Save current windows
    }
    vim.cmd("tab split")  -- Move current window to a new tab
    vim.cmd("only")  -- Close other splits in the new tab
  end
end
