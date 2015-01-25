local width = 200
local height = 100

local clock = 0
local limit = 4.5
local showed = false
local queue = {}

function box_push(name)
   table.insert(queue, name)
end

local function movement()
   local x = love.window.getWidth() - width
   local y

   if clock < 1 then -- attack
      y = love.window.getHeight() - clock * height
   elseif clock >= 1 and clock <= limit - 1 then -- sustain
      y = love.window.getHeight() - height
   else -- decay
      y = love.window.getHeight() - height + (clock - (limit - 1)) * height
   end

   return x, y
end

return {

   update = function(dt)
      if showed then
         clock = clock + dt * 3
         if clock >= limit then
            showed = false
            table.remove(queue, 1)
         end
      else
         if #queue > 0 then
            showed = true
            clock = 0
         end
      end
   end;

   draw = function()
      for _,text in ipairs(queue) do
         if showed then
            local x, y = movement(clock)

            love.graphics.setColor(80, 80, 80)
            love.graphics.rectangle("fill", x, y, width, height)
            love.graphics.setColor(255, 255, 255)
            love.graphics.printf(queue[1], x+fontwidth, y+fontwidth, width - fontwidth * 2, "left"stie )
         end
      end
   end;

}
