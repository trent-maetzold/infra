return {
	{
		"saghen/blink.cmp",
		opts = {
			completion = {
				ghost_text = { enabled = false },
				list = {
					selection = { preselect = false },
				},
			},
			fuzzy = {
				implementation = "lua",
			},
			keymap = {
				["<A-y>"] = {
					function(cmp)
						cmp.show({ providers = { "minuet" } })
					end,
				},
			},
			sources = {
				default = { "minuet" },
				providers = {
					minuet = {
						name = "minuet",
						module = "minuet.blink",
						async = true,
						timeout_ms = 3000,
						score_offset = 50,
					},
				},
			},
		},
	},
}
