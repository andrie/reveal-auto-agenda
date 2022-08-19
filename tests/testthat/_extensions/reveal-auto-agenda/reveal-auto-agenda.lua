
local dump = quarto.utils.dump
local stringify = pandoc.utils.stringify
local headers = pandoc.List()

local options_bullets = "bullet"
local options_heading = nil

-- permitted options include:
-- auto-agenda:
--   bullets: none | bullet | numbered
--   heading: none | heading
function read_meta(meta)
  local options = meta["auto-agenda"]
  -- options_bullets = "none"
  -- if options == nil then return meta end
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

function get_header_text(el)
  return el.content
end

function scan_headers(el)
  if el.level == 1 then
    headers:insert(get_header_text(el))
  end
end


function change_header_class(el)
  el.attr = pandoc.Attr("", {"agenda-slide"})
  return el
end

function identity(el)
  return el
end

function scan_blocks(blocks)
  local newBlocks = pandoc.List()
  local header_n = 0

  -- define agende bullet options
 
  local bullet_class = pandoc.BulletList
  if options_bullets ~= nil then
    if options_bullets == "none" then
    -- print(options_bullets)
    bullet_class = identity
    elseif options_bullets == "numbered" then
      bullet_class = pandoc.OrderedList
    end
  end
  
  for _, block in pairs(blocks) do
    if (block ~= nil and block.t == "Header" and block.level == 1) then
      header_n = header_n + 1
      change_header_class(block)
      newBlocks:insert(block)

      -- if defined in options, insert a heading
      if (options_heading ~= nil) then
        newBlocks:insert(pandoc.Para(options_heading))
      end

      -- modify the agenda items for active agenda item
      local mod_headers = pandoc.List()
      for i=1, #headers do 
        if (i == header_n) then
          mod_headers:insert(
            pandoc.Div(pandoc.Para(headers[i]), pandoc.Attr("", {"agenda-active"}))
          )
        else
          mod_headers:insert(pandoc.Para(headers[i]))
        end
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
    version = "0.0.1",
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