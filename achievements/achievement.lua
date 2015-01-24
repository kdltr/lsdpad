
local m = {}

function m.ach()
   m.activated = true
   ach('ach')
end

function m.activate(box)
  if box then box_push('First achievement!') end
end

return m
