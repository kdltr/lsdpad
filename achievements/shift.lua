
local m = {}

function m.char(client, char)
   if char:match("%u") then
      m.activated = true
      ach('shift')
   end
end

function m.activate(box)
   if box then box_push('Shift!') end
   m.activated = true
end

local t = 0
local txts = {}

function m.update(dt)
   t = t + dt
   for _, v in ipairs(txts) do
      v.x = v.x - dt * (10 + v.v * 50)
   end
   if t > 5 then
      local d = math.random(#s / 2)
      local txt = ''
      for i = d, math.min(#s, d + 20) do
         if s[i][1] == 'nl' then
            txt = txt .. " "
         else
            txt = txt .. s[i][1]
         end
      end
      table.insert(txts, { x = love.window.getWidth(), y = math.random() * love.window.getHeight(), v = math.random(), s = math.random(), txt = txt })
      t = 0
   end
end

function m.pre_draw()
   for _, v in ipairs(txts) do
      love.graphics.setColor(0, 0, 0, 10 + v.s * 20)
      local scale = 2 + v.s * 7
      love.graphics.print(v.txt, v.x, v.y - fontheight * scale / 2, 0, scale, scale)
   end
end

function m.post_draw()
end

return m
