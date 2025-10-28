return {
  "zbirenbaum/copilot.lua",
  keys = {
    {
      "<leader>at",
      function()
        if require("copilot.client").is_disabled() then
          require("copilot.command").enable()
        else
          require("copilot.command").disable()
        end
      end,
      desc = "Toggle (Copilot)",
    },
  },
  cmd = "Copilot",
  event = "BufReadPost",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      hide_during_completion = true,
      keymap = {
        accept = "<Tab>",
        next = "<M-w>",
        prev = "<M-q>",
      },
    },
    panel = { enabled = false },
    filetypes = {
      yaml = true,
      markdown = true,
      help = true,
      java = true,
      javascript = true,
      typescript = true,
    },
  },
}
