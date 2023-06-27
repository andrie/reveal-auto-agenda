
local stringify = pandoc.utils.stringify
local headers = pandoc.List()

local options_bullets = "bullet"
local options_heading = nil

-- permitted options include:
-- auto-agenda:
--   bullets: none | bullet | numbered
--   heading: none | heading
local function read_meta(meta)
  local options = meta["auto-agenda"]
  if options ~= nil then
    if options.bullets ~= nil then
      options_bullets = stringify(options.bullets)
    else
      options_bullets = "bullet"
    end
    if options.heading ~= nil then
      options_heading = options.heading
    end
  end
end

local function get_header_text(el)
  return el.content
end

local function scan_headers(el)
  if el.level == 1  then
    headers:insert(get_header_text(el))
  end
end

--@param el pandoc.Header
--@return pandoc.Header
local function change_header_class(el)
  el.attr.classes = {"agenda-slide"}
  return el
end

local function identity(el)
  return el
end

local function scan_blocks(blocks)
  local newBlocks = pandoc.List()
  local header_n = 0

  -- define agende bullet options
  local bullet_class = pandoc.BulletList
  if options_bullets ~= nil then
    if options_bullets == "none" then
    bullet_class = identity
    elseif options_bullets == "numbered" then
      bullet_class = pandoc.OrderedList
    end
  end

  for _, block in pairs(blocks) do
    if (block ~= nil and 
      block.t == "Header" and 
      block.level == 1 and 
      not block.attr.classes:includes("no-auto-agenda")
    ) then
      header_n = header_n + 1
      change_header_class(block)
      newBlocks:insert(block)

      -- if defined in options, insert a heading
      if (options_heading ~= nil) then
        newBlocks:insert(
          pandoc.Div(
            pandoc.Para(options_heading),
            pandoc.Attr("", {"agenda-heading"})
          )
        )
      end

      -- modify the agenda items for active agenda item
      local mod_headers = pandoc.List()
      local agenda_class = {}
      for i=1, #headers do
        if (i == header_n) then
          agenda_class = {"agenda-active"}
        elseif (i < header_n) then
          agenda_class = {"agenda-inactive", "agenda-pre-active"}
        elseif (i > header_n) then
          agenda_class = {"agenda-inactive", "agenda-post-active"}
        end
        mod_headers:insert(
          pandoc.Div(pandoc.Para(headers[i]), pandoc.Attr("", agenda_class))
        )
      end
          
      -- insert the agenda items
      newBlocks:insert(
        pandoc.Div(
          bullet_class(mod_headers),
          pandoc.Attr("", {"agenda"})
        )
      )
    else
      newBlocks:insert(block)
    end
  end
  
  -- inject the CSS dependency
  quarto.doc.addHtmlDependency({
    name = "reveal-auto-agenda",
    version = "0.0.3",
    stylesheets = {"reveal-auto-agenda.css"}
  })

  return newBlocks
end

if (quarto.doc.isFormat("revealjs")) then
  return {
    {Meta = read_meta}, 
    {Header = scan_headers}, 
    {Blocks = scan_blocks}
  }
end
