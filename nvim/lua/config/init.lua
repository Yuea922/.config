_G.Util = require("util")

---@class NeovimConfig
local M = {
    -- colorscheme can be a string like `catppuccin` or a function that will load the colorscheme
    ---@type string|fun()
    colorscheme = function()
        -- require("tokyonight").load()
        vim.cmd.colorscheme("edge")
    end,
    -- icons used by other plugins
    -- stylua: ignore
    icons = {
        misc = {
            dots = "󰇘",
        },
        dap = {
            Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
            Breakpoint          = " ",
            BreakpointCondition = " ",
            BreakpointRejected  = { " ", "DiagnosticError" },
            LogPoint            = ".>",
        },
        diagnostics = {
            Error = " ",
            Warn  = " ",
            Hint  = " ",
            Info  = " ",
        },
        git = {
            added    = " ",
            modified = " ",
            removed  = " ",
        },
        kinds = {
            Array         = " ",
            Boolean       = "󰨙 ",
            Class         = " ",
            Codeium       = "󰘦 ",
            Color         = " ",
            Control       = " ",
            Collapsed     = " ",
            Constant      = "󰏿 ",
            Constructor   = " ",
            Copilot       = " ",
            Enum          = " ",
            EnumMember    = " ",
            Event         = " ",
            Field         = " ",
            File          = " ",
            Folder        = " ",
            Function      = "󰊕 ",
            Interface     = " ",
            Key           = " ",
            Keyword       = " ",
            Method        = "󰊕 ",
            Module        = " ",
            Namespace     = "󰦮 ",
            Null          = " ",
            Number        = "󰎠 ",
            Object        = " ",
            Operator      = " ",
            Package       = " ",
            Property      = " ",
            Reference     = " ",
            Snippet       = " ",
            String        = " ",
            Struct        = "󰆼 ",
            TabNine       = "󰏚 ",
            Text          = " ",
            TypeParameter = " ",
            Unit          = " ",
            Value         = " ",
            Variable      = "󰀫 ",
        },
        blink = {
            LSP      = "🔧",
            Snippets = "📝",
            Buffer   = "📄",
            Path     = "🗂️",
            Codeium  = "🤖",
        }
    },
    ---@type table<string, string[]|boolean>?
    kind_filter = {
        default = {
            "Class",
            "Constructor",
            "Enum",
            "Field",
            "Function",
            "Interface",
            "Method",
            "Module",
            "Namespace",
            "Package",
            "Property",
            "Struct",
            "Trait",
        },
        markdown = false,
        help = false,
        -- you can specify a different filter for each filetype
        lua = {
            "Class",
            "Constructor",
            "Enum",
            "Field",
            "Function",
            "Interface",
            "Method",
            "Module",
            "Namespace",
            -- "Package", -- remove package since luals uses it for control flow structures
            "Property",
            "Struct",
            "Trait",
        },
    },
}

---@param buf? number
---@return string[]?
function M.get_kind_filter(buf)
    buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
    local ft = vim.bo[buf].filetype
    if M.kind_filter == false then
        return
    end
    if M.kind_filter[ft] == false then
        return
    end
    ---@diagnostic disable-next-line: return-type-mismatch
    return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

function M.setup()
    -- autocmds can be loaded lazily when not opening a file
    local lazy_autocmds = vim.fn.argc(-1) == 0
    if not lazy_autocmds then
        M.load("autocmds")
    end

    local group = vim.api.nvim_create_augroup("LazyVim", { clear = true })
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "VeryLazy",
        callback = function()
            if lazy_autocmds then
                M.load("autocmds")
            end
            M.load("keymaps")
            M.load("usercmds")

            Util.root.setup()
        end,
    })
    vim.cmd.colorscheme("edge")
end

---@param name "autocmds" | "options" | "keymaps" | "usercmds"
function M.load(name)
    require("config." .. name)
    if vim.bo.filetype == "lazy" then
        -- HACK: LazyVim may have overwritten options of the Lazy ui, so reset this here
        vim.cmd([[do VimResized]])
    end
    local pattern = "LazyVim" .. name:sub(1, 1):upper() .. name:sub(2)
    vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end

function M.init()
    -- delay notifications till vim.notify was replaced or after 500ms
    require("util").lazy_notify()

    -- load options here, before lazy init while sourcing plugin modules
    -- this is needed to make sure options will be correctly applied
    -- after installing missing plugins
    require("util.plugin").lazy_file()
    require("config.options")
end

return M
