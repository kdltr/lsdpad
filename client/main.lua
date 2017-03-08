side = "client"

require("lib.music")
local socket = require("socket")
local box = require("lib.box")
local parts = require("lib.parts")

local margin

cursor = 1
cursor_xy = {0, 0}
nb_lines = 1


local function init_screen()
   local msg, err = server:receive("*l")
   local n = string.match(msg, "dump (%d+)")

   for i = 1, n do
      local msg = server:receive("*l")
      local char, r, v, b = string.match(msg, "(.-) (%d+) (%d+) (%d+)")
      table.insert(s, {char, tonumber(r), tonumber(v), tonumber(b)})
   end
end

local parsers = {}

function sgn(x)
   if x < 0 then return -1
   elseif x > 0 then return 1
   else return 0
   end
end

function parsers.explode(msg)
   local expl = msg:match("^explode ([0-9 ]+)$")
   if not expl then return end
   local expl_p = {}
   for p in msg:gmatch("(%d+) ") do
      table.insert(expl_p, tonumber(p))
   end
   local cep, cex, cey = table.remove(expl_p, 1)
   map_s(function (ip, cx, cy, c)
      if cep == ip then
         cex, cey = cx, cy
         parts.add('explosion', (cx + 0.5) * fontwidth + margin, (cy + 0.5) * fontheight + margin, 120, nil, 0, -15, 5)
         s[ip][1] = ' '
      end
   end)
   map_s(function (ip, cx, cy, c)
      for v_, p in ipairs(expl_p) do
         if p == ip then
            parts.add(
               'letter', cx * fontwidth + margin, cy * fontheight + margin, 0, s[p][1],
               sgn(cx - cex) * (math.random() * 1000 + 200),
               sgn(cy - cey) * (math.random() * 1000 + 200),
               6)
            s[p][1] = ' '
         end
      end
   end)
   return true
end

function parsers.replace(msg)
   local p, c = msg:match("^replace (%d+) (.+)$")
   if p then
      s[tonumber(p)][1] = c
   end
end


function parsers.move(msg)
   local p = msg:match("^move (%d+)$")
   if p then
      cursor = tonumber(p)
      return true
   end
end

function parsers.ins(msg)
   local p, letter, r, v, b = msg:match("^ins (%d+) (.+) (%d+) (%d+) (%d+)$")
   if p then
      ins_char(tonumber(p), {letter, tonumber(r), tonumber(v), tonumber(b)})
      return true
   end
end

function parsers.delete(msg)
   local p = msg:match("^delete (%d+)$")
   if p then
      del_char(tonumber(p))
      return true
   end
end

function parsers.insline(msg)
   local p = msg:match("^insline (%d+)$")
   if p then
      ins_line(tonumber(p))
      return true
   end
end

function parsers.achievement(msg)
   local cmdbox = msg:match("^ach box (.+)$")
   local cmd = msg:match("^ach (.+)$")
   if not cmd and not cmdbox then return false end

   local box = false
   if cmdbox then
      cmd = cmdbox
      box = true
   end

   local module = modules[cmd]
   if module then
      module.activate(box)
   end

   return true
end

local function handle_client_msg(msg)
   for _, parser in pairs(parsers) do
      if parser(msg) then return end
   end
end

local function send(msg)
   server:send(msg .. "\n")
end

-- Love callbacks

-- boilerplate code
function love.load(args)
   local font = love.graphics.newFont("assets/terminus.ttf", 20)
   love.graphics.setFont(font)
   love.keyboard.setKeyRepeat(true)

   fontwidth = font:getWidth("m")
   fontheight = font:getHeight("m")

   love.graphics.setBackgroundColor(255, 255, 255)

   music.load()

   server = socket.connect(args[3], tonumber(args[4]))
   if not server then
      print("failed to connect to server")
      os.exit()
   end
   init_screen()
   server:settimeout(0)

   modules_call("load", args)
end

function love.draw()
   -- background
   love.graphics.clear(255,255,255)

   modules_call("pre_draw")

   love.graphics.translate(margin, margin)

   modules_call("draw")

   local x, y = 0, 0
   for ip, c in ipairs(s) do
      local char, r, v, b = unpack(c)
      if char == 'nl' then
         x = 0
         y = y + 1
      else
         love.graphics.setColor(r, v, b)
         love.graphics.print(char, x * fontwidth, y * fontheight)
         x = x + 1
         if x == cols then
            x = 0
            y = y + 1
         end
      end
   end

   love.graphics.translate(-margin, -margin)

   parts.draw()
   box.draw()

   modules_call("post_draw")
end


-- events handling

function love.update(dt)
   margin = (love.graphics.getWidth() - (cols * fontwidth)) / 2

   local msg, err = server:receive("*l")
   if not msg then
      if err == "closed" then
         love.event.quit()
      end
   else
      handle_client_msg(msg)
   end

   update_buffer_metadata()

   music.update(dt)
   box.update(dt)
   parts.update(dt)

   modules_call("update", dt)
end

function update_buffer_metadata()
   local x, y = 0, 0
   local ip = 1
   while ip <= #s do
      local char, r, v, b = unpack(s[ip])
      if ip == cursor then
         cursor_xy = {x, y}
      end
      if char == 'nl' then
         x = 0
         y = y + 1
      else
         x = x + 1
         if x == cols then
            x = 0
            y = y + 1
         end
      end
      ip = ip + 1
   end
   if ip == cursor then
      cursor_xy = {x, y}
   end

   nb_lines = y + 1
end

function love.textinput(text)
   send("char " .. text)

   modules_call("textinput", text)
end

function love.keypressed(key)
   if key == "left"
      or key == "right"
      or key == "up"
      or key == "down"
      or key == "home"
      or key == "end"
      then
         send("dir " .. key)
   elseif key == "backspace" or key == "return" or key == "delete" then
      send(key)
   end

   modules_call("keypressed", key)
end

function love.mousepressed(x, y, button)
--   if button == "l" then
--      local margin = (love.graphics.getWidth() - (cols * fontwidth)) / 2
--      local c, l = math.floor((x - margin) / fontwidth) + 1, math.floor((y - margin*0.8) / fontheight) + 1
--      print(c, l)
--      send("pos " .. c .. " " .. l)
--   end
--   if button == 1 then
--      local x, y = 0, 0
--      local ip = 1
--      while ip <= #s do
--         local char, r, v, b = unpack(s[ip])
--         if ip == cursor then
--            cursor_xy = {x, y}
--         end
--         if char == 'nl' then
--            x = 0
--            y = y + 1
--         else
--            x = x + 1
--            if x == cols then
--               x = 0
--               y = y + 1
--            end
--         end
--         ip = ip + 1
--      end
--      if ip == cursor then
--         cursor_xy = {x, y}
--      end
--
--      nb_lines = y + 1
--   end
   modules_call("mousepressed", x, y, button)
end

love.load(arg)
