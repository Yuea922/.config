return {
    -- lspconfig
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason.nvim",
            { "mason-org/mason-lspconfig.nvim", config = function() end },
        },
        ---@class PluginLspOpts
        opts = {
            ---@type vim.diagnostic.Opts
            diagnostics = {
                underline = true,
                update_in_insert = false,
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "icons",
                },
                severity_sort = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = require("config").icons.diagnostics.Error,
                        [vim.diagnostic.severity.WARN] = require("config").icons.diagnostics.Warn,
                        [vim.diagnostic.severity.HINT] = require("config").icons.diagnostics.Hint,
                        [vim.diagnostic.severity.INFO] = require("config").icons.diagnostics.Info,
                    },
                },
            },
            -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the inlay hints.
            inlay_hints = {
                enabled = false,
                exclude = { "vue" },
            },
            -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the code lenses.
            codelens = {
                enabled = false,
            },
            -- Enable this to enable the builtin LSP folding on Neovim.
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the folds.
            folds = {
                enabled = true,
            },
            -- Enable lsp cursor word highlighting
            document_highlight = {
                enabled = true,
            },
            -- add any global capabilities here
            capabilities = {
                workspace = {
                    fileOperations = {
                        didRename = true,
                        willRename = true,
                    },
                },
            },
            -- options for vim.lsp.buf.format
            -- `bufnr` and `filter` is handled by the LazyVim formatter,
            -- but can be also overridden when specified
            format = {
                formatting_options = nil,
                timeout_ms = nil,
            },
            -- LSP Server Settings
            ---@alias lazyvim.lsp.Config vim.lsp.Config|{mason?:boolean, enabled?:boolean}
            ---@type table<string, lazyvim.lsp.Config|boolean>
            servers = {
                stylua = { enabled = false },
                lua_ls = {
                    -- mason = false, -- set to false if you don't want this server to be installed with mason
                    -- Use this to add any additional keymaps
                    -- for specific lsp servers
                    -- ---@type LazyKeysSpec[]
                    -- keys = {},
                },
                jsonls = {},
                clangd = {
                    filetypes = { "c", "cpp", "objc", "objcpp" },
                    keys = {
                        { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
                    },
                },
                cmake = {},
                eslint = {},
                protols = {
                    filetypes = { "proto" },
                },
                vue_ls = {
                    filetypes = { "vue" },
                    -- In this mode, the Vue Language Server exclusively manages the CSS/HTML sections.
                    -- Nees the `ts_ls` server with the `@vue/typescript-plugin` plugin
                    -- to support TypeScript in `.vue` files.
                    init_options = {
                        vue = {
                            hybridMode = true, -- default
                        },
                    },
                },
                vtsls = {
                    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
                },
                pyright = {},
                ruff = {
                    capabilities = {
                        offset_encoding = "utf-16",
                    },
                    cmd_env = { RUFF_TRACE = "messages" },
                    init_options = {
                        settings = {
                            logLevel = "error",
                        },
                    },
                    keys = {
                        {
                            "<leader>co",
                            Util.lsp.action["source.organizeImports"],
                            desc = "Organize Imports",
                        },
                    },
                },
            },
            -- you can do any additional lsp server setup here
            -- return true if you don't want this server to be setup with lspconfig
            ---@type table<string, fun(server:string, opts: vim.lsp.Config):boolean?>
            setup = {
                -- Specify * to use this function as a fallback for any server
                -- ["*"] = function(server, opts) end,
                clangd = function(_, opts)
                    local clangd_ext_opts = Util.opts("clangd_extensions.nvim")
                    require("clangd_extensions").setup(
                        vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts })
                    )
                    return false
                end,
                ruff = function()
                    Util.lsp.on_attach(function(client, _)
                        -- Disable hover in favor of Pyright
                        client.server_capabilities.hoverProvider = false
                    end, "ruff")
                end,
            },
        },
        ---@param opts PluginLspOpts
        config = vim.schedule_wrap(function(_, opts)
            -- TODO: setup autoformat
            -- setup autoformat
            -- Util.format.register(Util.lsp.formatter())

            -- setup keymaps
            Util.lsp.on_attach(function(client, buffer)
                require("plugins.lsp.keymaps").on_attach(client, buffer)
            end)

            Util.lsp.setup()
            Util.lsp.on_dynamic_capability(require("plugins.lsp.keymaps").on_attach)

            -- inlay hints
            if opts.inlay_hints.enabled then
                Util.lsp.on_supports_method("textDocument/inlayHint", function(client, buffer)
                    if
                        vim.api.nvim_buf_is_valid(buffer)
                        and vim.bo[buffer].buftype == ""
                        and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
                    then
                        vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
                    end
                end)
            end

            -- folds
            if opts.folds.enabled then
                Util.lsp.on_supports_method("textDocument/foldingRange", function(client, buffer)
                    vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.lap.foldexpr()", { scope = "local" })
                end)
            end

            -- code lens
            if opts.codelens.enabled and vim.lsp.codelens then
                Util.lsp.on_supports_method("textDocument/codeLens", function(client, buffer)
                    vim.lsp.codelens.refresh()
                    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                        buffer = buffer,
                        callback = vim.lsp.codelens.refresh,
                    })
                end)
            end

            -- hover
            -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
            --     border = "rounded", -- 设置边框样式为圆角
            -- })
            -- local hover = vim.lsp.buf.hover
            -- ---@diagnostic disable-next-line: duplicate-set-field
            -- vim.lsp.buf.hover = function()
            --     return hover({
            --         border = "rounded",
            --     })
            -- end

            -- diagnostics
            if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
                opts.diagnostics.virtual_text.prefix = function(diagnostic)
                    local icons = require("config").icons.diagnostics
                    for d, icon in pairs(icons) do
                        if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
                            return icon
                        end
                    end
                    return "●"
                end
            end
            vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

            if opts.capabilities then
                vim.lsp.config("*", { capabilities = opts.capabilities })
            end

            -- get all the servers that are available through mason-lspconfig
            local have_mason = Util.has("mason-lspconfig.nvim")
            local mason_all = have_mason
                    and vim.tbl_keys(require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package)
                or {} --[[ @as string[] ]]
            local mason_exclude = {} ---@type string[]

            ---@return boolean? exclude automatic setup
            local function configure(server)
                local server_opts = opts.servers[server]
                server_opts = server_opts == true and {} or (not server_opts) and { enabled = false } or server_opts --[[@as lazyvim.lsp.Config]]

                if server_opts.enabled == false then
                    mason_exclude[#mason_exclude + 1] = server
                    return
                end

                local require_ok, conf_opts = pcall(require, "plugins.lsp.settings." .. server)
                if require_ok then
                    server_opts = vim.tbl_deep_extend("force", server_opts, conf_opts or {})
                end

                local use_mason = server_opts.mason ~= false and vim.tbl_contains(mason_all, server)
                local setup = opts.setup[server] or opts.setup["*"]
                if setup and setup(server, server_opts) then
                    mason_exclude[#mason_exclude + 1] = server
                else
                    vim.lsp.config(server, server_opts) -- configure the server
                    if not use_mason then
                        vim.lsp.enable(server)
                    end
                end
                return use_mason
            end

            local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
            if have_mason then
                require("mason-lspconfig").setup({
                    ensure_installed = vim.list_extend(
                        install,
                        Util.opts("mason-lspconfig.nvim").ensure_installed or {}
                    ),
                    automatic_enable = { exclude = mason_exclude },
                })
            end
        end),
    },

    -- cmdline tools and lsp servers
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        build = ":MasonUpdate",
        opts_extend = { "ensure_installed" },
        opts = {
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
            ensure_installed = {
                "stylua", -- stylua@0.20.0
                "lua-language-server", -- lua_ls@3.16.3
                "shfmt",
                "cmakelang",
                "cmakelint",
                "clang-format", -- clang-format@20.1.0
                "clangd", -- clangd@20.1.0
                "protols",
                "vue-language-server",
                "vtsls",
                "prettier",
                "black",
            },
        },
        ---@param opts MasonSettings | {ensure_installed: string[]}
        config = function(_, opts)
            require("mason").setup(opts)
            local mr = require("mason-registry")
            mr:on("package:install:success", function()
                vim.defer_fn(function()
                    -- trigger FileType event to possibly load this newly installed LSP server
                    require("lazy.core.handler.event").trigger({
                        event = "FileType",
                        buf = vim.api.nvim_get_current_buf(),
                    })
                end, 100)
            end)

            mr.refresh(function()
                for _, tool in ipairs(opts.ensure_installed) do
                    local p = mr.get_package(tool)
                    if not p:is_installed() then
                        p:install()
                    end
                end
            end)
        end,
    },

    {
        "p00f/clangd_extensions.nvim",
        lazy = true,
        config = function() end,
        opts = {
            inlay_hints = {
                inline = false,
            },
            ast = {
                --These require codicons (https://github.com/microsoft/vscode-codicons)
                role_icons = {
                    type = "",
                    declaration = "",
                    expression = "",
                    specifier = "",
                    statement = "",
                    ["template argument"] = "",
                },
                kind_icons = {
                    Compound = "",
                    Recovery = "",
                    TranslationUnit = "",
                    PackExpansion = "",
                    TemplateTypeParm = "",
                    TemplateTemplateParm = "",
                    TemplateParamObject = "",
                },
            },
        },
    },

    {
        "Civitasv/cmake-tools.nvim",
        lazy = true,
        init = function()
            local loaded = false
            local function check()
                local cwd = vim.uv.cwd()
                if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
                    require("lazy").load({ plugins = { "cmake-tools.nvim" } })
                    loaded = true
                end
            end
            check()
            vim.api.nvim_create_autocmd("DirChanged", {
                callback = function()
                    if not loaded then
                        check()
                    end
                end,
            })
        end,
        opts = {},
    },

    {
        "nvim-cmp",
        opts = function(_, opts)
            table.insert(opts.sorting.comparators, 1, require("clangd_extensions.cmp_scores"))
        end,
    },
}
