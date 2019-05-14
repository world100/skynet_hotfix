local sharedata = require "sharedata"

local x_cfg = {}
local x_cfg_buff = {}

local _x_cfg_mt = {
    __index = function(t, k)
        local cfg = x_cfg_buff[k]
        if cfg == nil then            
            cfg = sharedata.query(k)
            x_cfg_buff[k] = cfg
        end
        return cfg        
    end
}
setmetatable(x_cfg, _x_cfg_mt)

function x_cfg.clear()
    x_cfg_buff = {}
end

return x_cfg