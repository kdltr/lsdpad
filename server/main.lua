local socket = require("socket")

local server = socket.bind("0.0.0.0", "1234")

local ins = {server}

math.randomseed(os.time())

-- clients info
local ci = {}

s =
{
   {
      { 'a', 0, 0, 255 },
      { 'b', 0, 255, 0 },
      { ' ', 0, 255, 255 },
   },
   {
      { 'd', 0, 0, 255 },
      { 'e', 255, 0, 0 },
      { 'f', 255, 0, 255 },
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

function new_color()
   return { math.random(128) + 127, math.random(128) + 127, math.random(128) + 127 }
end

function init_client(client)
   ci[client] = { x = 1, y = 1, color = new_color()}
   ins[#ins+1] = client
   client:send(string.format("dump %d\n", #s));
   for _, line in ipairs(s) do
      client:send(table.concat(map(line, function (item)
         return string.format("%s %d %d %d ", item[1], item[2], item[3], item[4]);
      end
      )) .. "\n");
   end
end

local parsers = {}

function handle_msg(client, msg)
   print(client, "*" .. msg .. "*")
   for _, parser in pairs(parsers) do
      if parser(client, msg) then break end
   end
end

function parsers.dir(client, msg)
   local m = string.match(msg, "dir (%a+)")
   if not m then return false end
   local cinfo = ci[client]
   if m == "up" then
      if cinfo.y > 1 then
         cinfo.y = cinfo.y - 1;
         if cinfo.x > #s[cinfo.y] + 1 then
            cinfo.x = #s[cinfo.y] + 1
         end
      else
         cinfo.x = 1
      end
   elseif m == "left" then
      if cinfo.x == 1 and cinfo.y > 1 then
         cinfo.y = cinfo.y - 1
         cinfo.x = #s[cinfo.y] + 1
      elseif cinfo.x > 1 then
         cinfo.x = cinfo.x - 1
      end
   elseif m == "down" then
      if cinfo.y < #s then
         cinfo.y = cinfo.y + 1
         if cinfo.x > #s[cinfo.y] + 1 then
            cinfo.x = #s[cinfo.y] + 1
         end
      else
         cinfo.x = #s[cinfo.y] + 1
      end
   elseif m == "right" then
      if cinfo.x == #s[cinfo.y] + 1 then
         if cinfo.y < #s then
            cinfo.x = 1
            cinfo.y = cinfo.y + 1
         end
      else
         cinfo.x = cinfo.x + 1
      end
   end
   client:send(string.format("move %d %d\n", cinfo.x, cinfo.y))
   return true
end

function parsers.char(client, msg)
   local m = string.match(msg, "char (.+)")
   if not m then return false end
   local cinfo = ci[client]

   local x = cinfo.x
   local y = cinfo.y
   ins_char(
      x, y,
      { m, cinfo.color[1], cinfo.color[2], cinfo.color[3] }
   )

   relay(string.format(
      "ins %d %d %s %d %d %d\n",
      x, y, m,
      cinfo.color[1], cinfo.color[2], cinfo.color[3]
   ))

   for peer, peerinfo in pairs(ci) do
      if peerinfo.y == y and peerinfo.x >= x then
         peerinfo.x = peerinfo.x + 1
         if peerinfo.x > cols then
            peerinfo.x = 1
            peerinfo.y = peerinfo.y + 1
         end
         peer:send(
            string.format(
               "move %d %d\n",
               peerinfo.x, peerinfo.y
         ))
      end
   end

   return true
end

function relay(msg)
   for client, _ in pairs(ci) do
      client:send(msg)
   end
end
