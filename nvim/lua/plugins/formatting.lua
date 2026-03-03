local prettier_ft = {
    "css",
    "graphql",
    "handlebars",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "less",
    "markdown",
    "markdown.mdx",
    "scss",
    "typescript",
    "typescriptreact",
    "vue",
    "yaml",
}

--- Checks if a Prettier config file exists for the given context
---@param ctx ConformCtx
local function has_prettier_config(ctx)
    vim.fn.system({ "prettier", "--find-config-path", ctx.filename })
    return vim.v.shell_error == 0
end

--- Checks if a parser can be inferred for the given context:
--- * If the filetype is in the supported list, return true
--- * Otherwise, check if a parser can be inferred
---@param ctx ConformCtx
local function has_prettier_parser(ctx)
    local ft = vim.bo[ctx.buf].filetype
    -- default filetypes are always supported
    if vim.tbl_contains(prettier_ft, ft) then
        return true
    end
    -- otherwise, check if a parser can be inferred
    local output = vim.fn.system({ "prettier", "--file-info", ctx.filename })
    local ok, result = pcall(vim.fn.json_decode, output)
    if not ok or not result then
        return false
    end
    local parser = result.inferredParser
    return parser ~= nil and parser ~= vim.NIL
end

return {
    -- conform.nvim
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>cf",
                mode = { "n", "v" },
                function()
                    require("conform").format({
                        lsp_format = "fallback",
                        async = false,
                        timeout_ms = 500,
                    })
                end,
                desc = "Format file or range (in visual mode)",
            },
        },
        opts = {
            formatters_by_ft = {
                cpp = { "clang_format" },
                json = { "jq" },
                lua = { "stylua" },
                cmake = { "cmake_format" },
                -- sh = { "shfmt" },
                vue = { "prettier" },
                -- javascript = { "prettier" },
                typescript = { "prettier" },
            },
            format_on_save = function(bufnr)
                local ignore_filetypes = { "cpp", "cmake", "proto" }
                if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
                    return
                end
                return {
                    lsp_format = "fallback",
                    async = false,
                    timeout_ms = 5000,
                }
            end,
            formatters = {
                clang_format = {
                    command = "clang-format",
                    args = function(self, ctx)
                        local find_config = require("conform.util").root_file({
                            ".clang-format",
                            ".clang_format",
                        })
                        if find_config(self, ctx) then
                            return {
                                "-assume-filename",
                                "$FILENAME",
                            }
                        end

                        local global_clang_format = vim.fn.stdpath("config") .. "/formats/clang-format"
                        local stat = vim.uv.fs_stat(global_clang_format)
                        if stat and stat.type == "file" then
                            return {
                                "-assume-filename",
                                "$FILENAME",
                                "-style=file:" .. global_clang_format,
                            }
                        end

                        return {
                            "-assume-filename",
                            "$FILENAME",
                            "-style={ BasedOnStyle: Google, IndentWidth: 4 }",
                        }
                    end,
                },
                prettier = {
                    condition = function(_, ctx)
                        if not has_prettier_parser(ctx) then
                            return false
                        end
                        return has_prettier_config(ctx)
                    end,
                },
            },
        },
        config = function(_, opts)
            require("conform").setup(opts)
        end,
    },
}
