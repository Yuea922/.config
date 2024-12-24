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
                javascript = { "prettier" },
                sh = { "shfmt" },
                lua = { "stylua" },
            },
            format_on_save = {
                -- lsp_format = "fallback",
                async = false,
                timeout_ms = 500,
            },
        },
        config = function(_, opts)
            require("conform").setup(opts)
        end,
    },
}
