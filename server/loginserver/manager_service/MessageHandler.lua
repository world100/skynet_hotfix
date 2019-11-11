--
-- @Author:      name
-- @DateTime:    2018-03-30 23:05:48
-- @Description: 节点内消息的处理

local skynet = require "skynet"
local log = require "Logger"
local config = require "configquery"
local crypt = require "crypt"
local ProtoLoader = require "ProtoLoader"



local MessageHandler = class("MessageHandler")

---------------------------------------------------------
-- Private
---------------------------------------------------------
function MessageHandler:ctor(message_dispatch)

	self.svr_id = skynet.getenv("svr_id") --

	self.message_dispatch = message_dispatch	
	self.service_num = 0
	self.num = 1 --	
	self:register()
	
	--定时查看本服务逻辑是否发生改变
	skynet.fork(function()
		while true do 
			skynet.sleep(200)
			self:test()
		end
	end)
end

--注册本服务里的消息
function MessageHandler:register()

	self.message_dispatch:registerSelf('start', handler(self,self.start))
	self.message_dispatch:registerSelf('hotfix', handler(self,self.hotfixFile))
end

function MessageHandler:test()
	-- self.num = self.num + 1
	skynet.error("_测试输出__2__test_____self.num___这是服务_____",self.service_num)
	
end


---------------------------------------------------------
-- CMD
---------------------------------------------------------
function MessageHandler:start(data)
	self.service_num = data or 0
	skynet.error("_____manager_service__start________")
end

function MessageHandler:hotfixFile(file_module)
	if global.hotfix then 
		global.hotfix:hotfixFile(file_module)
	end
	-- skynet.debug("__________data________",data)
end





return MessageHandler