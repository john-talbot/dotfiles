-- Insert-mode skeletons. Snippet syntax: $1 $2 are tab stops, $0 is the final
-- cursor position, ${1:text} is a placeholder, and \\ is a literal backslash.
local function snip(lhs, body)
  vim.keymap.set("i", lhs, function()
    vim.snippet.expand(body)
  end, { buffer = true, desc = "LaTeX snippet" })
end

snip(";eq", table.concat({
  "\\\\begin{equation}",
  "  $1 \\\\label{eq:$2}",
  "\\\\end{equation}",
  "$0",
}, "\n"))

snip(";al", table.concat({
  "\\\\begin{align}",
  "  $1 \\\\label{eq:$2}",
  "\\\\end{align}",
  "$0",
}, "\n"))

snip(";fig", table.concat({
  "\\\\begin{figure}[htbp]",
  "  \\\\centering",
  "  \\\\includegraphics[width=\\\\linewidth]{$1}",
  "  \\\\caption{$2}",
  "  \\\\label{fig:$3}",
  "\\\\end{figure}",
  "$0",
}, "\n"))
