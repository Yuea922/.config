local util = require("lspconfig.util")

return {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
    },
    root_dir = function(fname)
        return util.root_pattern(
            ".clangd",
            ".clang-tidy",
            ".clang-format",
            "compile_commands.json",
            "compile_flags.txt",
            "configure.ac", -- AutoTools
            "build/compile_commands.json"
        )(fname) or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
    end,
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
    },
}
