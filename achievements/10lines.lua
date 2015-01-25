local m = {}

local fun = function()
   if #s >= 20 then
      ach("10lines")
      m.activated = true
   end
end

m.newline = fun
m.char = fun

function m.activate(box)
   if box then box_push "Long file is long" end
end

return m
