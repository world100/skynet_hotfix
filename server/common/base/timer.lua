local skynet = require "skynet"
local inspect = require "inspect"
local timer = {}

function timer:new(interval)
	local t = {}

	setmetatable(t, self)

	self.__index = self
	t:init(interval)
	return t
end

function timer:init(interval)
	if not interval then
		interval = 100
	end

	self.inc = 0

	self.interval = interval

	self.timer_idx = 0

	self.callbacks = {}

	self.timer_idxs = {}

	self.unregister_idx = {}

	skynet.timeout(self.interval, function()
		self:on_time_out()
	end)
end

function timer:on_time_out()
	skynet.timeout(self.interval, function()
		self:on_time_out()
	end)

	self.inc = self.inc + 1

	local callbacks = self.callbacks[self.inc]

	if not callbacks then
		return
	end

	--把注销的剔除掉
	for i=#self.unregister_idx,1,-1 do
		local idx = self.unregister_idx[i]
		if callbacks[idx] then
			callbacks[idx] = nil
			self.timer_idxs[idx] = nil
			table.remove(self.unregister_idx,i)
		end
	end

	for idx,callback in pairs(callbacks) do
		callback.f(callback.param)
		if callback.loop then
			local sec = self.inc + callback.sec
			self.timer_idxs[idx] = sec
			if not self.callbacks[sec] then
				self.callbacks[sec] = {}
			end
			callback.start_time = os.time()
			self.callbacks[sec][idx] = callback
		else
			self.timer_idxs[idx] = nil
		end
	end

	self.callbacks[self.inc] = nil
end

function timer:register(sec, param, f, loop)
	assert(type(sec) == "number" and sec > 0)
	assert(f and type(f) == "function")
	local _sec = sec
	sec = self.inc + sec

	self.timer_idx = self.timer_idx + 1
	if self.timer_idx > 2147483646 then 
		self.timer_idx = 1
	end
	self.timer_idxs[self.timer_idx] = sec

	if not self.callbacks[sec] then
		self.callbacks[sec] = {}
	end

	local callbacks = self.callbacks[sec]
	callbacks[self.timer_idx] = {f = f,param = param,sec = _sec,loop = loop,start_time=os.time()}
	
	return self.timer_idx
end

function timer:left_time(idx)
	if not idx then return end
	local sec = self.timer_idxs[idx]
	if not sec then
		return
	end
	local start_time = self.callbacks[sec][idx].start_time
	local wait_time = self.callbacks[sec][idx].sec
	local now_time = os.time()
	return start_time + wait_time - now_time
end

function timer:unregister(idx)
	if not idx then return end
	local sec = self.timer_idxs[idx]
	if not sec then
		return
	end

	table.insert(self.unregister_idx,idx) 
end

return timer
