music = {}

local prefix = "assets/RubberJohnny"
local data = {}
local current
local subcurrent
local next
local unlocked = {}
local clock = 0

local function stop_loops()
   for _, m in ipairs(data) do
      m[1]:stop()
      m[2]:stop()
   end
end

local function choose_music()
   local t = {}
   for id, _ in pairs(unlocked) do
      table.insert(t, id)
   end
   return t[math.random(#t)]
end

function music.load()
   for i = 1, 4 do
      local intro = love.audio.newSource(prefix .. "T" .. i .. ".wav")
      local loop = love.audio.newSource(prefix .. i .. ".wav")

      data[i] = { intro, loop }
   end
end

function music.playloop(num)
   unlocked[num] = true
   next = num
end

function music.stoploop()
   current = nil
   subcurrent = nil
   next = nil
   love.audio.stop()
end

function music.update(dt)
   clock = clock + dt

   if clock >= math.random(60) + 60 then
      next = choose_music()
      clock = 0
   end

   if not current then
      if next then
         current = next
         next = nil
         subcurrent = 1

         print("playing", current, subcurrent)
         data[current][subcurrent]:play()
      end
   end

   if subcurrent == 1 and not data[current][subcurrent]:isPlaying() then
      subcurrent = 2

      print("playing", current, subcurrent)
      data[current][subcurrent]:play()
   elseif subcurrent == 2 and not data[current][subcurrent]:isPlaying() then
      if next then
         current = next
         next = nil
         subcurrent = 1
      end

      print("playing", current, subcurrent)
      data[current][subcurrent]:play()
   end
end

