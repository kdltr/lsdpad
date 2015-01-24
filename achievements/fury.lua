local m = {}

function m.init_client(ci)
   ci.fury = { timer = 0, input = false }
end

function m.char(ci, char)
   ci.fury.input = true
end

function m.server_update(ci, dt)
   if ci.fury.input then
      ci.fury.timer = ci.fury.timer + dt
      ci.fury.input = false
   else
      ci.fury.timer = 0
   end

   if ci.fury.timer >= 1 then
      ach("fury")
      m.activated = true
   end
end

function m.activate(box)
   if box then box_push "FURY!" end
end

return m
