local Drop = require("lib.drop")

local drops = {}
local clock = 0

local sound = love.audio.newSource("assets/RubberJohnnyBubulle.wav")

local m = {}

local fun = function()
   if nb_lines() >= 20 then
      ach("20lines")
      m.activated = true
   end
end

m.newline = fun
m.char = fun

function m.activate(box)
   m.activated = true
   if box then box_push "Long file is long" end
   sound:play()
end

function m.update(dt)
   if not m.activated then return end

   clock = clock + dt

   if clock >= 43 then
      clock = 0
      sound:play()
   end

   table.insert(drops, Drop())

   local to_delete = {}
   for i, d in ipairs(drops) do
      local delete = d.update(dt)
      if delete then
         table.insert(to_delete, i)
      end
   end
   for _, i in ipairs(to_delete) do
      table.remove(drops, i)
   end
end

function m.pre_draw()
   for _, d in ipairs(drops) do
      d.draw()
   end
end

return m
