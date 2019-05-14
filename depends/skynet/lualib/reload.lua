local skynet = require "skynet"
local c = require "skynet.core"
local servicePath = SERVICE_PATH..SERVICE_NAME..'.lua'
local RELOAD

skynet.register_protocol {
	name = "reload",
	id = skynet.PTYPE_RELOAD,
	pack = skynet.pack,
	unpack = skynet.unpack,
}

local function subcribe(list)
	local reloadd = skynet.queryservice("reloadd")
	for k,v in ipairs(list)
	do
		skynet.send(reloadd,'lua',v)
	end
end

local function loadF(list,ignore_self)
	if RELOAD then return end
	RELOAD = true
	list = list or {}
	for k,v in ipairs(list)
	do
		local fun,msg = loadfile(v)
		if not fun then
			print(msg)
		else
			fun()
		end
	end

	if not ignore_self then
		table.insert(list,servicePath)
	end

	--queryservice will hang up at call,ned fork
	skynet.fork(subcribe,list)
end

skynet.dispatch("reload", function (_, source, filepath)
	local fun,msg = loadfile(filepath)
	if not fun then
		print(msg)
	else
		fun()
	end
end)

-- function reload_check()
-- 	local i = 1
-- 	print('<============')
-- 	while true do
-- 		local n, v = debug.getlocal(2, i)
-- 		if not n then break end
-- 		print(n,v)
-- 		i = i + 1
-- 	end
-- 	print('============>')
-- end

return loadF