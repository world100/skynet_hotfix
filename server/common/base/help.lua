	
local skynet = require "skynet"
local log = require "logger"
local Lang = require "Language"

local lang = Lang:getInstance()
local xpcall = xpcall
local pcall = pcall


function f_check_error(err)
	return (type(err) == "table" and err.err_no) and err or { err_no = -1, err_msg = tostring(err) }
end

function f_error(msg, err_no, format_string, ...)
	log.error('f_error >>>>>>>>', msg, err_no, format_string, ...)
	local err_body = {}
	if not msg then
		msg = 'error_res'
	end
	local param = ...
	local err_msg = format_string
	if param and err_msg then 
		err_msg = string.format(format_string, ...) or ""
	elseif not err_msg then  
		err_msg = lang:get(err_no) or format_string or ""
	end
	err_body[msg] = {
		err_no = err_no or -1,
		err_msg = err_msg,		
	}
	err_body.err = true
	return err_body
end

function x_pcall(f, ...)
	return xpcall(f, debug.traceback, ...)
end

function xx_pcall(f, ...)
	return (function ( ok, result, ... )
		 if not ok then
		 	log.error("xx_pcall faild:", result)
		 	--return
		 end
		return result, ...
	end)(x_pcall(f, ...))
end

function rq_pcall(f, ...)
	return (function ( ok, result, ... )	
		if not ok then
			if type(result) ~= 'table'then
				log.error("rq_pcall faild:".. tostring(result))

				return f_error(nil, -1, 'internal error')
			end
		elseif result and type(result) == 'table' and result.err then
			result.err = nil --有错误信息的情况下为何置空
		end
		return result, ...
	end)(x_pcall(f, ...))
end

function Assert(a, err_no,  format_string, ...)
	if not a then
		assert(a,f_error(nil, err_no, format_string, ...))
	end
end

function AssertEx(a, msg, err_no,  format_string, ...)
	if not a then
		assert(a,f_error(msg, err_no, format_string, ...))
	end
end

function GetErrorTable(err_no)
	return {err_no=err_no,err_msg=lang:get(err_no)}
end

function dispatch_command( CMD, REQUEST )
	if REQUEST then
		CMD.Request = function ( cmd,...)
			log.debug('REQUEST',cmd)
			local f = REQUEST[cmd]
			assert(f, 'REQUEST cmd no found :'..cmd)
			local result = f(...)
			log.debug(result)
			return result
		end
	end

	return function ( session, source, cmd, ... )
		local f = CMD[cmd]
		-- assert(f,'cmd no found :'..cmd)
		if not f then return end 

		if cmd == 'socket' then
			skynet.retpack(xx_pcall(f, source, ...))
		elseif cmd == 'Request' then
			--log.debug(...)
			skynet.retpack(rq_pcall(f, ...))
		else
			skynet.retpack(xx_pcall(f, ...))
	    end
	end
end


function stopwatch(f, title)
	if type(f) == "function" then
		local tick = os.clock()
		pcall(f)
		tick = os.clock() - tick
		print("stopwatch " .. tostring(title) .. " end in " .. tostring(tick) .. " seconds")
	end
end
