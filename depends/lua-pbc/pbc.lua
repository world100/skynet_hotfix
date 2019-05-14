local skynet = require "skynet"
local filelog = require "filelog"
local base = require "base"
local PBC = {}

function PBC.init()
	local result, P = base.pcall(skynet.call, ".pbcservice", "lua", "get_protobuf_env")	
	if not result then
		filelog.sys_error("PBC.init "..P)
	else
		debug.getregistry().PROTOBUF_ENV = P
	end
	return result
end

return PBC