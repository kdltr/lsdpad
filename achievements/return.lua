
local m = {}

function m.newline()
   m.activated = true
   ach('return')
end

function m.activate(box)
  if box then box_push('New line!') end
end

return m
