music = {}

local prefix = "assets/RubberJohnny"
local data = {}
local current
local subcurrent
local next
local unlocked = {}

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
      local intro = love.audio.newSource(prefix .. "T" .. i .. ".ogg")
      local introG = love.audio.newSource(prefix .. "T" .. i .. "Glitch.ogg")
      local loop = love.audio.newSource(prefix .. i .. ".ogg")
      local loopG = love.audio.newSource(prefix .. i .. "Glitch.ogg")

      introG:setVolume(0)
      loopG:setVolume(0)

      data[i] = { intro, loop, introG, loopG }
   end
end

function music.playloop(num)
   unlocked[num] = true
   next = num
end

function music.glitch()
   for _, m in ipairs(data) do
      m[1]:setVolume(0)
      m[2]:setVolume(0)
      m[3]:setVolume(1)
      m[4]:setVolume(1)
   end
end

function music.unglitch()
   for _, m in ipairs(data) do
      m[1]:setVolume(1)
      m[2]:setVolume(1)
      m[3]:setVolume(0)
      m[4]:setVolume(0)
   end
end

function music.stoploop()
   current = nil
   subcurrent = nil
   next = nil
   love.audio.stop()
end

function music.update(dt)

   if not next then
      next = choose_music()
   end

   if not current then
      if next then
         current = next
         next = nil
         subcurrent = 1

         print("playing", current, subcurrent)
         data[current][subcurrent]:play()
         data[current][subcurrent+2]:play()
      end
   end

   if subcurrent == 1 and not data[current][subcurrent]:isPlaying() then
      subcurrent = 2

      print("playing", current, subcurrent)
      data[current][subcurrent]:play()
      data[current][subcurrent+2]:play()
   elseif subcurrent == 2 and not data[current][subcurrent]:isPlaying() then
      if next then
         current = next
         next = nil
         subcurrent = 1
      end

      print("playing", current, subcurrent)
      data[current][subcurrent]:play()
      data[current][subcurrent+2]:play()
   end
end

