--- Colors adapted from https://github.com/Mofiqul/vscode.nvim
local M = {}

function M.setup()
    local c = {
        vscFront      = '#D4D4D4',
        vscBack       = '#000000',
        vscBlue       = '#569CD6', 
        vscLightBlue  = '#9CDCFE', 
        vscGreen      = '#6A9955', 
        vscBlueGreen  = '#4EC9B0', 
        vscLightGreen = '#B5CEA8', 
        vscRed        = '#F44747', 
        vscOrange     = '#CE9178', 
        vscYellow     = '#DCDCAA', 
        vscPink       = '#C586C0', 
        vscGray       = '#808080', 
    }

    local highlights = {
        -- UI
        ["Normal"]             = { fg = c.vscFront, bg = 'NONE' },
        ["NormalNC"]           = { fg = c.vscFront, bg = 'NONE' },
        ["NormalFloat"]        = { fg = c.vscFront, bg = 'NONE' },
        ["SignColumn"]         = { bg = 'NONE' },
        ["LineNr"]             = { fg = c.vscGray, bg = 'NONE' },
        ["WinSeparator"]       = { fg = '#444444', bg = 'NONE' },

        -- Diagnostics
        ["DiagnosticError"]    = { fg = c.vscRed },
        ["DiagnosticWarn"]     = { fg = c.vscYellow },
        ["DiagnosticInfo"]     = { fg = c.vscBlue },
        ["DiagnosticHint"]     = { fg = c.vscBlue },
        ["DiagnosticUnderlineError"] = { fg = c.vscRed, underline = true },

        -- Tree-sitter
        ["@variable"]          = { fg = c.vscLightBlue }, 
        ["@variable.member"]   = { fg = c.vscLightBlue }, 
        ["@variable.parameter"]= { fg = c.vscLightBlue },
        ["@variable.import"]    = { fg = c.vscLightBlue }, 
        ["@module"]            = { fg = c.vscBlueGreen },
        ["@property"]          = { link = "Normal" },  -- ? 
        ["@function"]          = { fg = c.vscYellow },
        ["@function.call"]     = { fg = c.vscYellow },
        ["@function.builtin"]  = { fg = c.vscYellow },
        ["@attribute"]         = { fg = c.vscYellow }, 
        ["@keyword"]           = { fg = c.vscPink },
        ["@keyword.function"]  = { fg = c.vscBlue },
        ["@keyword.operator"]  = { fg = c.vscBlue },
        ["@boolean"]           = { fg = c.vscBlue },
        ["@constant"]          = { fg = c.vscBlue },
        ["@constant.builtin"]  = { fg = c.vscBlue }, 
        ["@variable.builtin"]  = { fg = c.vscBlue }, 
        ["@include"]           = { fg = c.vscPink }, 
        ["@exception"]         = { fg = c.vscPink },
        ["@constructor"]       = { fg = c.vscBlueGreen },
        ["@type"]              = { fg = c.vscBlueGreen },
        ["@type.builtin"]      = { fg = c.vscBlueGreen },  
        ["@structure"]         = { fg = c.vscBlueGreen },
        ["@string"]            = { fg = c.vscOrange },
        ["@string.escape"]     = { fg = c.vscYellow },
        ["@number"]            = { fg = c.vscLightGreen },
        ["@number.float"]      = { fg = c.vscLightGreen },
        ["@float"]             = { fg = c.vscLightGreen }, 
        ["@comment"]           = { fg = c.vscGreen },
        ["@operator"]          = { fg = c.vscFront },
        ["@punctuation.bracket"] = { fg = c.vscYellow }, 
        ["@punctuation.delimiter"] = { fg = c.vscFront }, 
        ["@punctuation"]       = { fg = c.vscFront },    
        ["@tag"]               = { fg = c.vscBlue },
        ["@tag.attribute"]     = { fg = c.vscLightBlue },
        ["@tag.delimiter"]     = { fg = c.vscGray },

        -- LSP semantic tokens
        ["@lsp.type.variable"]   = { fg = c.vscLightBlue },
        ["@lsp.type.parameter"]  = { fg = c.vscLightBlue },
        ["@lsp.type.function"]   = { fg = c.vscYellow },
        ["@lsp.type.method"]     = { fg = c.vscYellow },
        ["@lsp.type.type"]       = { fg = c.vscBlueGreen },
        ["@lsp.type.namespace"]  = { fg = c.vscBlueGreen },  
        ["@lsp.type.class"]      = { fg = c.vscBlueGreen },
        ["@lsp.type.property"]   = { fg = c.vscLightBlue },
        ["@lsp.type.member"]     = { fg = c.vscLightBlue },
        ["@lsp.type.selfParameter"] = { link = "@variable.builtin" }, 
        ["@lsp.type.clsParameter"]  = { link = "@variable.builtin" }, 
        ["@lsp.type.decorator"] = { link = "@attribute" },
        ["@lsp.mod.readonly"] = { link = "@constant" },
        ["@lsp.typemod.variable.readonly"] = { link = "@constant" },

        -- Python
        ["@module.python"]             = { link = "Normal" },
        ["@variable.python"]           = { link = "Normal" },
        ["@variable.member.python"]    = { link = "Normal" },
        ["@variable.import.python"]    = { link = "Normal" },
        ["@constant.python"]           = { link = "Normal" },
        ["@function.python"]           = { link = "Normal" },
        ["@function.call.python"]      = { link = "Normal" },
        ["@function.method.python"]    = { link = "Normal" },
        ["@function.method.call.python"] = { link = "Normal" },
        ["@constructor.python"]        = { link = "Normal" },
        ["@type.python"]               = { link = "Normal" },
        ["@type.definition.python"]    = { link = "Normal" },
        ["@keyword.operator.python"]  = { fg = c.vscBlue },
    }

    for group, colors in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, colors)
    end
end

return M
