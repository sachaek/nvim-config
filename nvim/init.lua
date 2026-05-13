require("options")
require("keymaps")
require("plugins")

-- Colorscheme (tokyonight loaded early via lazy = false, priority = 1000)
vim.cmd.colorscheme("tokyonight-night")

require("lsp")
