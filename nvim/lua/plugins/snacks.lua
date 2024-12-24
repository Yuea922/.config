return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = { enabled = true },
        dashboard = {
            enabled = true,
            preset = {
                header = [[
        ███╗   ███╗██╗   ██╗███╗  ██╗██╗   ██╗██╗███╗   ███╗          Z
        ████╗ ████║╚██╗ ██╔╝████╗ ██║██║   ██║██║████╗ ████║      Z    
        ██╔████╔██║ ╚████╔╝ ██╔██╗██║██║   ██║██║██╔████╔██║   z       
        ██║╚██╔╝██║  ╚██╔╝  ██║╚████║╚██╗ ██╔╝██║██║╚██╔╝██║ z         
        ██║ ╚═╝ ██║   ██║   ██║ ╚███║ ╚████╔╝ ██║██║ ╚═╝ ██║           
        ╚═╝     ╚═╝   ╚═╝   ╚═╝   ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝           
    ]],
                -- stylua: ignore
                keys = {
                    { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                    { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                    { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
                    { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
                    { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
                    { icon = " ", key = "s", desc = "Restore Session", section = "session" },
                    -- { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
                    { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                },
                footer = function()
                    local stats = require("lazy").stats()
                    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                    return {
                        "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
                    }
                end,
            },
            sections = {
                { section = "header" },
                { section = "keys", gap = 1, padding = 1 },
                { section = "startup" },
            },
        },
        git = { enabled = true },
        gitbrowsw = { enabled = true },
        indent = { enabled = true },
        lazygit = { enabled = true },
        notifier = {
            enabled = true,
            timeout = 30000,
            -- editor margin to keep free. tabline and statusline are taken into account automatically
            margin = { top = 1, right = 1, bottom = 0 },
        },
        quickfile = { enabled = true },
        scroll = { enabled = false },
        statuscolumn = { enabled = false }, -- we set this in options.lua
        terminal = { enabled = false },
        words = { enabled = true },
    },
    -- stylua: ignore
    keys = {
        { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
        { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
        { "<leader>gg", function() Snacks.lazygit({ cwd = Util.root.git() }) end, desc = "Lazygit (root dir)" },
        { "<leader>gG", function() Snacks.lazygit() end, desc = "Lazygit (cwd)" },
        { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
        { "<leader>gl", function() Snacks.lazygit.log({ cwd = Util.root.git() }) end, desc = "Lazygit Log (root dir)" },
        { "<leader>gL", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
        { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
        { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    },
    config = function(_, opts)
        local notify = vim.notify
        require("snacks").setup(opts)
        -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
        -- this is needed to have early notifications show up in noice history
        if Util.has("noice.nvim") then
            vim.notify = notify
        end
    end,
    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            callback = function()
                -- Setup some globals for debugging (lazy-loaded)
                _G.dd = function(...)
                    Snacks.debug.inspect(...)
                end
                _G.bt = function()
                    Snacks.debug.backtrace()
                end
                vim.print = _G.dd -- Override print to use snacks for `:=` command

                -- Create some toggle mappings
                Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
                Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
                Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
                Snacks.toggle.diagnostics():map("<leader>ud")
                Snacks.toggle.line_number():map("<leader>ul")
                Snacks.toggle
                    .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
                    :map("<leader>uc")
                Snacks.toggle.treesitter():map("<leader>uT")
                Snacks.toggle
                    .option("background", { off = "light", on = "dark", name = "Dark Background" })
                    :map("<leader>ub")
                Snacks.toggle.dim():map("<leader>uD")
                if vim.lsp.inlay_hint then
                    Snacks.toggle.inlay_hints():map("<leader>uh")
                end
            end,
        })
    end,
}
