return {
  "goolord/alpha-nvim",
  dependencies = { "echasnovski/mini.icons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    local logo = [[
	  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
	  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
	  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
	  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
	  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
	  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝

                        [ hvenry ]
    ]]

    local vslogo = [[
    ██╗   ██╗███████╗ ██████╗ ██████╗ ██████╗ ███████╗
    ██║   ██║██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║   ██║███████╗██║     ██║   ██║██║  ██║█████╗  
    ╚██╗ ██╔╝╚════██║██║     ██║   ██║██║  ██║██╔══╝  
     ╚████╔╝ ███████║╚██████╗╚██████╔╝██████╔╝███████╗
      ╚═══╝  ╚══════╝ ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝

                        [ hvenry ]
    ]]
    dashboard.section.header.val = vim.split(logo, "\n")
    alpha.setup(dashboard.opts)
  end,
}
