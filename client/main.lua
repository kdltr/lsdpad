-- Globals

-- Text screen
s = {}
s[1] = {}


-- Modules loading
modules = {}

local function modules_load()
	local dir = "achievements"
	local files = love.filesystem.getDirectoryItems(dir)

	for _, file in ipairs(files) do
		print("loading module:", file)
		modules[file] = loadfile(dir .. "/" .. file)()
	end
end


-- bleraituenae

function love.textinput(text)
end

function love.draw()
	for _, module in pairs(modules) do
		if module.draw then module.draw() end
	end
	love.graphics.print("coucou!", 30, 30)
end

function love.update(dt)
	for _, module in pairs(modules) do
		if module.update then module.update(dt) end
	end
end

function love.keypressed(key)
	for _, module in pairs(modules) do
		if module.keypressed then module.keypressed(key) end
	end
end


modules_load()
