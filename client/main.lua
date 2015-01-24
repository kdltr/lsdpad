local socket = require("socket")

cursor = {1, 1}

-- Modules loading
modules = {}

local function init_screen()
   local msg, err = server:receive("*l")
   local nlines = string.match(msg, "dump (%d+)")

   for i = 1, nlines do
      print("new line: " .. i)
      s[i] = {}

      local msg, err = server:receive("*l")
      for char, r, v, b in string.gmatch(msg, "(.-) (%d+) (%d+) (%d+) ") do
         print(char, r, v, b)
         table.insert(s[i], {char, tonumber(r), tonumber(v), tonumber(b)})
      end
   end
end

local parsers = {}

function parsers.move(msg)
   local x, y = msg:match("^move (%d+) (%d+)$")
   if x then
      cursor = {x, y}
      return true
   end
end

function parsers.ins(msg)
   local x, y, letter, r, v, b = msg:match("^ins (%d+) (%d+) (.+) (%d+) (%d+) (%d+)$")
   if x then
      print(x, y, letter, r, v, b)
      ins_char(tonumber(x), tonumber(y), {letter, tonumber(r), tonumber(v), tonumber(b)})
      return true
   end
end

function parsers.delete(msg)
   local x, y = msg:match("^delete (%d+) (%d+)$")
   if x then
      del_char(tonumber(x), tonumber(y))
      return true
   end
end

function parsers.insline(msg)
   local x, y = msg:match("^insline (%d+) (%d+)$")
   if x then
      ins_line(tonumber(x), tonumber(y))
      return true
   end
end

function parsers.achievement(msg)
   local cmd = msg:match("^achievement (.+)$")
   local module = modules[cmd]

   if module then
      module.activate()
   end

   return true
end

local function handle_client_msg(msg)
   print(msg)
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
   local font = love.graphics.newFont("terminus.ttf", 20)
   love.graphics.setFont(font)
   love.keyboard.setKeyRepeat(true)

   fontwidth = font:getWidth("m")
   fontheight = font:getHeight("m")

   for k,v in pairs(args) do
      print(k,v)
   end

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
   love.graphics.setColor(255, 255, 255)
   love.graphics.rectangle("fill", 0, 0, love.window.getWidth(), love.window.getHeight())

   local d = (love.window.getWidth() - (cols * fontwidth)) / 2
   love.graphics.translate(d - fontwidth, d*0.8 - fontheight)

   modules_call("pre_draw")

   -- border
   love.graphics.setColor(220, 220, 220)
   love.graphics.setLineStyle("rough")
   love.graphics.setLineWidth(1)
   love.graphics.rectangle("line", fontwidth, fontheight, cols * fontwidth, #s * fontheight)

   -- cursor
   love.graphics.setColor(180, 180, 180)
   love.graphics.rectangle("fill", cursor[1] * fontwidth, cursor[2] * fontheight, fontwidth, fontheight)

   -- text buffer
   for l, line in ipairs(s) do
      for c, spec in ipairs(line) do
         local char, r, v, b = unpack(spec)
         love.graphics.setColor(r, v, b)
         love.graphics.print(char, c * fontwidth, l * fontheight)
      end
   end

   modules_call("post_draw")
end


-- events handling

function love.update(dt)
   local msg, err = server:receive("*l")
   if not msg then
      if err == "closed" then
         love.event.quit()
      end
   else
      handle_client_msg(msg)
   end

   modules_call("update", dt)
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
   if button == "l" then
      local margin = (love.window.getWidth() - (cols * fontwidth)) / 2
      local c, l = math.floor((x - margin) / fontwidth) + 1, math.floor((y - margin*0.8) / fontheight) + 1
      print(c, l)
      send("pos " .. c .. " " .. l)
   end

   modules_call("mousepressed", x, y, button)
end

modules_load()
love.load(arg)
