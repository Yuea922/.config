return {
    -- git signs
    {
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        opts = {
            signs = {
                add = { text = " " },
                change = { text = " " },
                delete = { text = " " },
                topdelete = { txet = "󱅁 " },
                changedelete = { text = "󰍷 " },
            },
            signs_staged = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
            },

            on_attach = function(buffer)
                local gs = package.loaded.gitsigns

                local function keymap(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
                end

                -- stylua: ignore start
                keymap("n", "<leader>g[", function() gs.nav_hunk("prev") end, "Goto prev hunk (Gitsigns)")
                keymap("n", "<leader>g]", function() gs.nav_hunk("next") end, "Goto next hunk (Gitsigns)")
                keymap("n", "<leader>gr", gs.preview_hunk, "Preview hunk (Gitsigns)")
                keymap("n", "<leader>gR", gs.preview_hunk_inline, "Preview hunk inline (Gitsigns)")
                keymap({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage hunk (Gitsigns)")
                keymap("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk (Gitsigns)")
                keymap("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line (Gitsigns)")
                keymap("n", "<leader>ghd", gs.diffthis, "Diff this (Gitsigns)")
            end,
        },
    },
}
