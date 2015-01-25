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

function map_s(fun)
   local cx, cy, ip = 0, 0, 1
   while ip <= #s do
      c = s[ip]
      fun(ip, cx, cy, c)
      if c[1] == 'nl' or cx == cols - 1 then
         cx = 0
         cy = cy + 1
      else
         cx = cx + 1
      end
      ip = ip + 1
   end
   fun(ip, cx, cy, nil)
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
      if method and
         (side == "server" and not module.activated
         or side == "client" and module.activated)
         then
            method(...)
         end
   end
end

local function color_diff(ref, value)
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

function nb_lines()
   local count = 0
   for _, char in ipairs(s) do
      if char[1] == "nl" then
         count = count + 1
      end
   end
   print("nb_lines", count)
   return count
end

function love.load(args)
   modules_load()
   if args[2] == "server" then
      require("server.main", args)
   else
      require("client.main", args)
   end
end
