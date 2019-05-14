--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local skynet = require "skynet"
local cluster 
local log = { _version = "0.1.0" }
local log_server


log.logfile = skynet.getenv("logger_file")
log.level = skynet.getenv("logger_level") or "trace"
log.level = 'debug'

local modes = {
    { name = "trace", file = log.logfile.."trace.log"},
    { name = "info", file = log.logfile.."info.log"},
    { name = "debug", file = log.logfile.."debug.log"},
    { name = "warn",  file = log.logfile.."warn.log"},
    { name = "error", file = log.logfile.."error.log"},
    { name = "fatal", file = log.logfile.."fatal.log"},
}

local levels = {}
for i, v in ipairs(modes) do
    levels[v.name] = i
end

local round = function(x, increment)
    increment = increment or 1
    x = x / increment
    return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * increment
end

local _tostring = tostring

local tostring = function(...)
    local t = {}
    for i = 1, select('#', ...) do
        local x = select(i, ...)
        if type(x) == "number" then
            x = round(x, .01)
        end
        t[#t + 1] = _tostring(x)
    end
    return table.concat(t, " ")
end


local function x_pcall(f, ...)
    return xpcall(f, debug.traceback, ...)
end

for i, x in ipairs(modes) do
    local file = x.file
    local format_str = x.fmt or "[%-6s%s][%s] %s"
    local nameupper = x.name:upper()
    log[x.name] = function(...)
        -- 日记级别设置
        if i < levels[log.level] then
            return 
        end
        local msg_tab = { ... }
        local msg_num = #msg_tab

        local msg_str
        if msg_num == 1 then
            msg_str = tostring(msg_tab[1])
        elseif msg_num > 1 then
            local tmp_msg_tab = {}
            for i=1, msg_num do
                local v = msg_tab[i]
                table.insert(tmp_msg_tab, tostring(v))
                table.insert(tmp_msg_tab, ' ')
            end
            msg_str = table.concat(tmp_msg_tab)
        else
            return
        end
        local info = debug.getinfo(2, "Sl")
        local lineinfo = info.short_src .. ":" .. info.currentline
        local str = string.format(format_str, nameupper, os.date("%X"), lineinfo, msg_str)
        str = string.format("[:%08x] " .. format_str .. "\n", skynet.self(), nameupper, os.date("%m-%d %X"), lineinfo, msg_str)
        if x.name == 'error' then 
            skynet.error(str)
        elseif x.name == 'debug' then 
            print(str)
        end
        if not cluster then 
           cluster = require "cluster"
        end
        -- print("____1111111111_______send__",cluster,x.name,file,str)
        -- local ok,result = pcall(cluster.send, 'logger','log_manager',x.name,file,str) 
        -- local ok, result = xpcall(cluster.send,debug.traceback,'logger','log_manager',x.name,file,str)
        -- if not ok then
        --     log.error('logger.lua send faild:',result)
        -- end
        cluster.send('logger','log_manager',x.name,file,str) 
    end
end

return log