return function()
   local width = 10
   local height = 100
   local angle = math.random() * 2 * math.pi
   local factor = math.random(20) - 10
   local color = new_color()
   factor = factor == 0 and 1 or factor

   local m = {}

   function m.update(dt)
      angle = angle + dt / factor
   end

   function m.draw()
      local x = height + width / 2
      local y = love.window.getHeight() - height

      love.graphics.translate(width / 2, 0)
      love.graphics.rotate(angle)
      love.graphics.translate(- (width / 2), 0)

      love.graphics.setColor(unpack(color))
      love.graphics.rectangle("fill", 0, 0, width, height)
      love.graphics.rotate(-angle)
   end

   return m

end
