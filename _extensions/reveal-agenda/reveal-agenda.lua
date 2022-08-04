

-- for code blocks w/ filename create an enclosing div:
-- <div class="code-with-filename">
--   <div class="code-with-filename-file">
--     <pre>filename.py</pre>
--   </div>
--   <div class="sourceCode" id="cb1" data-filename="filename.py">
--     <pre></pre>
--   </div>
-- </div>


local text = pandoc.text

local headers = pandoc.List()

function get_header_text(el)
  local z = ""
  local htext = el:walk {
    Str = function(el)
      z = el.text
    end
  }
  return z
end

function scan_headers(el)
  if el.level == 1 then
    headers:insert(get_header_text(el))
  end
end


local newBlocks = pandoc.List()


function change_header_class(el)
  el.attr = pandoc.Attr("", {"agenda-slide"})
  quarto.utils.dump(el.attributes)
  return el
end

function scan_blocks(blocks)
  
  for _,block in ipairs(blocks) do
    if (block.t == "Header" and block.level == 1) then
      change_header_class(block)
      newBlocks:insert(block)

      -- insert the original header
      -- newBlocks:insert(
      --   pandoc.Header(
      --     1, block.text, pandoc.Attr("", {"agenda-slide"})
      --   )
      -- )

      -- modify the agenda items for active agenda item
      local mod_headers = pandoc.List()
      for i=1, #headers do 
        if (headers[i] == get_header_text(block)) then
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
    name = "reveal-agenda",
    version = "0.0.1",
    stylesheets = {"reveal-agenda.css"}
  })

  return newBlocks
end

return {{Header = scan_headers}, {Blocks = scan_blocks}}