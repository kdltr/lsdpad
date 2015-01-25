
local gs = require 'lib.generic_sequence'
local m = gs("42", "42", "The answer!")

function m.update(dt)
end

function m.post_draw()
end

return m

