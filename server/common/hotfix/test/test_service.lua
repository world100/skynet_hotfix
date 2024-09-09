local skynet = require "skynet"
local hotfix_helper = request "hotfix.hotfix_helper"
local t2 = require "test02"
-----------------------------------------
---base
-----------------------------------------

local CMD = {}

function CMD.init()
  skynet.newservice("debug_console", 7001)

  t2.test2()
  -- os.Exit()

  return true
end

---------------------------------------------------------
---skynet
---------------------------------------------------------


local function dispatch_command( CMD )
	hotfix_helper.init(CMD)
	return 	function ( session, source, cmd, ... )
				local f = CMD[cmd]
				assert(f,'cmd no found :'..cmd)

				if cmd == 'socket' then
					skynet.retpack(xx_pcall(f, source, ...))
				elseif cmd == 'request' then
					skynet.retpack(xx_pcall(f, ...))
				else
					skynet.retpack(xx_pcall(f, ...))
				end
			end
end

skynet.start(function()
  skynet.dispatch("lua", dispatch_command(CMD))
end)
