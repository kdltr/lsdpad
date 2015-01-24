
local m = {}

function m.init_client(client)
   client._10samechar_last = ''
   client._10samechar_count = 0
end

function m.char(client, char)
   if char == client._10samechar_last then
      client._10samechar_count = client._10samechar_count + 1
      if client._10samechar_count == 10 then
         m.activated = true
         ach('10samechar')
      end
   else
      client._10samechar_cound = 0
      client._10samechar_last = char
   end
end

function m.activate(box)
  if box then box_push('10 times the same character!') end
end

return m
