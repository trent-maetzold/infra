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
		},
	},
}
