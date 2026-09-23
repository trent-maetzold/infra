return {
	{
		"folke/sidekick.nvim",
		opts = {
			nes = { enabled = false },
			cli = {
				mux = {
					backend = "tmux",
					enabled = true,
				},
				tools = {
					mini = {
						cmd = { "mini" },
						url = "https://github.com/SWE-agent/mini-swe-agent",
					},
					omp = {
						cmd = { "omp" },
						is_proc = "\\<omp\\>",
						native_scroll = true,
						url = "https://github.com/can1357/oh-my-pi",
					},
				},
			},
		},
		keys = {
			{
				"<leader>am",
				function()
					require("sidekick.cli").toggle({ name = "mini", focus = true })
				end,
				desc = "Sidekick Toggle mini-swe-agent",
			},
			{
				"<leader>ao",
				function()
					require("sidekick.cli").toggle({ name = "omp", focus = true })
				end,
				desc = "Sidekick Toggle omp",
			},
			{
				"<leader>ai",
				function()
					require("sidekick.cli").toggle({ name = "pi", focus = true })
				end,
				desc = "Sidekick Toggle pi",
			},
		},
	},
}
