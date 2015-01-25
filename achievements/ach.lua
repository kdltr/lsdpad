local clock = 0
local draw_cursor = false
local last_cursor = { 0, 0 }

local m = {}

function m.ach()
   m.activated = true
   modules["30seconds"].activated = false
   ach('ach')
end

function m.load()
   m.activated = false
end

function m.activate(box)
   m.activated = true
   if box then box_push('First achievement!') end
   music.playloop(1)
end

function m.update(dt)
   if not m.activated then return end

   if last_cursor[1] ~= cursor_xy[1] or
      last_cursor[2] ~= cursor_xy[2]
      then
         last_cursor[1] = cursor_xy[1]
         last_cursor[2] = cursor_xy[2]
         clock = 0
   else
      clock = clock + dt
      if clock <= 1 then
         draw_cursor = true
      elseif clock <= 1.3 then
         draw_cursor = false
      else
         clock = 0
      end
   end
end

function m.draw()
   if not m.activated then return end

   -- cursor
   if draw_cursor then
      love.graphics.setColor(180, 180, 180)
      love.graphics.rectangle("fill", cursor_xy[1] * fontwidth, cursor_xy[2] * fontheight, fontwidth, fontheight)
   end

   -- border
   love.graphics.setColor(220, 220, 220)
   love.graphics.setLineStyle("rough")
   love.graphics.setLineWidth(1)
   love.graphics.rectangle("line", 0, 0, cols * fontwidth, nb_lines * fontheight)
end

return m
