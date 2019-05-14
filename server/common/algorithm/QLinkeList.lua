--链表

require "luaext"

local QLinkList = class("QLinkList")
--[[
local Node = {
	head=nil,
	tail=nil,
	value=nil,
}
]]

function QLinkList:ctor()
	self.headNode = {
		head=nil,
		tail=nil,
		value=nil,	
	}
	self.tailNode = {
		head=nil,
		tail=nil,
		value=nil,	
	}
	self.headNode.tail = self.tailNode
	self.tailNode.head = self.headNode
end

--增
function QLinkList:add(value,posNode)
	local node = {
		head=nil,
		tail=nil,
		value=nil,	
	}
	node.value = value
	if posNode then 
		node.head = posNode
		node.tail = posNode.tail	
		posNode.tail.head = node
		posNode.tail = node	
		return
	end
	local tail = self.headNode.tail
	tail.head = node
	node.head = self.headNode
	node.tail = tail
	self.headNode.tail = node	
	-- print("___nodehead__",value,node.head.value,self.headNode.value)
end

--删
function QLinkList:remove(value)
	local tbNode = self:find(value)
	for _,node in pairs(tbNode) do		
		node.head.tail = node.tail
		node.tail.head = node.head
		node = nil
	end
	tbNode = nil
end

--查
function QLinkList:find(value)
	local node = self.headNode.tail
	local tbNode = {}
	while node do 
		if node.value == value then 
			table.insert(tbNode,node)
		end
		node = node.tail
	end
	return tbNode
end

--打印
function QLinkList:print()
	local node = self.headNode.tail
	while node do 
		print(node.value)
		node = node.tail
	end
end


local list = QLinkList.new()
list:add(2)
list:add(3)
list:add(1)
list:add(4)
list:add(6,list:find(3)[1])
-- list:remove(3)
list:print()