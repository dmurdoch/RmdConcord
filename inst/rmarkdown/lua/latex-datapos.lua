--[[
     A Pandoc 2 Lua filter to insert data-pos attributes as LaTeX \datapos macros
     Author: Duncan Murdoch
     License: Public domain
--]]

-- REQUIREMENTS: Load shared lua filter - see `shared.lua` for more details.
dofile(os.getenv 'RMARKDOWN_LUA_SHARED')

--[[
  About the requirement:
  * PANDOC_VERSION -> 2.1
]]
if (not pandocAvailable {2,1}) then
    io.stderr:write("[WARNING] (latex-datapos.lua) requires at least Pandoc 2.1. Lua Filter skipped.\n")
    return {}
end

-- START OF THE FILTER'S FUNCTIONS --

Span = function(span)
  local datapos = span.attributes['data-pos']
  if datapos then
    table.insert(span.content, pandoc.RawInline('tex', "\\datapos{" .. datapos .. "}"))
  end
  return span
end
