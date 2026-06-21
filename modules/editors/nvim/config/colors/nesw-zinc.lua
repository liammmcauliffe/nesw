vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") then
    vim.cmd.syntax("reset")
end
vim.o.background = "dark"
vim.g.colors_name = "nesw-zinc"

local c = {
    bg = "#09090b",
    bg_soft = "#18181b",
    bg_muted = "#27272a",
    fg = "#fafafa",
    fg_soft = "#f4f4f5",
    fg_muted = "#e4e4e7",
    zinc_300 = "#d4d4d8",
    zinc_400 = "#a1a1aa",
    zinc_500 = "#71717a",
    zinc_600 = "#52525b",
    zinc_700 = "#3f3f46",
    red = "#f87171",
    green = "#6ee7a0",
    yellow = "#fbbf24",
    blue = "#60a5fa",
    purple = "#c084fc",
    cyan = "#5eead4",
}

local function hl(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalFloat", { fg = c.fg, bg = c.bg_soft })
hl("FloatBorder", { fg = c.zinc_600, bg = c.bg_soft })
hl("FloatTitle", { fg = c.fg_muted, bg = c.bg_soft, bold = true })
hl("Cursor", { fg = c.bg, bg = c.zinc_400 })
hl("CursorLine", { bg = c.bg_muted })
hl("CursorLineNr", { fg = c.fg_muted, bold = true })
hl("LineNr", { fg = c.zinc_600 })
hl("SignColumn", { fg = c.zinc_600, bg = c.bg })
hl("Visual", { bg = c.zinc_700, fg = c.fg_soft })
hl("Search", { fg = c.bg, bg = c.yellow })
hl("IncSearch", { fg = c.bg, bg = c.cyan })
hl("MatchParen", { bg = c.zinc_700, bold = true })
hl("StatusLine", { fg = c.zinc_400, bg = c.bg_soft })
hl("StatusLineNC", { fg = c.zinc_600, bg = c.bg })
hl("WinSeparator", { fg = c.zinc_700 })
hl("TabLine", { fg = c.zinc_500, bg = c.bg })
hl("TabLineFill", { bg = c.bg })
hl("TabLineSel", { fg = c.fg, bg = c.bg_soft, bold = true })
hl("Pmenu", { fg = c.fg, bg = c.bg_soft })
hl("PmenuSel", { fg = c.fg, bg = c.zinc_700 })
hl("PmenuSbar", { bg = c.bg_muted })
hl("PmenuThumb", { bg = c.zinc_600 })
hl("Directory", { fg = c.blue })
hl("Title", { fg = c.fg, bold = true })
hl("Comment", { fg = c.zinc_500, italic = true })
hl("Constant", { fg = c.cyan })
hl("String", { fg = c.green })
hl("Character", { fg = c.green })
hl("Number", { fg = c.yellow })
hl("Boolean", { fg = c.purple })
hl("Identifier", { fg = c.fg })
hl("Function", { fg = c.blue })
hl("Keyword", { fg = c.purple })
hl("Statement", { fg = c.purple })
hl("Type", { fg = c.cyan })
hl("Special", { fg = c.cyan })
hl("Underlined", { fg = c.blue, underline = true })
hl("Error", { fg = c.red, bg = c.bg })
hl("WarningMsg", { fg = c.yellow })
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn", { fg = c.yellow })
hl("DiagnosticInfo", { fg = c.blue })
hl("DiagnosticHint", { fg = c.cyan })
hl("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.blue })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.cyan })

hl("@comment", { link = "Comment" })
hl("@string", { link = "String" })
hl("@number", { link = "Number" })
hl("@boolean", { link = "Boolean" })
hl("@keyword", { link = "Keyword" })
hl("@function", { link = "Function" })
hl("@function.builtin", { fg = c.blue })
hl("@type", { link = "Type" })
hl("@type.builtin", { fg = c.cyan })
hl("@variable", { link = "Identifier" })
hl("@variable.member", { fg = c.fg_muted })
hl("@constant", { link = "Constant" })
hl("@constant.builtin", { fg = c.purple })
hl("@operator", { fg = c.zinc_400 })
hl("@punctuation", { fg = c.zinc_400 })
hl("@tag", { fg = c.blue })
hl("@markup.heading", { fg = c.fg, bold = true })
hl("@markup.link", { fg = c.blue, underline = true })
hl("@markup.strong", { bold = true })
hl("@markup.italic", { italic = true })

hl("MiniPickBorder", { fg = c.zinc_600, bg = c.bg })
hl("MiniPickBorderText", { fg = c.zinc_400, bg = c.bg })
hl("MiniPickNormal", { fg = c.fg, bg = c.bg })
hl("MiniPickPrompt", { fg = c.fg_soft, bg = c.bg, bold = true })
hl("MiniPickMatchCurrent", { fg = c.fg_muted, bold = true })
hl("MiniPickMatchRanges", { fg = c.zinc_500 })
hl("MiniPickIconDirectory", { fg = c.blue })
hl("MiniPickIconFile", { fg = c.zinc_400 })
hl("MiniPickPreviewRegion", { bg = c.bg_soft })
hl("MiniFilesBorder", { fg = c.zinc_600, bg = c.bg })
hl("MiniFilesTitle", { fg = c.fg_muted, bg = c.bg_soft, bold = true })
hl("MiniNotifyBorder", { fg = c.zinc_600, bg = c.bg_soft })
hl("MiniNotifyNormal", { fg = c.fg, bg = c.bg_soft })
hl("MiniCompletionActiveParameter", { fg = c.cyan, underline = true })
