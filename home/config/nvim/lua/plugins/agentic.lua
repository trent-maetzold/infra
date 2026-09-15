return {
  {
    "carlos-algms/agentic.nvim",

    opts = {
      provider = "pi-acp",

      windows = {
        position = "right",
        width = "40%",
        height = "30%",
        input = { height = 10 },
        todos = { display = true, max_height = 10 },
      },

      diff_preview = {
        enabled = true,
        layout = "split",
        center_on_navigate_hunks = true,
      },

      folding = {
        tool_calls = {
          enabled = true,
          threshold = 10,
          fold_on_error = false,
        },
      },
    },

    keys = {
      -- which-key group header for <leader>a
      { "<leader>a",  "", desc = "+ai", mode = { "n", "v" } },

      -- ── Toggle / Open ──
      {
        "<leader>aa",
        function() require("agentic").toggle() end,
        mode = { "n", "v" },
        desc = "Toggle Agentic Chat",
      },
      {
        "<leader>ac",
        function() require("agentic").toggle({ auto_add_to_context = false }) end,
        mode = { "n", "v" },
        desc = "Chat (no context add)",
      },

      -- ── Context: add files / selections / project ──
      {
        "<leader>ab",
        function() require("agentic").add_selection_or_file_to_context() end,
        mode = { "n", "v" },
        desc = "Add buffer/selection to context",
      },
      {
        "<leader>af",
        function() require("agentic").add_file() end,
        mode = { "n" },
        desc = "Add file to context",
      },
      {
        "<leader>aP",
        function()
          local root = vim.fs.root(0, ".git") or vim.uv.cwd()
          if root then
            require("agentic").add_files_to_context({ files = { root } })
          end
        end,
        mode = { "n" },
        desc = "Add project root to context",
      },

      -- ── Visual mode ──
      {
        "<leader>ae",
        function() require("agentic").add_selection() end,
        mode = { "v" },
        desc = "Add selection to context",
      },
      {
        "<leader>aS",
        function() require("agentic").add_selection() end,
        mode = { "x" },
        desc = "Add selection to context (select)",
      },

      -- ── Diagnostics ──
      { "<leader>aD", "", desc = "+diagnostics", mode = { "n" } },
      {
        "<leader>ad",
        function() require("agentic").add_current_line_diagnostics() end,
        mode = { "n" },
        desc = "Add line diagnostic",
      },
      {
        "<leader>aDD",
        function() require("agentic").add_buffer_diagnostics() end,
        mode = { "n" },
        desc = "Add buffer diagnostics",
      },

      -- ── Sessions ──
      { "<leader>as", "", desc = "+sessions", mode = { "n", "v" } },
      {
        "<leader>asn",
        function() require("agentic").new_session() end,
        mode = { "n", "v" },
        desc = "New session",
      },
      {
        "<leader>asN",
        function() require("agentic").new_session_with_provider() end,
        mode = { "n", "v" },
        desc = "New session (pick provider)",
      },
      {
        "<leader>asr",
        function() require("agentic").restore_session() end,
        mode = { "n", "v" },
        desc = "Restore session",
      },

      -- ── Provider / Model ──
      { "<leader>ap", "", desc = "+provider", mode = { "n", "v" } },
      {
        "<leader>apv",
        function() require("agentic").switch_provider() end,
        mode = { "n", "v" },
        desc = "Switch provider",
      },

      -- ── Controls ──
      {
        "<leader>ax",
        function() require("agentic").stop_generation() end,
        mode = { "n", "v" },
        desc = "Stop generation",
      },
      {
        "<leader>al",
        function() require("agentic").rotate_layout() end,
        mode = { "n", "v" },
        desc = "Rotate layout",
      },
    },

    --- @param opts agentic.PartialUserConfig
    config = function(_, opts)
      require("agentic").setup(opts)

      -- jk → <Esc> inside agentic widget buffers
      local agentic_bufs = {
        "agentic-chat",
        "agentic-input",
        "agentic-files",
        "agentic-code",
        "agentic-diagnostics",
        "agentic-todos",
      }

      vim.api.nvim_create_augroup("AgenticJK", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = "AgenticJK",
        pattern = agentic_bufs,
        callback = function(ev)
          vim.keymap.set("i", "jk", "<Esc>", { buffer = ev.buf, desc = "jk escape" })
        end,
      })
    end,
  },
}
