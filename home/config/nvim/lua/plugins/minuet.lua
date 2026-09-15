return {
	{
		"milanglacier/minuet-ai.nvim",
		event = "InsertEnter",
		config = function()
			require("minuet").setup({
				provider = "openai_fim_compatible",
				n_completions = 1,
				context_window = 512,
				provider_options = {
					openai_fim_compatible = {
						api_key = "TERM", -- dummy env var; passes minuet's get_api_key non-nil check
						name = "llama-swap",
						end_point = "http://localhost:8080/v1/completions",
						model = "refact-1.6b-fim",
						optional = {
							max_tokens = 56,
							top_p = 0.9,
						},
						-- llama.cpp /v1/completions REJECTS the `suffix` param (server-common.cpp
						-- unsupported_params = {"best_of","suffix"}), so disable it and bake the
						-- FIM special tokens into `prompt`.
						template = {
							prompt = function(context_before_cursor, context_after_cursor, _)
								return "<fim_prefix>"
									.. context_before_cursor
									.. "<fim_suffix>"
									.. context_after_cursor
									.. "<fim_middle>"
							end,
							suffix = false,
						},
					},
				},
				request_timeout = 3,
			})
		end,
	},
}
