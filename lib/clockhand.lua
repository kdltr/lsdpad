return function()
   local width = 25
   local height = 300
   local angle = math.random() * 2 * math.pi
   local factor = math.random(10) - 5
   local color = new_color()
   color[4] = 60
   factor = factor == 0 and 1 or factor

   local m = {}

   function m.update(dt)
      angle = angle + dt / factor
   end

   function m.draw()
      local x = 3 * height / 4
      local y = love.window.getHeight() - 3 * height / 4

      love.graphics.translate(width / 2, 60)
      love.graphics.rotate(angle)
      love.graphics.translate(- (width / 2), -60)

      love.graphics.setColor(unpack(color))
      love.graphics.rectangle("fill", 0, 0, width, height)
      love.graphics.rotate(-angle)
   end

   return m

end
