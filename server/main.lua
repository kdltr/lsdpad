local socket = require("socket")

local server = socket.bind("0.0.0.0", "1234")

local ins = {server}

-- clients info
local ci = {}

s = {
   {
      { letter = 'a', r = 255, v = 255, b = 255 },
      { letter = 'b', r = 255, v = 255, b = 255 },
      { letter = 'c', r = 255, v = 255, b = 255 },
   },
   {
      { letter = 'd', r = 255, v = 255, b = 255 },
      { letter = 'e', r = 255, v = 255, b = 255 },
      { letter = 'f', r = 255, v = 255, b = 255 },
   },
}

function love.update(dt)
   local toread, _, err = socket.select(ins, {}, 0.1)
   for _,client in ipairs(toread) do
      if client == server then
<<<<<<< local
         local client = server:accept()
         client:settimeout(0)
         ins[#ins+1] = client
=======
         init_client(server:accept())
>>>>>>> other
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
         return string.format("%s %d %d %d ", item.letter, item.r, item.v, item.b);
      end
      )) .. "\n");
   end
end

function handle_msg(client, msg)
<<<<<<< local
   print(client, msg)
=======
   
>>>>>>> other
end
<<<<<<< local
=======


>>>>>>> other
