--
-- Author:      name
-- DateTime:    2018-04-23 17:19:33
-- Description: 服务管理


require "skynet.manager"
local skynet = require "skynet"
local Hotfix = require("Hotfix")

local MessageDispatch = import("MessageDispatch")
local MessageHandler = import("MessageHandler")

--服务唯一全局变量, 别的地方请不要注册全局变量, 请不要中途往global里加入变量
global = {}


local function init()

	--在luaext.lua 里有对类对象进行加入处理
	local hotfix = Hotfix.new()
	global.hotfix = hotfix

	local message_dispatch = MessageDispatch.new()		
	local message_handler = MessageHandler.new(message_dispatch)



	skynet.dispatch("lua", message_dispatch:dispatch())		
	skynet.register('.proxy')
end


---------------------------------------------------------
-- skynet
---------------------------------------------------------

skynet.start(function()

	init()
	
end)