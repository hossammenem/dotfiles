return {
  "rmagatti/auto-session",
  config = function()
    require("auto-session").setup({
      -- Use FULL PATH to avoid name collisions (e.g., "nvim" vs. "home-manager")
      auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
      auto_session_enable_last_session = false, -- Disable "last session" fallback
      auto_session_suppress_dirs = { "~/", "/", "~/Downloads" }, -- Suppress generic dirs
      -- Force session names to use full directory paths (replace "/" with "_")
      auto_session_session_name = function(dir)
        return dir:gsub("/", "_"):gsub("%.", "")
      end,
    })
  end,
}
