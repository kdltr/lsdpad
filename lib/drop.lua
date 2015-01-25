return function()
   local x = math.random(love.window.getWidth())
   local y = math.random(love.window.getHeight())
   local rmax = math.random(30)
   local color = new_color()
   local r = 0

   local m = {}

   function m.update(dt)
      r = r + dt

      if r >= rmax then
         r = rmax
         return true
      end

      return false
   end

   function m.draw()
      print("drawing drop")
      love.graphics.setColor(unpack(color))
      love.graphics.circle("line", x, y, r)
   end

   return m
end
