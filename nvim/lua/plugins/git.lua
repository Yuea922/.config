return {
	-- git signs
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>g[",
				"<Cmd>Gitsigns prev_hunk<CR>",
				desc = "Goto prev hunk (Gitsigns)",
			},
			{
				"<leader>g]",
				"<Cmd>Gitsigns next_hunk<CR>",
				desc = "Goto next hunk (Gitsigns)",
			},
			{
				"<leader>gr",
				"<Cmd>Gitsigns preview_hunk<CR>",
				desc = "Preview current hunk (Gitsigns)",
			},
			{
				"<leader>gb",
				"<Cmd>Gitsigns blame_line<CR>",
				desc = "blame line (Gitsigns)",
			},
		},
		opts = {
			signs = {
				add = { text = " " },
				change = { text = " " },
				delete = { text = " " },
				topdelete = { txet = "󱅁 " },
				changedelete = { text = "󰍷 " },
			},
		},
		config = function(_, opts)
			require("gitsigns").setup(opts)
		end,
	},
}
