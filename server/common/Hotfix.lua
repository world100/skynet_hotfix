--
-- Author:      feilong
-- DateTime:    2019-04-27 10:59:15
-- Description: 对象的热更


--负责对象的热更
-- local skynet = require "skynet"
-- local codecache = require "skynet.codecache"

local table_insert = table.insert
local table_remove = table.remove
local string_split = string.split

local Hotfix = {}

function Hotfix.new(...)
	local instance = setmetatable({}, {__index=Hotfix})
	instance:ctor(...)
	return instance
end


-------------
function Hotfix:ctor()

	self.open = true --功能关闭中

	self.module_list = {} --模块里的对象	
end


function Hotfix:hotfixFile(file_path)
	print("____hotfix_____更新文件___",self.open, file_path)
	if not self.open then 
		return 
	end		
	--全部列表更新
	if not file_path or file_path == "" then 		
		for mode_name, objects in pairs(self.module_list) do 
			-- print("________mode_name__", mode_name)
			if package.loaded[mode_name] then 	
				package.loaded[mode_name] = nil
				local new_module = require(mode_name)
				-- print("#####hotfix#############",mode_name, new_module.__cname, new_module, objects)	
				--更新类方法
			    for k, v in pairs(new_module) do         			        
			        for _, object in pairs(objects) do 
			        	if object[k] and type(object[k]) == "function" then 
			        		print("##################", k )
					        object[k] = v
					    end
				    end
			    end
			    for _, object in pairs(objects) do 
			        if object.register and type(object.register) == "function" then --重新注册回调函数
			        	object:register()
			        end
			    end	    
				package.loaded[mode_name] = new_module				
			end
		end
		print("____hotfix_____更新文件完成___")
		return true
	end

	--单个文件更新
	if not package.loaded[file_path] then 
		print("_hotfix_模块列表里没有找这个文件__",file_path)
		return false
	end
	-- --清除缓存
	-- codecache.clear()			
	package.loaded[file_path] = nil
	local new_module = require(file_path)	
	local objects = self.module_list[file_path]
	--更新类方法
    for k, v in pairs(new_module) do                 
        for i, object in pairs(objects) do 
        	if object[k] and type(object[k]) == "function" then 
		        object[k] = v
		    end
	    end
    end
    for i, object in pairs(objects) do 
        if object.register and type(object.register)=="function" then --重新注册回调函数
        	object:register()
        end
    end	    
	package.loaded[file_path] = new_module
	print("_hotfix_更新成功___")			
	return true
end

--添加对象到模块列表中
function Hotfix:addObject(module_name, object)
	if not self.open then 
		return 
	end	
	if not module_name or not object then 
		return 
	end
	if not self.module_list[module_name] then 
		self.module_list[module_name] = {}
		setmetatable(self.module_list[module_name], {__mode="v"}) --弱表就不用管理对象删除了
	end
	local need_add = true 
	for _, obj in pairs(self.module_list[module_name]) do 
		if obj == object then 
			need_add = false 
			break
		end
	end
	if need_add then 
		table_insert(self.module_list[module_name], object)
	end

end


--
function Hotfix:start()
	self.open = true --开启

end
function Hotfix:close()
	self.open = false --

end
return Hotfix