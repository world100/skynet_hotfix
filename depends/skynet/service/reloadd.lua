local skynet = require "skynet"
local c = require "skynet.core"
local ModuleList = {} --list[path] = {{time,montior}}

skynet.register_protocol {
	name = "reload",
	id = skynet.PTYPE_RELOAD,
	pack = skynet.pack,
	unpack = skynet.unpack,
}

local function filetime(file)
	return c.command("FILETIME",file)
end

local function dispatch_notice(list,path)
	for k,_ in pairs(list)
	do
		skynet.send(k,'reload',path)
	end
end

local function update()
	skynet.sleep(100)
	while true do
		for path,v in pairs(ModuleList)
		do
			local newtime = filetime(path)
			if(v[1]~=newtime)
			then
				v[1] = newtime
				print("Reload File ===>> "..path)
				local func, msg = loadfile('@'..path)
				if not func then
					print(msg)
				end				
				dispatch_notice(v[2],path)
			end
		end
		
		skynet.sleep(300)
	end
end

skynet.start(function()
	skynet.fork(update)
	skynet.dispatch("lua", function (_, source, filepath)
		local file = ModuleList[filepath]
		if(not file)
		then
			print('reload sub path:'..filepath)
			file = {filetime(filepath),{}}
			ModuleList[filepath] = file
		end
		file[2][source] = true
	end)
end)