local function modules_load()
	print("loading modules…")
	local dir = "achievements"
	local files = love.filesystem.getDirectoryItems(dir)

	for _, file in ipairs(files) do
		print("loading module:", file)
		--modules[file] = loadfile(dir .. "/" .. file)()
	end
end

modules_load()

