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

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
    pattern = {
        "checkhealth",
        "gitsigns-blame",
        "grug-far",
        "help",
        "lspinfo",
        "notify",
        "qf",
        "startuptime",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
            vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
            })
        end)
    end,
})

-- clean up large LSP log file on startup
vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("cleanup_lsp_log", { clear = true }),
    callback = function()
        local log_path = vim.fn.stdpath("log") .. "/lsp.log"
        if vim.fn.filereadable(log_path) == 1 and vim.fn.getfsize(log_path) > 1024 * 1024 then
            vim.fn.writefile({}, log_path)
        end
    end,
    desc = "clean up large LSP log file on startup",
})
