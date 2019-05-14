--树
--[[
	前序遍历 根节点->左子树->右子树
	中序遍历 左子树->根节点->右
	后序遍历 左->右->根
]]

require "luaext"

local QTree = class("QTree")

function QTree:ctor()
	
end

local tb = {1,2,3,4}
