
local gs = require 'lib.generic_sequence'
local m = gs("boom", "boom", "Destruction")

local achieved = false

function m.activate_callback(client, module)
   local x, y
   if not achieved then
      ach(module)
      achieved = true
   end
   map_s(function (ip, cx, cy)
      if ip == client.p - 1 then
         x, y = cx, cy
      end
   end)
   local expl = { client.p - 1 }
   map_s(function (ip, cx, cy, c)
      if not c then return end
      if ip ~= client.p - 1 then 
         q = math.max(0, 10 - math.abs(cx - x) / 2 - math.abs(cy - y)) / 10
         if c[1] ~= 'nl' and math.random() < q then
            table.insert(expl, ip)
         end
      end
   end)
   for _, ip in ipairs(expl) do
      s[ip][1] = ' '
   end
   relay(string.format('explode %s \n', table.concat(expl, ' ')))
   return false
end

return m
