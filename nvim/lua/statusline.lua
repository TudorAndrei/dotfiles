local lualine = require 'lualine'
local pypath = vim.g.current_python_path

local config = {
    options = {
        theme = 'dracula',
        icons_enabled = true,
        component_separators = {'', ''},
        section_separators = {'', ''},
        disabled_filetypes = {}
   },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype', 'TESTST'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
        inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    extensions = {}
}
lualine.setup(config)
