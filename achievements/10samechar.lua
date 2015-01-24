
local activated = false
local m = {}

function m.init_client(client)
   client.last_char = ''
   client.last_char_count = 0
end

function m.char(client, char)
   if activated then return end
   if char == client.last_char then
      client.last_char_count = client.last_char_count + 1
      if client.last_char_count == 10 then
         activated = true
         ach(client.s, '10samechar')
      end
   else
      client.last_char_count = 0
      client.last_char = char
   end
end

function m.activate(box)
  if box then box_push('10 times the same character!') end
end

return m
