local LazyUtil = require("lazy.core.util")

return {
    -- Treesitter is a new parser generator tool that we can
    -- use in Neovim to power faster and more accurate
    -- syntax highlighting.
    -- NOTE:Install tree-sitter v0.26.2 by cargo
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main", -- migrate to nvim-treesitter main branch
        version = false, -- last release is way too old and doesn't work on Windows
        build = function()
            local TS = require("nvim-treesitter")
            if not TS.get_installed then
                LazyUtil.error(
                    "Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch."
                )
                return
            end
            -- make sure we're using the latest treesitter util
            package.loaded["lazyvim.util.treesitter"] = nil
            Util.treesitter.build(function()
                TS.update(nil, { summary = true })
            end)
        end,
        event = { "LazyFile", "VeryLazy" },
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
        keys = {
            { "<c-space>", desc = "Increment selection" },
            { "<bs>", desc = "Decrement selection", mode = "x" },
        },
        ---@alias nvim.TSFeat { enable?: boolean, disable?: string[] }
        ---@class nvim.TSConfig: TSConfig
        opts = {
            autopairs = { enable = true },
            indent = { enable = true }, ---@type nvim.TSFeat
            highlight = { enable = true }, ---@type nvim.TSFeat
            folds = { enable = true }, ---@type nvim.TSFeat
            ensure_installed = {
                "cpp",
                "c",
                "cmake",
                "bash",
                "markdown",
                "markdown_inline",
                "css",
                "javascript",
                "typescript",
                "tsx",
                "php",
                "css",
                "json",
                "jsonc",
                "lua",
                "luadoc",
                "vim",
                "vimdoc",
                "vue",
                "xml",
                "yaml",
                "regex",
                "ninja",
                "rst",
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
        },
        ---@param opts nvim.TSConfig
        config = function(_, opts)
            local TS = require("nvim-treesitter")

            setmetatable(require("nvim-treesitter.install"), {
                __newindex = function(_, k)
                    if k == "compilers" then
                        vim.schedule(function()
                            LazyUtil.error({
                                "Setting custom compilers for `nvim-treesitter` is no longer supported.",
                                "",
                                "For more info, see:",
                                "- [compilers](https://docs.rs/cc/latest/cc/#compile-time-requirements)",
                            })
                        end)
                    end
                end,
            })

            -- some quick sanity checks
            if not TS.get_installed then
                return LazyUtil.error("Please use `:Lazy` and update `nvim-treesitter`")
            elseif type(opts.ensure_installed) ~= "table" then
                return LazyUtil.error("`nvim-treesitter` opts.ensure_installed must be a table")
            end

            -- setup treesitter
            TS.setup(opts)
            Util.treesitter.get_installed(true) -- initialize the installed langs

            -- install missing parsers
            local install = vim.tbl_filter(function(lang)
                return not Util.treesitter.have(lang)
            end, opts.ensure_installed or {})
            if #install > 0 then
                Util.treesitter.build(function()
                    TS.install(install, { summary = true }):await(function()
                        Util.treesitter.get_installed(true) -- refresh the installed langs
                    end)
                end)
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("nvim_treesitter", { clear = true }),
                callback = function(ev)
                    local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
                    if not Util.treesitter.have(ft) then
                        return
                    end

                    ---@param feat string
                    ---@param query string
                    local function enabled(feat, query)
                        local f = opts[feat] or {} ---@type nvim.TSFeat
                        return f.enable ~= false
                            and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
                            and Util.treesitter.have(ft, query)
                    end

                    -- highlighting
                    if enabled("highlight", "highlights") then
                        pcall(vim.treesitter.start, ev.buf)
                    end

                    -- indents
                    if enabled("indent", "indents") then
                        vim.api.nvim_set_option_value(
                            "indentexpr",
                            "v:lua.Util.treesitter.indentexpr()",
                            { scope = "local" }
                        )
                    end

                    -- folds
                    if enabled("folds", "folds") then
                        vim.api.nvim_set_option_value(
                            "foldexpr",
                            "v:lua.Util.treesitter.foldexpr()",
                            { scope = "local" }
                        )
                    end
                end,
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = "VeryLazy",
        opts = {
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                -- extention to create buffer-local keymaps
                keys = {
                    goto_next_start = {
                        ["]f"] = "@function.outer",
                        ["]c"] = "@class.outer",
                        ["]a"] = "@parameter.inner",
                    },
                    goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
                    goto_previous_start = {
                        ["[f"] = "@function.outer",
                        ["[c"] = "@class.outer",
                        ["[a"] = "@parameter.inner",
                    },
                    goto_previous_end = {
                        ["[F"] = "@function.outer",
                        ["[C"] = "@class.outer",
                        ["[A"] = "@parameter.inner",
                    },
                },
            },
        },
        config = function(_, opts)
            local TS = require("nvim-treesitter-textobjects")
            if not TS.setup then
                LazyUtil.error("Please use `:Lazy` and update `nvim-treesitter`")
                return
            end
            TS.setup(opts)

            local function attach(buf)
                local ft = vim.bo[buf].filetype
                if not (vim.tbl_get(opts, "move", "enable") and Util.treesitter.have(ft, "textobjects")) then
                    return
                end
                ---@type table<string, table<string, string>>
                local moves = vim.tbl_get(opts, "move", "keys") or {}

                for method, keymaps in pairs(moves) do
                    for key, query in pairs(keymaps) do
                        local desc = query:gsub("@", ""):gsub("%..*", "")
                        desc = desc:sub(1, 1):upper() .. desc:sub(2)
                        desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
                        desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
                        if not (vim.wo.diff and key:find("[cC]")) then
                            vim.keymap.set({ "n", "x", "o" }, key, function()
                                require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
                            end, {
                                buffer = buf,
                                desc = desc,
                                silent = true,
                            })
                        end
                    end
                end
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("lazyvim_treesitter_textobjects", { clear = true }),
                callback = function(ev)
                    attach(ev.buf)
                end,
            })
            vim.tbl_map(attach, vim.api.nvim_list_bufs())
        end,
    },

    -- comments
    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        event = { "LazyFile", "VeryLazy" },
        opts = {
            enable = true,
            enable_autocmd = false,
        },
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        event = { "LazyFile", "VeryLazy" },
        enabled = true,
        opts = function()
            local tsc = require("treesitter-context")
            Snacks.toggle({
                name = "Treesitter Context",
                get = tsc.enabled,
                set = function(state)
                    if state then
                        tsc.enable()
                    else
                        tsc.disable()
                    end
                end,
            }):map("<leader>ut")
            return { mode = "cursor", max_lines = 3 }
        end,
    },

    {
        "windwp/nvim-ts-autotag",
        event = "LazyFile",
        opts = {
            -- Defaults
            -- enable_close = true, -- Auto close tags
            -- enable_rename = true, -- Auto rename pairs of tags
            enable_close_on_slash = false, -- Auto close on trailing </
        },
    },
}
