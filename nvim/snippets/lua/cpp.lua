return {
    s(
        { trig = "main", name = "starter Template", dscr = "Standard starter template for c++" },
        fmt(
            [[
        int main(int argc, char* argv[]) {{
            {content}

            return 0;
        }}
        ]],
            { content = i(1) }
        )
    ),

    s(
        { trig = "ca", name = "Creation Comment", dscr = "Comment with creation data and author" },
        fmt(
            [[
        /**
         * @file {filename}
         *
         * @author qiziyi
         * @date {date}
         */
        ]],
            {
                filename = f(function()
                    return vim.fn.expand("%:t")
                end),
                date = f(function()
                    return os.date("%Y-%m-%d")
                end),
            }
        )
    ),
}
