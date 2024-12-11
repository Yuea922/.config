-- switch input method
-- vim.api.nvim_create_autocmd({ "InsertLeave" }, {
--     pattern = { "*" },
--     callback = function()
--         local input_status = tonumber(vim.fn.system("fcitx5-remote"))
--         if input_status == 2 then
--             vim.fn.system("fcitx5-remote -c")
--         end
--     end,
-- })

-- auto restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = { "*" },
    callback = function()
        if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
            vim.fn.setpos(".", vim.fn.getpos("'\""))
            vim.cmd("silent! foldopen")
        end
    end,
})

-- remove auto-comments
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = { "*" },
    callback = function()
        vim.opt.formatoptions:remove({ "c", "r", "o" })
    end,
})
