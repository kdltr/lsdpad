local clock = 0
local draw_cursor = false

local m = {}

function m.ach()
   m.activated = true
   ach('ach')
end

function m.load()
   m.activated = true
end

function m.activate(box)
   m.activated = false
   if box then box_push('First achievement!') end
   music.playloop(1)
end

function m.update(dt)
   if m.activated then return end

   clock = clock + dt
   if clock >= 0.5 then
      draw_cursor = not draw_cursor
      clock = 0
   end
end

function m.pre_draw()
   if m.activated then return end

   -- cursor
   if draw_cursor then
      love.graphics.setColor(180, 180, 180)
      love.graphics.rectangle("fill", cursor[1] * fontwidth, cursor[2] * fontheight, fontwidth, fontheight)
   end

   -- border
   love.graphics.setColor(220, 220, 220)
   love.graphics.setLineStyle("rough")
   love.graphics.setLineWidth(1)
   love.graphics.rectangle("line", fontwidth, fontheight, cols * fontwidth, #s * fontheight)
end

return m
