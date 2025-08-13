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
                -- javascript = { "prettier" },
                -- sh = { "shfmt" },
            },
            format_on_save = function(bufnr)
                local ignore_filetypes = { "cpp", "cmake" }
                if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
                    return
                end
                return {
                    lsp_format = "fallback",
                    async = false,
                    timeout_ms = 500,
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
            },
        },
        config = function(_, opts)
            require("conform").setup(opts)
        end,
    },
}
