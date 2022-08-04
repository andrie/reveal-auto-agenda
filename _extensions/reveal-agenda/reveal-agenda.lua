local text = pandoc.text
local headers = pandoc.List()

function scan_headers(el)
  if el.level == 1 then
    local htext = el:walk {
      Str = function(el)
        headers:insert(el.text)
      end
    }
  end
end


local newBlocks = pandoc.List()

function scan_blocks(blocks)
  
  for _,block in ipairs(blocks) do
    newBlocks:insert(block)
    if (block.t == "Header" and block.level == 1) then
      newBlocks:insert(pandoc.BulletList(headers))
    end
  end
  
  -- if we found a file name then return the modified list
  -- of blocks and ensure our dependency w/ css is injected
  -- if foundFilename then
  --   quarto.doc.addHtmlDependency({
  --     name = "reveal-agenda",
  --     version = "0.0.1",
  --     stylesheets = {"reveal-agenda.css"}
  --   })
  --   return newBlocks
  -- else
  --   return blocks
  -- end
  return newBlocks
end


return {{Header = scan_headers}, {Blocks = scan_blocks}}