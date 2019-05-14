--
-- Author:      name
-- DateTime:    2018-04-23 17:19:33
-- Description: 服务管理


require "skynet.manager"
local skynet = require "skynet"

local Objects = require "Objects"
local MessageDispatch = require "MessageDispatch"
local MessageHandler = require "MessageHandler"

g_objects = Objects.new()

local function init()

	local message_dispatch = MessageDispatch.new()		
	local message_handler = MessageHandler.new(message_dispatch)

	g_objects:add(message_handler)
	g_objects:hotfix()

	skynet.dispatch("lua", message_dispatch:dispatch())		
	skynet.register('.proxy')
end


---------------------------------------------------------
-- skynet
---------------------------------------------------------

skynet.start(function()

	init()
	
end)