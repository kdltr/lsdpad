local socket = require("socket")

-- Globals
-- text screen
s = {}
s[1] = {}

msgs = {}

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
   love.graphics.print(table.concat(msgs, "\n"), 30, 30)
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
   server:settimeout(0)
end

modules_load()
love.load(arg)
