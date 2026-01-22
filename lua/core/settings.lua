vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.incsearch = true

vim.g.mapleader = " "

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
