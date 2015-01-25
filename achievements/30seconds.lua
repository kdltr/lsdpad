local clock = 0
local m = {}

local function reset()
   clock = 0
end

function m.load()
   m.activated = true -- unactivate in ach
end

function m.server_update(ci, dt)
   clock = clock + dt
   print(clock)

   if clock >= 30 then
      ach("30seconds")
      m.activated = true
   end
end

m.pos = reset
m.dir = reset
m.newline = reset
m.delete = reset
m.backspace = reset
m.char = reset

function m.activate(box)
   if box then box_push "Are you still there?" end
end

return m
