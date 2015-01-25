local count = 1
local p = 1
local t = 0
local m = {}

m.activated = false

local has_fired = false

function m.char(ci, c)
   if has_fired then return end
   if c:match("%u") then
      count = count + 1
      if p == ci.p - 1 then
         p = p + 1
         print(count, x)
      else
         count = 1
         p = ci.p
      end
   end

   if count == 5 then
      ach("yell")
      has_fired = true
      --m.activated = true
   end
end

function m.activate(box)
  if box then box_push('STOP YELLING') end
end

function m.server_update(ci, dt)
   if not has_fired then return end
   t = t + dt
   if t > math.random(15) then
      t = 0
      if #s == 0 then return end
      local i = math.random(#s)
      s[i][1] = string.char(math.random(96) + 30)
      relay(string.format('replace %d %s\n', i, s[i][1]))
   end
end

return m
