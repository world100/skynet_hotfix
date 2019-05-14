--
-- Author:      name
-- DateTime:    2018-04-21 16:07:56
-- Description: 语言类

local Language = class("Language")

g_language = nil

function Language:getInstance(name)
	if not g_language then 
		g_language = Language.new(name)
	end
	return g_language
end

function Language:ctor(name)
	self.tbLan = {
		"ch",
		"en",
	}
	self.tbText = {}
	for k,v in pairs(self.tbLan) do 
		if name == v then 
			self.tbText = require(v)
			break
		end
	end
	if not next(self.tbText) then 
		self.tbText = require("ch")
	end
end

function Language:get(id)
	return self.tbText[id] or ""
end


return Language