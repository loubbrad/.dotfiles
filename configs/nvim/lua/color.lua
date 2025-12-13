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
        ["Normal"]             = { fg = c.vscFront, bg = c.vscBack },
        ["NormalNC"]           = { fg = c.vscFront, bg = c.vscBack },
        ["SignColumn"]         = { bg = c.vscBack },
        ["LineNr"]             = { fg = c.vscGray, bg = c.vscBack },
        ["WinSeparator"]       = { fg = '#444444', bg = c.vscBack },
        ["DiagnosticError"]    = { fg = c.vscRed },
        ["DiagnosticWarn"]     = { fg = c.vscYellow },
        ["DiagnosticInfo"]     = { fg = c.vscBlue },
        ["DiagnosticHint"]     = { fg = c.vscBlue },
        ["DiagnosticUnderlineError"] = { sp = c.vscRed, undercurl = true },
        ["@variable"]          = { fg = c.vscLightBlue }, 
        ["@variable.member"]   = { fg = c.vscLightBlue }, 
        ["@variable.parameter"]= { fg = c.vscLightBlue },
        ["@variable.import"]    = { fg = c.vscBlueGreen }, 
        ["@module"]            = { fg = c.vscBlueGreen }, 
        ["@property"]          = { fg = c.vscLightBlue },
        ["@function"]          = { fg = c.vscYellow },
        ["@function.call"]     = { fg = c.vscYellow },
        ["@function.builtin"]  = { fg = c.vscYellow },
        ["@attribute"]         = { fg = c.vscYellow }, 
        ["@keyword"]           = { fg = c.vscBlue },
        ["@keyword.function"]  = { fg = c.vscBlue },
        ["@keyword.operator"]  = { fg = c.vscBlue },
        ["@boolean"]           = { fg = c.vscBlue },
        ["@constant"]          = { fg = c.vscBlue },
        ["@constant.builtin"]  = { fg = c.vscBlue }, 
        ["@variable.builtin"]  = { fg = c.vscBlue }, 
        ["@keyword.return"]    = { fg = c.vscPink },
        ["@keyword.conditional"]= { fg = c.vscPink },
        ["@keyword.repeat"]    = { fg = c.vscPink },
        ["@keyword.import"]    = { fg = c.vscPink }, 
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
        ["@lsp.type.selfParameter"] = { link = "@variable.builtin" }, 
        ["@lsp.type.clsParameter"]  = { link = "@variable.builtin" }, 
        ["@lsp.type.decorator"] = { link = "@attribute" },
    }

    for group, colors in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, colors)
    end
end

return M
