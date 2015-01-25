music = {}

local prefix = "assets/RubberJohnny"
local data = {}
local queue = {}
local current

function music.load()
   for i = 1, 2 do
      local intro = love.audio.newSource(prefix .. "T" .. i .. ".wav")
      local loop = love.audio.newSource(prefix .. i .. ".wav")

      loop:setLooping(true)

      data[i] = { intro, loop }
   end
end

function music.playloop(num)
   print("PLAY")
   music.stoploop()
   current = num
   data[num][1]:play()
end

function music.stoploop()
   current = nil
   love.audio.stop()
end

function music.update(dt)
   if not current then return end

   if not data[current][1]:isPlaying() and not data[current][2]:isPlaying() then
      print("changing music!")
      data[current][1]:stop()
      data[current][2]:play()
   end
end

