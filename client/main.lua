local socket = require("socket")


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


-- Love callbacks

function love.textinput(text)
end

function love.draw()
   for _, module in pairs(modules) do
      if module.draw then module.draw() end
   end

   for l, line in ipairs(s) do
      for c, spec in ipairs(line) do
         local char, r, v, b = unpack(spec)
         love.graphics.setColor(r, v, b)
         love.graphics.print(char, c * 10, l * 10)
      end
   end
end

function love.update(dt)
   for _, module in pairs(modules) do
      if module.update then module.update(dt) end
   end

   local msg, err = server:receive("*l")
   if msg then
      table.insert(msgs, msg)
   end
end

function love.keypressed(key)
   for _, module in pairs(modules) do
      if module.keypressed then module.keypressed(key) end
   end
end

function love.load(args)
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
end

function init_screen()
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

modules_load()
love.load(arg)
