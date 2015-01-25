-- shared declarations
s = {}
cols = 60
modules = {}

-- utils
function map(table, fun)
   local r = {}
   for k, v in pairs(table) do
      r[k] = fun(v)
   end
   return r
end

-- char is { "l", r, v, b }
function ins_char(p, char)
   table.insert(s, p, char)
end

function del_char(p)
   table.remove(s, p)
end

function ins_line(p)
   table.insert(s, p, { 'nl', 0, 0, 0 })
end


-- loader
function modules_load()
   print("loading modules…")
   local dir = "achievements"
   local files = love.filesystem.getDirectoryItems(dir)

   for _, file in ipairs(files) do
      local filename = string.match(file, "^(.+)%.lua$")
      if filename then
         print("loading module:", file)
         local thunk, err = loadfile(dir .. "/" .. file)
         if not thunk then
            error(err)
         end
         modules[filename] = thunk()
      end
   end
end

function modules_call(which, ...)
   for _, module in pairs(modules) do
      local method = module[which]
      if method and not module.activated then method(...) end
   end
end


function love.load(args)
   modules_load()
   if args[2] == "server" then
      require("server.main", args)
   else
      require("client.main", args)
   end
end
