--双向队列 (先进先出)
require "luaext"

local QQueue = class("QQueue")

function QQueue:ctor()
	self.list = {first = 0,last = -1}
end

--从头部插入
function QQueue:pushFront(node)
	local first = self.list.first
	self.list[first] = node
	self.list.first = first+1
end

--从尾部插入
function QQueue:pushBack(node)
	local last = self.list.last
	self.list[last] = node
	self.list.last = last-1
end

--从头部取
function QQueue:popFront()
	local first = self.list.first-1
	if first == self.list.last then 
		--空了		
		return nil
	end
	self.list.first = first
	local node = self.list[first]	
	self.list[first] = nil	
	return node
end

--从尾部取
function QQueue:popBack()
	local last = self.list.last+1
	if self.list.first == last then 
		--空了		
		return nil
	end		
	self.list.last = last
	local node = self.list[last]	
	self.list[last] = nil	
	return node	
end

function QQueue:print()
	for k,v in pairs(self.list) do 
		print("-->",k,v)
	end
end

local queue = QQueue.new()
queue:pushFront(1)
queue:pushFront(2)
-- queue:pushBack(3)
-- queue:print()
queue:popBack()
queue:pushBack(3)
queue:pushFront(2)
queue:popFront()
queue:print()