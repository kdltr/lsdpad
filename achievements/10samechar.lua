
local m = {}

local ponay = love.graphics.newImage('assets/ponay.png')
local ponay_sound = love.audio.newSource('assets/RubberJohnnyPoney.wav')


local t, alpha = 0.0, 0.0

function m.init_client(client)
   client._10samechar_last = ''
   client._10samechar_count = 0
end

function m.char(client, char)
   if char == client._10samechar_last then
      client._10samechar_count = client._10samechar_count + 1
      if client._10samechar_count == 10 then
         m.activated = true
         ach('10samechar')
      end
   else
      client._10samechar_cound = 0
      client._10samechar_last = char
   end
end

function m.activate(box)
  if box then box_push('10 times the same character!') end
  m.activated = true
  music.playloop(2)
end

local sound_delay

function m.update(dt)
   if not m.activated then return end
   if alpha < 0.20 then alpha = alpha + dt * 0.005 end
   t = t + dt / 200 
   sound_delay = sound_delay + dt
   if sound_delay >= 120 then
      ponay_sound:play()
      sound_delay = 0
   end
end

function m.pre_draw()
   if not m.activated then return end
   love.graphics.setColor(255, 255, 255, alpha * 255)
   love.graphics.draw(ponay, love.window.getWidth() / 2, love.window.getHeight() / 2, t, 0.5, 0.5, ponay:getWidth() / 2, ponay:getHeight() / 2)
end

return m
