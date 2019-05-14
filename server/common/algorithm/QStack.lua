--栈，后进先出
require "luaext"

local QStack = class("QStack")

function QStack:ctor()
	self.list = {}
end

function QStack:size()
	return #self.list
end

function QStack:push(node)
	if not node then 
		return 
	end
	table.insert(self.list,1,node)
end

function QStack:pop()
	if next(self.list) then 
		return table.remove(self.list,1)
	end
	return nil
end

function QStack:remove(node)
	if next(self.list) then 
		for k,v in pairs(self.list) do 
			if v == node then 
				table.remove(self.list,k)
				break
			end
		end
	end
	return nil
end

function QStack:print()
	for i=1,#self.list do 
		print("---->",self.list[i])
	end
end

local stack = QStack.new()
stack:push(3)
stack:push(4)
stack:push(2)
stack:push(1)
stack:push(5)
stack:remove(2)
print("__pop__",stack:pop())
stack:print()