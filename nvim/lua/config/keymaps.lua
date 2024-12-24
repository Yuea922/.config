local keymap = vim.keymap.set

-- Copy
keymap("n", "Y", "y$")
-- keymap("v", "Y", '"+y')

-- Search
keymap("", "<leader><cr>", ":nohlsearch<cr>", { desc = "toggle highlight search" })
keymap("", "-", "N", { desc = "prev search" })
keymap("", "=", "n", { desc = "next search" })

-- Indentation
keymap("n", "<", "<<", { desc = "indentation left" })
keymap("n", ">", ">>", { desc = "indentation right" })

-- Folding
keymap("", "<leader>o", "za", { silent = true, desc = "folding" })

-- Find and replace
keymap("n", "\\s", ":%s//g<left><left>", { desc = "replace global" })

-- Delete find pair
-- keymap("n", "dy", "d%")

-- Adjacent duplicate words
-- keymap("n", "<leader>dw", "/\\(\\<\\w\\+\\>\\)\\_s*\\1")

-- Cursor movement
--     ^
--     k
-- < h   l >
--     j
--     v
keymap("n", "\\v", "v$h", { silent = true, desc = "visual go to the end of the line" })
keymap("", "K", "5k", { silent = true })
keymap("", "J", "5j", { silent = true })
keymap("", "N", "0", { silent = true, desc = "go to the start of the line" })
keymap("", "M", "$", { silent = true, desc = "go to the end of the line" })
keymap("", "W", "5w", { desc = "inline navigation backward" })
keymap("", "B", "5b", { desc = "inline navigation forward" })
-- Ctrl + K or J will move up/down the view port without moving the cursor
keymap("", "<C-K>", "5<C-y>", { desc = "move up the view port without moving the cursor" })
keymap("", "<C-J>", "5<C-e>", { desc = "move down the view port without moving the cursor" })

-- Insert mode
keymap("i", "<C-a>", "<esc>A", { desc = "go to the end of the line in insert mode" })
keymap("i", "<C-p>", "<esc>o", { desc = "create a new line and go to the start in insert mode" })

-- Commond mode
keymap("c", "<C-a>", "<Home>")
keymap("c", "<C-e>", "<End>")
keymap("c", "<C-k>", "<Up>")
keymap("c", "<C-j>", "<Down>")
keymap("c", "<C-h>", "<Left>")
keymap("c", "<C-l>", "<Right>")
keymap("c", "<M-h>", "<S-Left>")
keymap("c", "<M-l>", "<S-Right>")

-- ===
-- === Window management
-- ===
-- Use <space> + new arrow keys for moving the cursor around windows
keymap("", "<leader>w", "<C-w>w")
keymap("", "<leader>h", "<C-w>h")
keymap("", "<leader>j", "<C-w>j")
keymap("", "<leader>k", "<C-w>k")
keymap("", "<leader>l", "<C-w>l")
keymap("", "qf", "<C-w>o")
-- Resize splits with arrow keys
keymap("", "<leader><up>", ":res +5<cr>")
keymap("", "<leader><down>", ":res -5<cr>")
keymap("", "<leader><left>", ":vertical resize-5<cr>")
keymap("", "<leader><right>", ":vertical resize+5<cr>")
-- split the screens to up (horizontal), down (horizontal), left (vertical), right (vertical)
keymap("", "sk", ":set nosplitbelow<cr>:split<cr>:set splitbelow<cr>")
keymap("", "sj", ":set splitbelow<cr>:split<cr>")
keymap("", "sh", ":set nosplitright<cr>:vsplit<cr>:set splitright<cr>")
keymap("", "sl", ":set splitright<cr>:vsplit<cr>")
-- Place the two screens up and down
keymap("", "su", "<C-w>t<C-w>K")
-- Place the two screens side by side
keymap("", "sv", "<C-w>t<C-w>H")
-- Rotate screens
keymap("", "srk", "<C-w>b<C-w>K")
keymap("", "srv", "<C-w>b<C-w>H")
-- Press <SPACE> + q to close the window below the current window
-- keymap("", "<leader>q", "<C-w>j:q<cr>")

-- ===
-- === Tab management
-- ===
-- Create a new tab with tu
keymap("", "tu", ":tabe<cr>", { desc = "create a new tab" })
keymap("", "tU", ":tab split<cr>", { desc = "create a new tab same as current" })
-- Move around tabs with tj and tk
keymap("", "tj", ":-tabnext<cr>", { desc = "move around the tab on left" })
keymap("", "tk", ":+tabnext<cr>", { desc = "move around the tab on right" })
-- Move the tabs with tmn and tmi
keymap("", "tmj", ":-tabmove<cr>", { desc = "move tabs to left" })
keymap("", "tmk", ":+tabmove<cr>", { desc = "move tabs to right" })

-- Disable the default s key
keymap("n", "s", "<nop>", { desc = "disable default s key" })

-- Call figlet. It"s fun
--   __ _       _      _
--  / _(_) __ _| | ___| |_
-- | |_| |/ _` | |/ _ \ __|
-- |  _| | (_| | |  __/ |_
-- |_| |_|\__, |_|\___|\__|
--        |___/
keymap("", "tx", ":r !figlet", { desc = "call figlet" })
