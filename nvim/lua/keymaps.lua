vim.g.mapleader = " "

local map = vim.keymap.set

map("n", "<Space>", "", { desc = "Leader" })
map({ "n", "v" }, "<Space>w", "<C-w>", { desc = "Window commands" })

-- Better navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Clear search highlighting
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search" })

-- Better indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half" })

-- Quick save
map({ "n", "x" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
