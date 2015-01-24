
local m = {}

function m.char(client, char)
   if char == string.upper(char) then
      m.activated = true
      ach('shift')
   end
end

function m.activate(box)
  if box then box_push('Shift!') end
end

return m
