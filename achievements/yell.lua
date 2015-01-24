local count = 1
local x = 0

local m = {}

function m.char(ci, c)
   if c == c:upper() then
      count = count + 1
      if x == ci.x - 1 then
         x = x + 1
         print(count, x)
      else
         count = 1
         x = ci.x
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

return m
