
local dump = quarto.utils.dump
local stringify = pandoc.utils.stringify
local text = pandoc.text
local headers = pandoc.List()

function get_header_text(el)
  return el.content
end

function scan_headers(el)
  if el.level == 1 then
    headers:insert(get_header_text(el))
  end
end


local newBlocks = pandoc.List()
local header_n = 0


function change_header_class(el)
  el.attr = pandoc.Attr("", {"agenda-slide"})
  return el
end

function scan_blocks(blocks)
  
  for _,block in ipairs(blocks) do
    if (block.t == "Header" and block.level == 1) then
      header_n = header_n + 1
      change_header_class(block)
      newBlocks:insert(block)

      -- modify the agenda items for active agenda item
      local mod_headers = pandoc.List()
      for i=1, #headers do 
        if (i == header_n) then
          mod_headers:insert(
            pandoc.Div(headers[i], pandoc.Attr("", {"agenda-active"}))
          )
        else
          mod_headers:insert(headers[i])
        end
      end

          
      -- insert the agenda items
      newBlocks:insert(
        pandoc.Div(
          pandoc.BulletList(mod_headers),
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

return {{Header = scan_headers}, {Blocks = scan_blocks}}