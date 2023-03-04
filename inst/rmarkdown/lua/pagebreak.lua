--[[
pagebreak – convert raw LaTeX page breaks to other formats
 in commonmark.

This is closely based on pagebreak.lua from the rmarkdown package.

Copyright © 2017-2019 Benct Philip Jonsson, Albert Krewinkel
Copyright © 2019-2021 Christophe Dervieux, Romain Lesur, Atsushi Yasumoto
Copyright © 2022 Duncan Murdoch

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]

-- REQUIREMENTS: Load shared lua filter - see `shared.lua` for more details.
dofile(os.getenv 'RMARKDOWN_LUA_SHARED')

--[[
  About the requirement:
  * PANDOC_VERSION -> 2.1
  * pandoc.utils -> 2.1
]]
if (not pandocAvailable {2,1}) then
  io.stderr:write("[WARNING] (pagebreak.lua) requires at least Pandoc 2.1. Lua Filter skipped.\n")
  return {}
end

-- START OF THE FILTER'S FUNCTIONS --

local stringify_orig = (require 'pandoc.utils').stringify

local function stringify(x)
  return type(x) == 'string' and x or stringify_orig(x)
end

--- configs – these are populated in the Meta filter.
local pagebreak = {
  epub = '<p style="page-break-after: always;"> </p>',
  html = '<div style="page-break-after: always;"></div>',
  latex = '\\newpage{}',
  ooxml = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>',
  odt = '<text:p text:style-name="Pagebreak"/>',
  context = '\\page'
}

local function pagebreaks_from_config (meta)
  local html_class =
    (meta.newpage_html_class and stringify(meta.newpage_html_class))
    or os.getenv 'PANDOC_NEWPAGE_HTML_CLASS'
  if html_class and html_class ~= '' then
    pagebreak.html = string.format('<div class="%s"></div>', html_class)
  end

  local odt_style =
    (meta.newpage_odt_style and stringify(meta.newpage_odt_style))
    or os.getenv 'PANDOC_NEWPAGE_ODT_STYLE'
  if odt_style and odt_style ~= '' then
    pagebreak.odt = string.format('<text:p text:style-name="%s"/>', odt_style)
  end
end

--- Return a block element causing a page break in the given format.
local function newpage(format)
  if format == 'docx' then
    return pandoc.RawBlock('openxml', pagebreak.ooxml)
  elseif format:match 'latex' then
    return pandoc.RawBlock('tex', pagebreak.latex)
  elseif format:match 'odt' then
    return pandoc.RawBlock('opendocument', pagebreak.odt)
  elseif format:match 'html.*' then
    return pandoc.RawBlock('html', pagebreak.html)
  elseif format:match 'epub' then
    return pandoc.RawBlock('html', pagebreak.epub)
  elseif format:match 'context' then
    return pandoc.RawBlock('context', pagebreak.context)
  else
    -- fall back to insert a form feed character
    return pandoc.Para{pandoc.Str '\f'}
  end
end

-- Turning paragraphs which contain nothing but \pagebreak
-- or \newpage in commonmark_x+sourcepos output.

function Para (el)
  if #el.content == 2 and
     el.content[1].content == pandoc.Span('\\').content and
     (el.content[2].content == pandoc.Span('pagebreak').content or
      el.content[2].content == pandoc.Span('newpage').content) then
    return newpage(FORMAT)
  end
end

return {
  {Meta = pagebreaks_from_config},
  {RawBlock = RawBlock, Para = Para}
}
