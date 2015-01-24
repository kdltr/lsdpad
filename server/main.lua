local socket = require("socket")

local server = socket.bind("0.0.0.0", "1234")

local ins = {server}

local achs = {}

local parsers = {}

math.randomseed(os.time())

-- clients info
local ci = {}

function love.update(dt)
   for _,v in pairs(ci) do
      modules_call("server_update", v, dt)
   end

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
                  modules_call("destroy_client", ci[client])
                  table.remove(ins, k)
                  ci[client] = nil
               end
            end
         else
            handle_msg(client, msg)
         end
      end
      print(client)
   end

end

function color_diff(ref, value)
   local r1 = math.abs(ref - value)
   local r2 = math.abs((ref + 1) - value)
   return math.max(0, 0.66 - r1, 0.66 - r2) / 0.66
end

function new_color()
   local hue = math.random()
   local r = {
      color_diff(0, hue) * 192,
      color_diff(0.33, hue) * 192,
      color_diff(0.66, hue) * 192,
   }
   return r
end

function init_client(client)
   ci[client] = { x = 1, y = 1, color = new_color(), s = client }
   ins[#ins+1] = client
   client:send(string.format("dump %d\n", #s));
   for _, line in ipairs(s) do
      client:send(table.concat(map(line, function (item)
         return string.format("%s %d %d %d ", item[1], item[2], item[3], item[4]);
      end
      )) .. "\n");
   end
   client:settimeout(0)
   modules_call("init_client", ci[client])
   for _, lua_filename in ipairs(achs) do
      client:send(string.format("ach %s\n", lua_filename))
   end
end

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
   if m == "end" then
      cinfo.x = #s[cinfo.y] + 1
   elseif m == "home" then
      cinfo.x = 1
   elseif m == "up" then
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
   modules_call("dir", cinfo, m)
   return true
end

function parsers.pos(client, msg)
   local x, y = string.match(msg, "pos (%d+) (%d+)")
   if not x then return false end
   local cinfo = ci[client]
   x = tonumber(x)
   y = tonumber(y)
   if y > #s then
      cinfo.y = #s
   elseif y < 1 then
      cinfo.y = 1
   else
      cinfo.y = y
   end
   if x > #s[cinfo.y] + 1 then
      cinfo.x = #s[cinfo.y] + 1
   elseif x < 1 then
      cinfo.x = 1
   else
      cinfo.x = x
   end
   client:send(string.format("move %d %d\n", cinfo.x, cinfo.y))
   modules_call("pos", cinfo, x, y)
   return true
end

function parsers.newline(client, msg)
   if msg ~= "return" then return false end
   local cinfo = ci[client]
   ins_line(cinfo.x, cinfo.y)
   relay(string.format("insline %d %d\n", cinfo.x, cinfo.y))
   for peer, peerinfo in pairs(ci) do
      local do_move = false
      if peerinfo.y > cinfo.y then
         peerinfo.y = peerinfo.y + 1
         do_move= true
      elseif peerinfo.y == cinfo.y and peerinfo.x >= cinfo.x then
         peerinfo.y = peerinfo.y + 1
         peerinfo.x = peerinfo.x - cinfo.x + 1
         do_move = true
      end
      if do_move then
         peer:send(string.format("move %d %d\n", peerinfo.x, peerinfo.y))
      end
   end
   modules_call("newline", cinfo)
   return true
end

function parsers.delete(client, msg)
   if msg ~= "delete" then return false end
   local cinfo = ci[client]
   parsers_do_del_char(cinfo.x, cinfo.y)
   modules_call("delete", cinfo)
   return true
end

function parsers.backspace(client, msg)
   if msg ~= "backspace" then return false end
   local cinfo = ci[client]
   local x = cinfo.x - 1
   local y = cinfo.y
   if x == 0 then
      if y == 1 then return true end
      y = y - 1
      x = #s[y] + 1
   end
   parsers_do_del_char(x, y)
   modules_call("backspace", cinfo)
   return true
end

function parsers_do_del_char(x, y)
   local moves = {}
   if y == #s and x > #s[#s] then return true end
   local line_merge = x == #s[y] + 1
   for peer, peerinfo in pairs(ci) do
      local do_move = false
      print(line_merge, x, y, peerinfo.x, peerinfo.y)
      if line_merge then
         if peerinfo.y > y + 1 then
            peerinfo.y = peerinfo.y - 1
            do_move = true
         elseif peerinfo.y == y + 1 then
            peerinfo.x = peerinfo.x + #s[y]
            peerinfo.y = y
            do_move = true
         end
      elseif peerinfo.y == y and peerinfo.x > x then
         peerinfo.x = peerinfo.x - 1
         do_move = true
      end
      if do_move then
         moves[peer] = string.format("move %d %d\n", peerinfo.x, peerinfo.y)
      end
   end
   if del_char(x, y) then
      for peer, msg in pairs(moves) do
         peer:send(msg)
      end
      relay(string.format("delete %d %d\n", x, y))
   end
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

   modules_call("char", cinfo, m)
   return true
end

function relay(msg)
   for client, _ in pairs(ci) do
      client:send(msg)
   end
end

function ach(lua_filename)
   relay(string.format("ach box %s\n", lua_filename))
   table.insert(achs, lua_filename)
   modules_call("ach", lua_filename)
end

