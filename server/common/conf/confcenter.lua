--
-- Author:      name
-- DateTime:    2018-04-21 15:27:55
-- Description: 服务间共享配置数据

local skynet = require "skynet"
local configtool = require "configtool"

local setting_file = skynet.getenv("setting_file")
--进程配置
local function load_service_setting( )
	local config = require(setting_file)
	for _,pro in pairs(config) do
		for k,v in pairs(pro) do 
			if type(v) == 'table' then
				v.svr_id = k				
			end
		end
	end
	configtool.share_new("setting_cfg", config)	
end

local function load_config()	
	load_service_setting()
end

skynet.start(function()
	configtool.begin()
	load_config()
	configtool.finish()
end)