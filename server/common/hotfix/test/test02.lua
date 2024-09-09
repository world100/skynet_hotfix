local skynet = require "skynet"
local log = require "logger"


--回调的好手
function handler(obj, method)
    assert(obj)
    assert(obj[method])
    return function(...)
        return obj[method](...)
    end
end
local a = 1

local function test()
    a = a + 1
    log.info("local test6666666", a)
end
local function test2()
    a = a + 1
    log.info("local test222", a)
end

local M = {}
local TIME_FUNC = {}
M.TIME_FUNC = TIME_FUNC
local STATUS = {}
STATUS.start = function ()
    -- log.info("start22222222")
    test()
end
STATUS.play = function ()
    log.info("play")
end
M.STATUS = STATUS


M.test1 = function()
    -- test()
    -- log.info("M.test8888", a)
    -- log.info("666666666")
    -- test2()
    log.info("test fun:", sys_tostring(test))

    log.info("STATUS.start fun:", sys_tostring(STATUS.start))
end

M.test2 = function()
    M.print()
    local fun1 = handler(M, "test1")
    local fun2 = handler(STATUS, "start")
    local fun3 = function ()
        test()
    end
    TIME_FUNC.start = function ()
        return STATUS.start()
    end
    local func4 = handler(TIME_FUNC, "start")

    skynet.fork(function()
        while(true) do 
            skynet.sleep(500)
            -- M.test1()
            fun1()
            -- log.error("STATUStb:", sys_tostring(STATUS), sys_tostring(STATUS.start))
            -- log.error("tb:M", sys_tostring(M.test1))
            fun2()

            -- fun3()
            func4()
        end
    end)
end

M.print = function ()
    -- log.error("tb:", sys_tostring(STATUS),sys_tostring(STATUS.start))
    log.error("tb:M", sys_tostring(M.test1))
end


return M