local LazyUtil = require("lazy.core.util")

---@class util: LazyUtilCore
---@field inject util.inject
---@field lsp util.lsp
---@field plugin util.plugin
---@field root util.root
---@field telescope util.telescope
---@field ui util.ui
local M = {}

setmetatable(M, {
    __index = function(t, k)
        if LazyUtil[k] then
            return LazyUtil[k]
        end
        ---@diagnostic disable-next-line: no-unknown
        t[k] = require("util." .. k)
        return t[k]
    end,
})

---@param name string
function M.get_plugin(name)
    return require("lazy.core.config").spec.plugins[name]
end

---@param plugin string
function M.has(plugin)
    return M.get_plugin(plugin) ~= nil
end

---@param fn fun()
function M.on_very_lazy(fn)
    vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
            fn()
        end,
    })
end

---@param name string
function M.opts(name)
    -- local plugin = require('lazy.core.config').plugins[name]
    local plugin = M.get_plugin(name)
    if not plugin then
        return {}
    end
    local Plugin = require("lazy.core.plugin")
    return Plugin.values(plugin, "opts", false)
end

-- delay notifications till vim.notify was replaced or after 500ms
function M.lazy_notify()
    local notifs = {}
    local function temp(...)
        table.insert(notifs, vim.F.pack_len(...))
    end

    local orig = vim.notify
    vim.notify = temp

    local timer = vim.uv.new_timer()
    local check = assert(vim.uv.new_check())

    local replay = function()
        timer:stop()
        check:stop()
        if vim.notify == temp then
            vim.notify = orig -- put back the original notify if needed
        end
        vim.schedule(function()
            ---@diagnostic disable-next-line: no-unknown
            for _, notif in ipairs(notifs) do
                vim.notify(vim.F.unpack_len(notif))
            end
        end)
    end

    -- wait till vim.notify has been replaced
    check:start(function()
        if vim.notify ~= temp then
            replay()
        end
    end)
    -- or if it took more than 500ms, then something went wrong
    timer:start(500, 0, replay)
end

return M
