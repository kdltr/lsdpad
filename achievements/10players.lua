local players = 0

local m = {}

function m.init_client()
   players = players + 1

   if players == 10 then
      ach("10players")
      m.activated = true
   end
end

function m.destroy_client()
   players = players - 1
end

function m.activate(box)
   if box then box_push "PARTY HARD !!" end
end

return m
