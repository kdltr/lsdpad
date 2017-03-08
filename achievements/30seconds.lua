local Clockhand = require("lib.clockhand")
local clock = 0
local m = {}

local function reset()
   clock = 0
end

function m.load()
   m.activated = true -- unactivate in ach
end

function m.server_update(ci, dt)
   clock = clock + dt

   if clock >= 30 then
      ach("30seconds")
      m.activated = true
   end
end

m.pos = reset
m.dir = reset
m.newline = reset
m.delete = reset
m.backspace = reset
m.char = reset

function m.activate(box)
   m.activated = true
   if box then box_push "Are you still there?" end
end


local hands = {}
for i = 1, 5 do
   table.insert(hands, Clockhand())
end

function m.update(dt)
   if not m.activated then return end
   for _, h in ipairs(hands) do
      h.update(dt)
   end
end

function m.pre_draw()
   if not m.activated then return end
   local x = 100
   local y = love.graphics.getHeight() - 100

   love.graphics.push()
   love.graphics.translate(x, y)

   for _, h in ipairs(hands) do
      love.graphics.push()
      h.draw()
      love.graphics.pop()
   end

   love.graphics.pop()
end

return m
