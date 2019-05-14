local skynet = require "skynet"
local cjson = require "cjson"
local sharedata = require "sharedata"
local c = require "skynet.core"
require 'debug'
---------------------------------------------------------------

local dgetinfo = debug.getinfo
local open_path = open_path

local init = true
local file_list = {} -- temp file list
local file_dic = {} -- share_name => share_file
local alter = {}
local config_mgr = {}

-- hot load

local function filetime(file)
    return c.command("FILETIME",file)
end

function config_mgr.share_new( share_name , config)
    print('load sharedata:'..share_name)
    if init then
        file_dic[dgetinfo(2).func] = file_list
        file_list = {}
        sharedata.new(share_name, config)
    else
        sharedata.update(share_name, config)
    end
end

function config_mgr.begin( ... )
    file_list = {}
end

local function hot_load(  )
    while true do
        for share_fun,files in pairs(file_dic) do
            for _,file in ipairs(files) do
                if file[2] ~= filetime(file[1]) then
                    file[2] = filetime(file[1])
                    alter[share_fun] = true
                end
            end
        end
        if next(alter) then
            for share_fun,_ in pairs(alter) do
                share_fun()
            end
            alter = {}
        end

        skynet.sleep(300)
    end
end

function config_mgr.finish()
    init = false
    skynet.fork(hot_load)
end

local function file_montior(file)
    if init then
        table.insert(file_list,{file,filetime(file)})
    end
end

----------------------------------------------------------------------


--- cjson序列化会出现NULL值, 可以通过csjon.null比较
function convert_null(obj, null_v)
    if obj and type(obj) == "table" then
        for k, v in pairs(obj) do
            if v == cjson.null or v == "null" then
                obj[k] = null_v
            elseif type(v) == "table" then
                convert_null(v, null_v)
            end
        end
    end
    return obj
end

function read_file(f)
    local fstr = nil

    local fd = io.open(f, "r")
    if fd then
        fstr = fd:read("*a")
        fd:close()
    end

    return fstr
end

function unpack_array(array)
    local result = {}
    for _, v in pairs(array) do
        result[tostring(v)] = v
    end
    return result
end

function read_lines(f, callback)
    local fd = io.open(f, "r")
    if fd then
        for line in fd:lines() do
            pcall(callback, line)
        end
        fd:close()
    end
end

function read_all_lines(f, callback)
    local fd = io.open(f, "r")
    if fd then
        local all_lines = fd:read("*all")
        pcall(callback, all_lines)
        fd:close()
    end
end

--加载json文件
function load_json_directory(path, ext, callback)
    open_path(path, ext, function(fd)
        local all_lines = fd:read("*all")
        local ok, result = pcall(cjson.decode, all_lines)
        if not ok then
            print('load json path faild:'..path..' err:'..tostring(result))
        elseif result then
            local ok,err = pcall(callback, convert_null(result, ''))
            if not ok then
                print(err)
            end
        end
    end)
end

--加载lua
function load_lua_directory(path, ext, callback)
    open_path(path, ext, function(fd)
        local source = fd:read("*all")
        local tmp = {}
        local f,ok,err
        f, err = load(source, "@"..path, "bt", tmp)
        if not f then
            print(err)
        end
        ok, err = pcall(f)
        if not ok then
            print(err)
        end
        ok,err = pcall(callback, tmp)
        if not ok then
            print(err)
        end
    end)
end

function load_lua_file(path, callback)
    local fd = io.open(path, "r")
    if fd then
        local source = fd:read("*all")
        local tmp = {}
        local f,ok,err
        f, err = load(source, "@"..path, "bt", tmp)
        if not f then
            print(err)
        end
        ok, err = pcall(f)
        if not ok then
            print(err)
        end
        ok,err = pcall(callback, tmp)
        if not ok then
            print(err)
        end
        fd:close()
        file_montior(path)
    end
end

return config_mgr