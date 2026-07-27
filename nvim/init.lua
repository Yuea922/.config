if vim.fn.has("nvim-0.11.2") == 0 then
    vim.api.nvim_echo({
        { "This Neovim configuration requires Neovim >= 0.11.2\n", "ErrorMsg" },
        { "Press any key to exit", "MoreMsg" },
    }, true, {})
    vim.fn.getchar()
    vim.cmd([[quit]])
end

require("config.lazy")
require("config").setup()
