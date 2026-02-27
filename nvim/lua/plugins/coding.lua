return {
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp",
        dependencies = {
            "rafamadriz/friendly-snippets",
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
                require("luasnip.loaders.from_lua").lazy_load({ paths = { "./snippets/lua" } })
            end,
        },
        opts = {
            history = true,
            delete_check_events = "TextChanged",
        },
    },

    {
        "hrsh7th/nvim-cmp",
        version = false, -- last release is way too old
        event = { "InsertEnter" }, -- Enter insert model
        enabled = false,
        dependencies = {
            -- Sources
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lua",
        },

        opts = function()
            vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
            local cmp = require("cmp")
            local defaults = require("cmp.config.default")()

            local luasnip = require("luasnip")
            local has_words_before = function()
                unpack = unpack or table.unpack
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0
                    and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            return {
                completion = {
                    completeopt = "menu, menuone, noinsert",
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "nvim_lua" },
                    { name = "path" },
                    { name = "buffer" },
                }),
                mapping = cmp.mapping.preset.insert({
                    ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    -- Accept currently selected item. If none selected, `select` first item.
                    -- Set `select` to `false` to only confirm explicitly selected items.
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<S-CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expandable() then
                            luasnip.expand()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, {
                        "i",
                        "s",
                    }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, {
                        "i",
                        "s",
                    }),
                }),
                formatting = {
                    format = function(entry, item)
                        local icons = require("config").icons.kinds
                        if icons[item.kind] then
                            item.kind = icons[item.kind] .. item.kind
                        end
                        item.menu = ({
                            nvim_lsp = "[LSP]",
                            nvim_lua = "[LSP]",
                            luasnip = "[Snippet]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                        })[entry.source.name]
                        return item
                    end,
                },
                experimental = {
                    ghost_text = {
                        hl_group = "CmpGhostText",
                    },
                },
                sorting = defaults.sorting,
            }
        end,

        config = function(_, opts)
            for _, source in ipairs(opts.sources) do
                source.group_index = source.group_index or 1
            end
            require("cmp").setup(opts)
        end,
    },

    {
        "saghen/blink.cmp",
        enabled = true,
        dependencies = {
            "rafamadriz/friendly-snippets",
            "L3MON4D3/LuaSnip",
            -- add blink.compat to dependencies
            {
                "saghen/blink.compat",
                opts = {},
                version = "2.*",
                lazy = true,
            },
        },
        event = { "InsertEnter", "CmdlineEnter" },

        opts = {
            snippets = {
                preset = "luasnip",
                --INFO: 避免dartls补全占位符的问题
                expand = function(args)
                    require("luasnip").lsp_expand(args)
                end,
            },

            sources = {
                -- adding any nvim-cmp sources here will enable them
                -- with blink.compat
                compat = { "nvim_lua" },
                default = { "lsp", "path", "snippets", "buffer" },
                per_filetype = {
                    codecompanion = { "codecompanion" },
                },
            },

            appearance = {
                -- sets the fallback highlight groups to nvim-cmp's highlight groups
                -- useful for when your theme doesn't support blink.cmp
                -- will be removed in a future release, assuming themes add support
                use_nvim_cmp_as_default = false,
                -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono",
                kind_icons = require("config").icons.kinds,
            },

            signature = {
                enabled = true,
                trigger = {
                    blocked_trigger_characters = {},
                    blocked_retrigger_characters = {},
                    -- When true, will show the signature help window when the cursor comes after a trigger character when entering insert mode
                    show_on_insert_on_trigger_character = true,
                },
                window = {
                    min_width = 1,
                    max_width = 80,
                    max_height = 10,
                    border = "rounded",
                    winblend = 20,
                    winhighlight = "Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder",
                    scrollbar = false, -- Note that the gutter will be disabled when border ~= 'none'
                    -- Which directions to show the window,
                    -- falling back to the next direction when there's not enough space,
                    -- or another window is in the way
                    direction_priority = { "n", "s" },
                    -- Disable if you run into performance issues
                    treesitter_highlighting = true,
                },
            },

            completion = {
                keyword = {
                    -- 'prefix' will fuzzy match on the text before the cursor
                    -- 'full' will fuzzy match on the text before _and_ after the cursor
                    -- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
                    range = "full",
                },
                ghost_text = {
                    enabled = true,
                },
                accept = {
                    -- experimental auto-brackets support
                    auto_brackets = {
                        enabled = true,
                    },
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                    window = {
                        border = "rounded",
                        direction_priority = {
                            menu_north = { "w", "e", "n", "s" },
                            menu_south = { "w", "e", "s", "n" },
                        },
                    },
                },
                list = {
                    -- Maximum number of items to display
                    max_items = 200,
                    -- Controls if completion items will be selected automatically,
                    -- and whether selection automatically inserts
                    selection = { preselect = false, auto_insert = false },
                    -- Controls how the completion items are selected
                    -- 'preselect' will automatically select the first item in the completion list
                    -- 'manual' will not select any item by default
                    -- 'auto_insert' will not select any item by default, and insert the completion items automatically
                    -- when selecting them
                    --
                    -- You may want to bind a key to the `cancel` command, which will undo the selection
                    -- when using 'auto_insert'
                    cycle = {
                        -- When `true`, calling `select_next` at the *bottom* of the completion list
                        -- will select the *first* completion item.
                        from_bottom = true,
                        -- When `true`, calling `select_prev` at the *top* of the completion list
                        -- will select the *last* completion item.
                        from_top = true,
                    },
                },
                menu = {
                    border = "rounded",
                    max_height = 15,
                    winblend = 20,
                    winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
                    draw = {
                        treesitter = { "lsp" },
                        columns = {
                            { "source_name" },
                            { "label" },
                            { "kind_icon", "kind", gap = 1 },
                            { "label_description" },
                        },
                        components = {
                            label = {
                                ellipsis = true,
                                width = { fill = true, max = 50 },
                                text = function(ctx)
                                    return ctx.label .. ctx.label_detail
                                end,
                                highlight = function(ctx)
                                    -- label and label details
                                    local highlights = {
                                        {
                                            0,
                                            #ctx.label,
                                            group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
                                        },
                                    }
                                    if ctx.label_detail then
                                        table.insert(highlights, {
                                            #ctx.label,
                                            #ctx.label + #ctx.label_detail,
                                            group = "BlinkCmpLabelDetail",
                                        })
                                    end

                                    -- -- characters matched on the label by the fuzzy matcher
                                    for _, idx in ipairs(ctx.label_matched_indices) do
                                        table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                                    end

                                    return highlights
                                end,
                            },
                            label_description = {
                                width = { max = 50 },
                                text = function(ctx)
                                    if ctx.item.detail ~= nil and ctx.item.detail ~= "" and #ctx.item.detail <= 65 then
                                        return ctx.item.detail
                                    end
                                    if ctx.label_description ~= "" and ctx.label_description ~= nil then
                                        return ctx.label_description
                                    end
                                end,
                                highlight = "BlinkCmpLabelDescription",
                            },
                            source_name = {
                                width = { max = 10 },
                                -- source_name or source_id are supported
                                text = function(ctx)
                                    local icons = require("config").icons.blink
                                    return icons[ctx.source_name] or ctx.source_name
                                end,
                                highlight = "BlinkCmpLabel",
                            },
                        },
                    },
                },
            },

            cmdline = {
                enabled = true,
                keymap = {
                    preset = "cmdline",
                    ["<Right>"] = false,
                    ["<Left>"] = false,
                },
                completion = {
                    list = { selection = { preselect = false } },
                    menu = {
                        auto_show = function(ctx)
                            return vim.fn.getcmdtype() == ":"
                        end,
                    },
                    ghost_text = { enabled = true },
                },
            },

            keymap = {
                preset = "default",
                ["<CR>"] = { "accept", "fallback" },
                ["<C-j>"] = { "scroll_documentation_down", "snippet_forward" },
                ["<C-k>"] = { "scroll_documentation_up", "snippet_backward" },
                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },
                ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                ["<C-g>"] = { "show_signature", "hide_signature", "fallback" },
                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "cancel", "fallback" },
                ["<C-d>"] = { "snippet_forward" },
            },

            hl_group_mapping = {
                BlinkCmpLabel = "Fg",
                BlinkCmpLabelMatch = { cterm = { bold = true }, ctermfg = 110, bold = true, fg = "#6cb6eb" },
                BlinkCmpLabelDetail = { bold = true, fg = "#7e8294" },
                BlinkCmpLabelDescription = { bold = true, fg = "#7e8294" },
                BlinkCmpLabelDeprecated = "Grey",

                BlinkCmpGhostText = { italic = true, bold = true, fg = "#909090" },

                BlinkCmpMenu = "Fg",
                BlinkCmpKindText = "Fg",

                BlinkCmpKind = "Purple",
                BlinkCmpKindKeyword = "Purple",
                BlinkCmpKindEvent = "Purple",
                BlinkCmpKindOperator = "Purple",

                BlinkCmpKindMethod = "Blue",
                BlinkCmpKindConstructor = "Blue",
                BlinkCmpKindField = "Blue",

                BlinkCmpKindFunction = "Green",
                BlinkCmpKindUnit = "Green",
                BlinkCmpKindValue = "Green",
                BlinkCmpKindFile = "Green",
                BlinkCmpKindEnumMember = "Green",

                BlinkCmpKindVariable = "Red",
                BlinkCmpKindProperty = "Red",
                BlinkCmpKindConstant = "Red",

                BlinkCmpKindClass = "Yellow",
                BlinkCmpKindInterface = "Yellow",
                BlinkCmpKindModule = "Yellow",
                BlinkCmpKindEnum = "Yellow",
                BlinkCmpKindStruct = "Yellow",
                BlinkCmpKindTypeParameter = "Yellow",

                BlinkCmpKindSnippet = "Cyan",
                BlinkCmpKindColor = "Cyan",
                BlinkCmpKindReference = "Cyan",
                BlinkCmpKindFolder = "Cyan",
                BlinkCmpKindCodeium = "Cyan",
            },
        },
        config = function(_, opts)
            -- setup compat sources
            local enabled = opts.sources.default
            for _, source in ipairs(opts.sources.compat or {}) do
                opts.sources.providers[source] = vim.tbl_deep_extend(
                    "force",
                    { name = source, module = "blink.compat.source" },
                    opts.sources.providers[source] or {}
                )
                if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
                    table.insert(enabled, source)
                end
            end
            -- Unset custom prop to pass blink.cmp validation
            opts.sources.compat = nil

            -- TODO:add ai_accept to <Tab> key

            -- check if we need to override symbol kinds
            for _, provider in pairs(opts.sources.providers or {}) do
                if provider.kind then
                    local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
                    local kind_idx = #CompletionItemKind + 1

                    CompletionItemKind[kind_idx] = provider.kind
                    CompletionItemKind[provider.kind] = kind_idx

                    local transform_items = provider.transform_items
                    provider.transform_items = function(ctx, items)
                        items = transform_items and transform_items(ctx, items) or items
                        for _, item in ipairs(items) do
                            item.kind = kind_idx or item.kind
                            item.kind_icon = require("config").icons.kinds[item.kind_name] or item.kind_icon or nil
                        end
                        return items
                    end

                    -- Unset custom prop to pass blink.cmp validation
                    provider.kind = nil
                end
            end

            -- -- 检查基本颜色组是否存在（至少检查几个关键的）
            -- local base_groups = { "Fg", "Purple", "Cyan", "Yellow", "Red", "Blue", "Green", "Grey" }
            -- local ok = true
            -- for _, group in ipairs(base_groups) do
            --     local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
            --     if not hl or (not hl.fg and not hl.link) then
            --         -- 如果没有定义任何颜色，则认为缺失
            --         ok = false
            --         break
            --     end
            -- end

            for blink_hl, target in pairs(opts.hl_group_mapping) do
                if type(target) == "string" then
                    vim.cmd(string.format("highlight! link %s %s", blink_hl, target))
                elseif type(target) == "table" then
                    vim.api.nvim_set_hl(0, blink_hl, target)
                end
            end

            -- Unset custom prop to pass blink.cmp validation
            opts.hl_group_mapping = nil

            require("blink.cmp").setup(opts)
        end,
    },

    -- disable noice signature (use blink.cmp)
    {
        "folke/noice.nvim",
        opts = {
            lsp = {
                signature = {
                    enabled = true,
                    auto_open = {
                        enabled = false,
                        trigger = false, -- Automatically show signature help when typing a trigger character from the LSP
                        luasnip = false, -- Will open signature help when jumping to Luasnip insert nodes
                        throttle = 50, -- Debounce lsp signature help request by 50ms
                    },
                    view = nil, -- when nil, use defaults from documentation
                    opts = {}, -- merged with defaults from documentation
                },
            },
        },
    },

    {
        "numToStr/Comment.nvim",
        event = { "LazyFile", "VeryLazy" },
        opts = {
            pre_hook = function()
                require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
            end,
        },
    },

    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
        opts = {
            disable_filetype = { "TelescopePrompt", "spectre_panel" },
            ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
            check_ts = true,
            ts_config = {
                lua = { "string", "source" },
                javascript = { "string", "template_string" },
                java = false,
            },
            fast_wrap = {
                map = "<M-e>",
                chars = { "{", "[", "(", '"', "'" },
                pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
                offset = 0, -- Offset from pattern match
                end_key = "$",
                keys = "qwertyuiopzxcvbnmasdfghjkl",
                check_comma = true,
                highlight = "PmenuSel",
                highlight_grey = "LineNr",
            },
        },
    },

    {
        "folke/lazydev.nvim",
        ft = "lua",
        cmd = "LazyDev",
        opts = {
            library = {
                { path = "luvit-meta/library", words = { "vim%.uv" } },
                { path = "snacks.nvim", words = { "Snacks" } },
                { path = "lazy.nvim", words = { "LazyVim" } },
            },
        },
    },

    -- Manage libuv types with lazy. Plugin will never be loaded
    { "Bilal2453/luvit-meta", lazy = true },

    -- Add lazydev source to cmp
    {
        "hrsh7th/nvim-cmp",
        optional = true,
        opts = function(_, opts)
            table.insert(opts.sources, { name = "lazydev", group_index = 0 })
        end,
    },

    -- Add lazydev source to cmp
    {
        "saghen/blink.cmp",
        opts = {
            sources = {
                per_filetype = {
                    lua = { inherit_defaults = true, "lazydev" },
                },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100, -- show at a higher priority than lsp
                    },
                },
            },
        },
    },

    {
        "HiPhish/rainbow-delimiters.nvim",
        enabled = true,
        event = { "LazyFile", "VeryLazy" },
        opts = {
            highlight = {
                "RainbowDelimiterGreen",
                "RainbowDelimiterOrange",
                "RainbowDelimiterBlue",
                "RainbowDelimiterYellow",
                "RainbowDelimiterCyan",
                "RainbowDelimiterViolet",
                "RainbowDelimiterRed",
            },
        },
        config = function(_, opts)
            require("rainbow-delimiters.setup").setup(opts)
        end,
    },
}
