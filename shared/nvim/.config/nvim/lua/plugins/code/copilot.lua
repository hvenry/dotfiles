return {
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        gitcommit = true,
        ["*"] = true,
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)

      -- Shift-Tab: accept Copilot suggestion if visible, else send literal <S-Tab>
      vim.keymap.set("i", "<Tab>", function()
        local ok, suggestion = pcall(require, "copilot.suggestion")
        if ok and suggestion.is_visible() then
          suggestion.accept()
          return ""
        end
        return "<S-Tab>"
      end, { expr = true, silent = true, desc = "Copilot accept / Shift-Tab" })
    end,
  },
}
