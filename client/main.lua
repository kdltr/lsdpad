local socket = require("socket")

cursor = {1, 1}

-- Modules loading
modules = {}

local function modules_load()
   local dir = "achievements"
   local files = love.filesystem.getDirectoryItems(dir)

   for _, file in ipairs(files) do
      print("loading module:", file)
      modules[file] = loadfile(dir .. "/" .. file)()
   end
end

local function modules_call(which, ...)
   for _, module in pairs(modules) do
      local method = module[which]
      if method then method(...) end
   end
end

local function init_screen()
   local msg, err = server:receive("*l")
   local nlines = string.match(msg, "dump (%d+)")

   for i = 1, nlines do
      print("new line")
      s[i] = {}

      local msg, err = server:receive("*l")
      for char, r, v, b in string.gmatch(msg, "(.) (%d+) (%d+) (%d+) ") do
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
      ins_char(x, y, {letter, r, v, b})
   end
end

local function handle_client_msg(msg)
   for _, parser in pairs(parsers) do
      if parser(msg) then return end
   end
end

-- Love callbacks

-- boilerplate code
function love.load(args)
   local font = love.graphics.newFont("terminus.ttf", 20)
   love.graphics.setFont(font)

   fontwidth = font:getWidth("m")
   fontheight = font:getHeight("m")

   for k,v in pairs(args) do
      print(k,v)
   end

   server = socket.connect(args[3], tonumber(args[4]))
   if not server then
      print("failed to connect to server")
      love.event.quit()
   end
   init_screen()
   server:settimeout(0)

   modules_call("load", args)
end

function love.draw()
   -- background
   --love.graphics.setColor(255, 255, 255)
   --love.graphics.rectangle("fill", 0, 0, 800, 600)

   -- border
   --love.graphics.setColor(180, 180, 180)
   --love.graphics.setLineWidth(1)
   --love.graphics.rectangle("line", fontwidth, fontheight, 70 * fontwidth, 25 * fontheight)

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

   modules_call("draw") -- XXX should modules hide text? if not put that at the top of love.draw
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
   server:send("char " .. text)

   modules_call("textinput", text)
end

function love.keypressed(key)
   if key == "left"
      or key == "right"
      or key == "up"
      or key == "down"
      then
         server:send("dir " .. key)
   elseif key == "backspace" or key == "enter" then
      server:send(key)
   end

   modules_call("keypressed", key)
end

function love.mousepressed(x, y, button)
   if button == "l" then
      local c, l = math.floor(x / fontwidth), math.floor(y / fontheight)
      print(c, l)
      server:send("pos " .. c .. " " .. l)
   end

   modules_call("mousepressed", x, y, button)
end

modules_load()
love.load(arg)
