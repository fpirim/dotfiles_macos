-- Tab and Indentation Settings
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.relativenumber = true

-- Clipboard Configuration
if vim.fn.has("unnamedplus") == 1 then
  vim.opt.clipboard = "unnamedplus"
else
  vim.opt.clipboard = "unnamed"
end

-- Set Leader Keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
