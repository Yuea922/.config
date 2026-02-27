return {
    {
        "amitds1997/remote-nvim.nvim",
        version = "*", -- Pin to GitHub releases
        dependencies = {
            "nvim-lua/plenary.nvim", -- For standard functions
            "MunifTanjim/nui.nvim", -- To build the plugin UI
            "nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
        },
        config = true,
        opts = {
            -- Configuration for devpod connections
            devpod = {
                binary = "devpod-cli", -- Binary to use for devpod
                docker_binary = "docker", -- Binary to use for docker-related commands
            },
            ssh_config = {
                scp_binary = "rsync", -- Binary to use for running SSH copy commands
            },
        },
    },
}
