-- shared declarations
s = {{}}
cols = 78

-- utils
function map(table, fun)
   local r = {}
   for k, v in pairs(table) do
      r[k] = fun(v)
   end
   return r
end

-- char is { "l", r, v, b }
function ins_char(x, y, char)
   table.insert(s[y], x, char)
   local cy = y
   while #s[cy] >= cols do
      if #s[cy] == cols then
         table.insert(s, cy + 1, {})
         break
      end
      table.insert(s[cy + 1], 1, table.remove(s[cy]))
      cy = cy + 1
   end
end

-- loader
function modules_load()
   print("loading modules…")
   local dir = "achievements"
   local files = love.filesystem.getDirectoryItems(dir)

   for _, file in ipairs(files) do
      print("loading module:", file)
      --modules[file] = loadfile(dir .. "/" .. file)()
   end
end

function modules_call(which, ...)
   for _, module in pairs(modules) do
      local method = module[which]
      if method then method(...) end
   end
end


function love.load(args)
   if args[2] == "server" then
      require("server.main", args)
   else
      require("client.main", args)
   end
end
