return {
	{
		"folke/sidekick.nvim",
		opts = {
			cli = {
				tools = {
					mini = {
						cmd = { "mini" },
						url = "https://github.com/SWE-agent/mini-swe-agent",
					},
				},
			},
		},
		keys = {
			-- { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
			{
				"<leader>aa",
				function()
					require("sidekick.cli").toggle({ name = "mini", focus = true })
				end,
				desc = "Sidekick Toggle mini",
			},
		},
	},
}
