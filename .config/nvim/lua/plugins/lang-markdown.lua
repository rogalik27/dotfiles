return {
    "OXY2DEV/markview.nvim",
    ft = "markdown",
    lazy = true,
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },
    config = function (_, _)
        -- Keep checkbox source text ("- [ ]" / "- [x]") as plain text instead
        -- of concealing it into an icon glyph, since that makes it awkward
        -- to edit (cursor lands on a single "icon" cell instead of on "[x]").
        require("markview").setup({
            markdown_inline = {
                checkboxes = {
                    enable = false,
                },
            },
            markdown = {
                list_items = {
                    enable = false,
                },
            },
        })

        -- NOTE: Fix for https://github.com/epwalsh/obsidian.nvim/issues/286
        vim.api.nvim_create_autocmd({"BufEnter"}, {
            pattern = "*.md",
            callback = function()
                vim.b.saved_conceallevel = vim.opt.conceallevel:get()
                vim.opt.conceallevel = 2
            end
        })

        vim.api.nvim_create_autocmd({"BufLeave"}, {
            pattern = "*.md",
            callback = function()
                if vim.b.saved_conceallevel ~= nil then
                    vim.opt.conceallevel = vim.b.saved_conceallevel
                end
            end
        })


    end
}
