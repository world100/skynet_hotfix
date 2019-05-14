--
-- Author:      name
-- DateTime:    2019-04-30 10:59:15
-- Description: 协议加载模块


local skynet = require "skynet"
local log = require "Logger"
local parser = require "parser"
local protobuf = require "protobuf"
local sharedata = require "sharedata"


local dir_list = dir_list

local ProtoLoader = class("ProtoLoader")

-- 构造
function ProtoLoader:ctor()

end

--解析enum 类型
local function parserEnumType(enum_type)
    local enum = {}

    if enum_type then
        for _, field in ipairs(enum_type) do
            enum[field.name] = {}
            local first = false
            for _, value in ipairs(field.value) do
                if first == false then
                    first = true
                    if string.find(value.name, "^DMSG_[%w_]*_MSG$") then
                        enum[field.name][1] = value.name
                    end
                end
                enum[field.name][value.name] = value.number
            end
        end
    end

    return enum
end

--解析message类型
local function parserMessageType(message_type)
    local message = {}

    if message_type then
        for _, message_field in ipairs(message_type) do
            message[message_field.name] = {}
            for _, field in ipairs(message_field.field) do
                message[message_field.name][field.name] = field.number
            end
        end
    end

    return message
end

--解析proto文件内容
local function parserPackage(proto_data)

    local package = {}
    
    if proto_data then
        for _, proto_package in ipairs(proto_data) do
            local enum_type = proto_package.enum_type
            local message_type = proto_package.message_type
            
            local one_package = {}
            one_package["package"] = proto_package.package or ""
            one_package["enum_type"] = parserEnumType(enum_type)
            one_package["message_type"] = parserMessageType(message_type)
            table.insert(package, one_package)
        end
    end

	return package
end

--解析消息包
local function parserMessagePackage(message_package)

    local message_cmd = {}
    local message_map = {}
    local message_name_map = {} --name -> main_id,sub_id

    if message_package and type(message_package) == "table" then
        for _, this_package in ipairs(message_package) do
            for _, package in ipairs(this_package) do
                for enum_type, enum_field in pairs(package.enum_type) do
                    
                    local pos = string.find(enum_type, "MsgType$")
                    --消息映射
                    if pos and enum_type ~= "MainMsgType" then
                        local first_enum_name = enum_field[1]
                        if first_enum_name then
                            local main_cmd_id = enum_field[first_enum_name] 
                            if not message_map[main_cmd_id] then message_map[main_cmd_id] = {} end

                            for name, value in pairs(enum_field) do
                                if type(name) == "string" and first_enum_name ~= name then 
                                    -- local message_name = string.gsub(name, "^D", "") 
                                    local subStr = string.sub(name,1,1)
                                    -- print(subStr)
                                    local message_name = string.gsub(name,"^"..subStr,string.lower(subStr))                                    
                                    local message = package.message_type[message_name] 

                                    if message then 
                                        message_map[main_cmd_id][value] = message_name 
                                        message_name_map[message_name] = {
                                            main_id = main_cmd_id,
                                            sub_id = value,
                                        }
                                    else
                                        message_map[main_cmd_id][value] = ''
                                    end
                                end
                            end
                        end
                    end

                    --消息命令
                    if pos then
                        local first_enum_name = enum_field[1]
                        for enum_name, enum_value in pairs(enum_field) do
                            if not (first_enum_name == enum_name or 1 == enum_name) then
                                if not message_cmd[enum_name] then
                                    message_cmd[enum_name] = enum_value
                                else
                                    log.error("parserMessagePackage this message command the same:", enum_name)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- print("__message_map__",message_map)
    -- print("__message_name_map__",message_name_map)
    -- print("__message_cmd____",message_cmd)

    --注意不能 加载 两次一样的 sharedata.new 
    sharedata.new('message_cmd', message_cmd)
    sharedata.new('message_map', message_map)
    sharedata.new('message_name_map', message_name_map)

end

-- 初始化
function ProtoLoader:init(path, dirs)

	if not dirs then 
		dirs = {''} 
		if path:sub(#path) == '/' then 
			path = path:sub(1, #path-1)
		end
	end

    local message_package = {}
	for _, dir in ipairs(dirs) do
		local dir_path = path .. dir
		local file_list = dir_list(dir_path)
        local proto_data = self:load(file_list, dir_path)
        table.insert(message_package, parserPackage(proto_data))
    end

    parserMessagePackage(message_package)

    -- print("___message_name_map_",message_name_map)
	return protobuf.get_protobuf_env()
end

-- 加载协议文件
function ProtoLoader:load(proto_file, proto_path)

	local ok, result = x_pcall(parser.register, proto_file, proto_path)
    if not ok or not result then
        log.error("加载proto文件错误___ProtoLoader:load ", tostring(proto_file), tostring(result))
		return nil
	else
        -- print("___###########_", proto_file)
        return result
	end
end


return ProtoLoader
