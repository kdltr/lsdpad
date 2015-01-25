return function()
   local x = math.random(love.window.getWidth())
   local y = math.random(love.window.getHeight())
   local rmax = math.random(15)
   local mode = math.random(2) == 1 and "fill" or "line"
   local color = new_color()
   local r = 0

   local m = {}

   function m.update(dt)
      r = r + dt * 3

      if r >= rmax then
         r = rmax
         return true
      end

      return false
   end

   function m.draw()
      love.graphics.setColor(unpack(color))
      love.graphics.circle(mode, x, y, r)
   end

   return m
end
