local Drop = require("lib.drop")

local drops = {}
local clock = 0

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
end

function m.update(dt)
   if not m.activated then return end

   clock = clock + dt
   if clock >= 1 then
      table.insert(drops, Drop())
   end

   for i, d in ipairs(drops) do
      local delete = d.update(dt)
   end
end

function m.pre_draw()
   for _, d in ipairs(drops) do
      d.draw()
   end
end

return m
