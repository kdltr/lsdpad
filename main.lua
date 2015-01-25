-- shared declarations
s = {{}}
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

function del_char(x, y)
   if x <= #s[y] then
      table.remove(s[y], x)
   elseif x > #s[y] then
      if y == #s then return false end
      for _, v in ipairs(s[y + 1]) do
         table.insert(s[y], v)
      end
      table.remove(s, y + 1)
   end
   return true
end

function ins_line(x, y)
   table.insert(s, y + 1, {})
   for i = x, #s[y] do
      table.insert(s[y + 1], 1, table.remove(s[y]))
   end
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
      if method and
         (side == "server" and not module.activated
         or side == "client" and module.activated)
         then
            method(...)
         end
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
