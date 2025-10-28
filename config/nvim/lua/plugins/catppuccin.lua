return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    local present, catppuccin = pcall(require, "catppuccin")

    if not present then
      return
    end

    catppuccin.setup({
      flavour = "mocha",
      transparent_background = true
    })

    vim.cmd.colorscheme "catppuccin"
  end
}
