local m = {}

function m.char()
   m.activated = true
   ach('firstchar')
end

function m.activate(box)
   if box then box_push('Your first character!') end
end

return m
