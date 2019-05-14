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
	local cluster_name = svr_name.."_"..svr_id
	local cluster_list = {} --集群配置表
	for server_type, server_list in pairs(setting) do 
		for k, v in pairs(server_list) do 
			cluster_list[server_type.."_"..k] = v.cluster
		end
	end	
	--skynet控制台
	skynet.uniqueservice("debug_console",svr_info.debug_port)

	--集群表加载
	cluster.reload(cluster_list)	
	cluster.open(cluster_name)
	
	print("#####################",svr_name, cluster_name)


	--主服务
	local manager = skynet.newservice("manager_service")
	skynet.call(manager, "lua", "start")



	skynet.error("----------------测试定时新开服务--------------------")
	skynet.fork(function()
		for i=2, 20 do 
			skynet.sleep(1000)
			local manager = skynet.newservice("manager_service","第"..i.."个服务起动")
			skynet.call(manager, "lua", "start")
		end
	end)

	
    -- skynet.exit()
end)

