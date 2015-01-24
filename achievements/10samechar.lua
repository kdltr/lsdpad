
local activated = false
local m = {}

function m.init_client(client)
   client.last_chars = {'', '', '', '', '', '', '', '', '', ''}
end

function m.char(client, char)
   if activated then return end
   table.insert(client.last_chars, char)
   table.remove(client.last_chars, 1)
   print(table.concat(client.last_chars))
   local c = false
   local all_same = true
   for _, v in ipairs(client.last_chars) do
      if not c then
         c = v
      else
         if c ~= v then
            all_same = false
            break
         end
      end
   end
   if all_same then
      activated = true
      ach(client.s, '10samechar')
   end
end

function m.activate()
   box_push('10 times the same character!')
end

return m
