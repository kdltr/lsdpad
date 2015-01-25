
local gs = require 'lib.generic_sequence'
local m = gs("42", "42", "The answer!")

local nbglitch = 40

local gw = 50
local gh = 50

local dx
local dy

local glitches = {}
local clock = 0
local deleteclock = 0
local nexttime = 0

function m.update(dt)
   deleteclock = deleteclock + dt
   clock = clock + dt
   if clock >= nexttime then
      nexttime = clock + math.random()^10 * 10

      if #glitches > nbglitch then return end

      local screenshot = love.graphics.newScreenshot()

      for n = 1, math.random(nbglitch) do
         local gw = math.random(gw) + 5
         local gh = math.random(gh) + 10
         local glitchdata = love.image.newImageData(gw, gh)
         local sx = math.random(love.window.getWidth() - gw)
         local sy = math.random(love.window.getHeight() - gh)

         for i = 0, gw-1 do
            for j = 0, gh-1 do
               local r, g, b = screenshot:getPixel(sx + i, sy + j)
               r = r - math.random(40)
               g = g - math.random(40)
               b = b - math.random(40)
               glitchdata:setPixel(i, j, r, g, b)
            end
         end

         dx = math.random(love.window.getWidth() - gw)
         dy = math.random(love.window.getHeight() - gh)

         table.insert(glitches, { dx, dy, love.graphics.newImage(glitchdata) })
         music.glitch()
      end
   end

   if deleteclock >= 1/30 then
      deleteclock = 0
      table.remove(glitches, math.random(#glitches))
      if #glitches == 0 then
         music.unglitch()
      end
   end
end

function m.post_draw()
   for _, g in ipairs(glitches) do
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(g[3], g[1], g[2])
   end
end

return m

