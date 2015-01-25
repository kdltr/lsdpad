local m = {}

local parts = {}

function m.add(nature, x, y, size, data, speedx, speedy, life)
   table.insert(parts, {
      nat = nature,
      x = x,
      y = y,
      size = size,
      data = data,
      sx = speedx,
      sy = speedy,
      life = life,
   })
end

function m.update(dt)
   local vacuum = {}
   for k, part in ipairs(parts) do
      part.x = part.x + part.sx * dt
      part.y = part.y + part.sy * dt
      part.life = part.life - dt
      if part.life < 0 then
         table.insert(vacuum, 1, k)
      else
         if part.nat == 'letter' then
            part.sx = part.sx * 0.99
            part.sy = part.sy + 10
         elseif part.nat == 'explosion' then
            part.size = part.size * 0.96
         end
      end
   end
   for _, k in ipairs(vacuum) do
      table.remove(parts, k)
   end
end

function m.draw()
   for _, part in ipairs(parts) do
      if part.nat == 'letter' then
         love.graphics.setColor(0, 0, 0)
         love.graphics.print(part.data, part.x, part.y)
      elseif part.nat == 'explosion' then
         love.graphics.setColor(255, 0, 0, 192)
         love.graphics.circle('fill', part.x, part.y, part.size)
         love.graphics.setColor(255, 255, 0, 255)
         love.graphics.circle('fill', part.x, part.y, part.size / 3)
      end
   end
end

return m
