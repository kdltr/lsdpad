side = "server"

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

function love.load(arg)
   modules_call("load", arg)
end

function init_client(client)
   ci[client] = { p = 1, color = new_color(), s = client }
   ins[#ins+1] = client
   client:send(string.format("dump %d\n", #s));
   client:send(table.concat(map(s, function (item)
      return string.format("%s %d %d %d\n", item[1], item[2], item[3], item[4]);
      end
   )));
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
   local p = cinfo.p
   if m == "end" then
      while p < #s + 1 and s[p][1] ~= 'nl' do
         p = p + 1
      end
   elseif m == "home" then
      while p > 1 and s[p - 1][1] ~= 'nl' do
         p = p - 1
      end
   elseif m == "up" then
      local np = p
      while np > 1 and s[np - 1][1] ~= 'nl' do
         np = np - 1
      end
      if np == 1 then return true end
      local offset = p - np
      np = np - 1
      while np > 1 and s[np - 1][1] ~= 'nl' do
         np = np - 1
      end
      while offset > 0 and s[np][1] ~= 'nl' do
         np = np + 1
         offset = offset - 1
      end
      p = np
   elseif m == "left" then
      if p > 1 then p = p - 1 end
   elseif m == "down" then
      local np = p
      while np > 1 and s[np - 1][1] ~= 'nl' do
         np = np - 1
      end
      local offset = p - np
      while np < #s + 1 and s[np][1] ~= 'nl' do
         np = np + 1
      end
      if np == #s + 1 then return true end
      np = np + 1
      while offset > 0 and np < #s + 1 and s[np][1] ~= 'nl' do
         np = np + 1
         offset = offset - 1
      end
      p = np
   elseif m == "right" then
      if p < #s + 1 then p = p + 1 end
   end
   cinfo.p = p
   client:send(string.format("move %d\n", cinfo.p))
   modules_call("dir", cinfo, m)
   return true
end

function parsers.pos(client, msg)
   local p = string.match(msg, "pos (%d+)")
   if not p then return false end
   local cinfo = ci[client]
   p = tonumber(p)
   if p < 1 then
      cinfo.p = 1
   elseif p > #s + 1 then
      cinfo.p = #s + 1
   else
      cinfo.p = p
   end
   client:send(string.format("move %d\n", cinfo.p))
   modules_call("pos", cinfo, cinfo.p)
   return true
end

function parsers.newline(client, msg)
   if msg ~= "return" then return false end
   local cinfo = ci[client]
   ins_line(cinfo.p)
   relay(string.format("insline %d\n", cinfo.p))
   for peer, peerinfo in pairs(ci) do
      if peerinfo.p >= cinfo.p then
         peerinfo.p = peerinfo.p + 1
         peer:send(string.format("move %d\n", peerinfo.p))
      end
   end
   modules_call("newline", cinfo)
   return true
end

function parsers.delete(client, msg)
   if msg ~= "delete" then return false end
   local cinfo = ci[client]
   parsers_do_del_char(cinfo.p)
   modules_call("delete", cinfo)
   return true
end

function parsers.backspace(client, msg)
   if msg ~= "backspace" then return false end
   local cinfo = ci[client]
   if cinfo.p == 1 then return true end
   parsers_do_del_char(cinfo.p - 1)
   modules_call("backspace", cinfo)
   return true
end

function parsers_do_del_char(p)
   local moves = {}
   for peer, peerinfo in pairs(ci) do
      if (peerinfo.p > p) then
         peerinfo.p = peerinfo.p - 1
         moves[peer] = string.format("move %d\n", peerinfo.p)
      end
   end
   del_char(p)
   for peer, msg in pairs(moves) do
      peer:send(msg)
   end
   relay(string.format("delete %d\n", p))
end

function parsers.char(client, msg)
   local m = string.match(msg, "char (.+)")
   if not m then return false end
   local cinfo = ci[client]

   ins_char(
      cinfo.p,
      { m, cinfo.color[1], cinfo.color[2], cinfo.color[3] }
   )

   relay(string.format(
      "ins %d %s %d %d %d\n",
      cinfo.p, m, cinfo.color[1], cinfo.color[2], cinfo.color[3]
   ))

   for peer, peerinfo in pairs(ci) do
      if peerinfo.p >= cinfo.p then
         peerinfo.p = peerinfo.p + 1
         peer:send(string.format("move %d\n", peerinfo.p))
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

love.load(arg)
