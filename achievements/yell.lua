local count = 1
local p = 1
local t = 0
local m = {}

function m.char(ci, c)
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
      m.activated = true
      ach("yell")
   end
end

function m.activate(box)
  if box then box_push('STOP YELLING') end
end

function m.server_update(dt)
   if not m.activated then return end
   t = t + dt
   if t > 1 then
      t = 0
      local i = math.random(#s)
      s[i] = '*'
   end
end

return m
