local socket = require("socket")

local server = socket.bind("0.0.0.0", "1234")

local ins = {server}

-- clients info
local ci = {}

function love.update(dt)
	local toread, _, err = socket.select(ins, {}, 0.1)
	for _,client in ipairs(toread) do
		if client == server then
			local client = server:accpet()
			client:settimeout(0)
			ins[#ins+1] = client
		else
			local msg, err = client:receive("*l")
			if not msg then
				print("client closed:", err)
				for k,v in ipairs(ins) do
					if v == client then
						table.remove(ins, k)
					end
				end
			else
				handle_msg(client, msg)
			end
		end
		print(client)
	end
end

function handle_msg(client, msg)

end
