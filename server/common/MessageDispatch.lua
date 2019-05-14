--
-- @Author:      
-- @DateTime:    2018-03-30 23:05:48
-- @Description: 消息的派发

local skynet = require "skynet"
local log = require "Logger"
local md5 = require "md5"
local crypt = require "crypt"
local cjson = require "cjson"
local queue = require "skynet.queue"


local MessageDispatch = class("MessageDispatch")
---------------------------------------------------------
-- Private
---------------------------------------------------------
function MessageDispatch:ctor()
	self.self_msg_callback = nil
	self.tb_self_msg = {} --本服务要监听的消息
	self.mqueue = queue()
end



--注册本服务里的消息
function MessageDispatch:registerSelf(msg_name, callback)
	if not callback or type(callback) ~= 'function' then 
		log.error("注册的函数回调不对___", msg_name)
		return
	end
	self.tb_self_msg[msg_name] = callback
end




--消息派发
function MessageDispatch:dispatchMessage(session, source, cmd, ... )
	-- print("####dispatchMessage#######",source, cmd, ...)
	local func = self.tb_self_msg[cmd] -- gate是否有handler
	if not func and not self.self_msg_callback then 
		-- print("__self.tb_self_msg__",self.tb_self_msg)
		log.error("####### cmd "..cmd .." not found at manager_service ")
		return
	end

	if cmd == "socket" then 
		if func then			
			skynet.retpack(xx_pcall(func, source, ...))	
		else 
			skynet.retpack(xx_pcall(self.self_msg_callback, source, ...))	
		end
		return
	end
	
	if func then
		-- xx_pcall(func, ...)
		skynet.retpack(xx_pcall(func, ...))
	else
		skynet.retpack(xx_pcall(self.self_msg_callback, ...))
	end
end


--需要排队的消息
function MessageDispatch:dispatchQueue()
	return handler(self, self.queueMessage)
end

function MessageDispatch:dispatch(type)
	return handler(self, self.dispatchMessage)
end


return MessageDispatch