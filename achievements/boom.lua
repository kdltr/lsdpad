
local gs = require 'lib.generic_sequence'
local m = gs("boom", "boom", "Destruction")

function m.activate_callback(client)
   local x, y
   map_s(function (ip, cx, cy)
      if ip == client.p then
         x, y = cx, cy
      end
   end)
   local expl = {}
   map_s(function (ip, cx, cy, c)
      if not c then return end
      q = math.max(0, 8 - math.abs(cx - x) / 2 - math.abs(cy - y)) / 8
      if c[1] ~= 'nl' and math.random() < q then
         table.insert(expl, ip)
      end
   end)
   for _, ip in ipairs(expl) do
      s[ip] = ' '
   end
   relay(string.format('explode %s\n', table.concat(expl, ' ')))
end

return m
