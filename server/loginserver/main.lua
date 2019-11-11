--
-- @Author:      name
-- @DateTime:    2018-04-20 21:48:12
-- @Description: 节点起动与集群配置读取

local skynet = require "skynet"
local cluster = require "cluster"
local config = require "configquery"

skynet.start(function()
	skynet.uniqueservice("confcenter")
	local setting = config.setting_cfg
	local svr_id = tonumber(skynet.getenv("svr_id")) --服务器id
	local svr_name = skynet.getenv("svr_name") --服务器类型
	local svr_info = setting[svr_name][svr_id]


	--skynet控制台
	skynet.uniqueservice("debug_console",svr_info.debug_port)



	--主服务
	local manager = skynet.newservice("manager_service")
	skynet.call(manager, "lua", "start")



	skynet.error("----------------测试定时新开服务--------------------")
	skynet.fork(function()
		for i=2, 20 do 
			skynet.sleep(1000)
			local manager = skynet.newservice("manager_service","第"..i.."个服务起动")
			skynet.call(manager, "lua", "start", i)
		end
	end)

	
    -- skynet.exit()
end)

