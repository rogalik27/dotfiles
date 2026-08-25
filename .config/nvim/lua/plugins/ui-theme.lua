return {
    {
        "Mofiqul/dracula.nvim",
        opts = {
            italic_comment = true
        },
        config = function(opts, _)
            local theme = require("dracula")
            theme.setup(opts)
        end
    },
    { "ellisonleao/gruvbox.nvim",
        priority = 1000 ,
        opts = {
            transparent_mode = true
        },
        config = function(_, opts)
            local theme = require("gruvbox")
            theme.setup(opts)
        end
    },
    {
        "nyoom-engineering/oxocarbon.nvim",
        lazy = false
    },
    {
        "baliestri/aura-theme",
        lazy = false
    }
}
