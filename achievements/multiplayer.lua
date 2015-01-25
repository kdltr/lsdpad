local players = 0

local m = {}

function m.init_client()
   players = players + 1

   if players == 2 then
      ach("multiplayer")
      m.activated = true
   end
end

function m.destroy_client()
   players = players - 1
end

function m.activate(box)
   if box then box_push "Yay! More players! \\o/" end
end

function m.update(dt)
end

function m.draw()
end

return m
