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
	self.message_dispatch:registerSelf('hotfix_test', handler(self,self.onHotfixText))
end

function MessageHandler:test()
	-- self.num = self.num + 1
	skynet.error("_111____test_____self.num________",self.num)
	
end


---------------------------------------------------------
-- CMD
---------------------------------------------------------
function MessageHandler:start()
	skynet.error("_____manager_service__start________")
end

function MessageHandler:onHotfixText(data)
	self.num = self.num + 1
	skynet.error("______onHotfixText____self.num________",self.num)
	-- skynet.debug("__________data________",data)
end





return MessageHandler