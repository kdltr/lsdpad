local socket = require("socket")

local server = socket.bind("0.0.0.0", "1234")

local ins = {server}

-- clients info
local ci = {}

s =
{
   {
      { 'a', 255, 255, 255 },
      { 'b', 255, 255, 255 },
      { ' ', 255, 255, 255 },
   },
   {
      { 'd', 255, 255, 255 },
      { 'e', 255, 255, 255 },
      { 'f', 255, 255, 255 },
   },
}

function love.update(dt)
   local toread, _, err = socket.select(ins, {}, 0.1)
   for _,client in ipairs(toread) do
      if client == server then
         init_client(server:accept())
      else
         local msg, err = client:receive("*l")
         if not msg then
            print("client closed:", err)
            for k,v in ipairs(ins) do
               if v == client then
                  table.remove(ins, k)
               end
            end
         else
            handle_msg(client, msg)
         end
      end
      print(client)
   end
end

function init_client(client)
   ci[client] = { x = 0, y = 0, color = { 0xff, 0xff, 0 }}
   ins[#ins+1] = client
   client:send(string.format("dump %d\n", #s));
   for _, line in ipairs(s) do
      client:send(table.concat(map(line, function (item)
         return string.format("%s %d %d %d ", item[1], item[2], item[3], item[4]);
      end
      )) .. "\n");
   end
end

function handle_msg(client, msg)
   print(client, msg)
end

