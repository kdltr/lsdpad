
local gs = require 'lib.generic_sequence'
local m = gs("pony", "pony", "Friendship is magic!")

local alpha = 0.0

function m.update(dt)
   if not m.activated then return end
   if alpha < 0.15 then alpha = alpha + dt * 0.005 end
end

function m.pre_draw()
   if not m.activated then return end
   r = math.pow(math.random(), 12)
   love.graphics.setColor(0, 0, 0, 255 * (alpha * r))
   love.graphics.rectangle('fill', 0, 0, love.window.getWidth(), love.window.getHeight())
end

return m
