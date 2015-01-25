local m = {}

local t = 0

function m.init_client(ci)
   ci.fury = { timer = 0, input = false }
end

function m.char(ci, char)
   ci.fury.input = true
end

function m.server_update(ci, dt)
   if ci.fury.input then
      ci.fury.timer = ci.fury.timer + dt
      ci.fury.input = false
   else
      ci.fury.timer = 0
   end

   if ci.fury.timer >= 1 then
      ach("fury")
      m.activated = true
   end
end

function m.activate(box)
   if box then box_push "FURY!" end
   m.activated = true
end

function m.update(dt)
   if not m.activated then return end
   t = t + dt * 6
   if t > 1000 then t = 0 end
end

function m.pre_draw()
   if not m.activated or t > 250 then return end
   local cx, cy = love.window.getWidth() / 2, love.window.getHeight() / 2
   love.graphics.setColor(math.min(t, 255), 0, 0, math.max(0, math.min(50, 250 - t)))
   local step = 2 * math.pi / 64.0
   for i = 0, 63 do
      local r = t + math.max(0, t - 160) * math.random() / 2
      love.graphics.polygon(
         'fill',
         cx, cy,
         cx + r * math.cos(i * step), cy + r * math.sin(i * step),
         cx + r * math.cos((i + 1) * step), cy + r * math.sin((i + 1) * step)
      )
   end
end

return m
