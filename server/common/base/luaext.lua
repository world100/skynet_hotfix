-- lua扩展
local random = math.random

----------------------------------------------------------------------
-- table扩展 
----------------------------------------------------------------------
-- 返回table大小
table.size = function(t)
	local count = 0
	for _,v in pairs(t) do
		count = count + 1
	end
	return count
end

-- 判断table是否为空
table.empty = function(t)
    return not t or not next(t)
end

-- 返回table索引列表
table.indices = function(t)
    local result = {}
    for k, v in pairs(t) do
        table.insert(result, k)
    end
end

-- 返回table值列表
table.values = function(t)
    local result = {}
    for k, v in pairs(t) do
        table.insert(result, v)
    end
end

-- 浅拷贝
table.clone = function(t, nometa)
    local result = {}
    if not nometa then
        setmetatable(result, getmetatable(t))
    end
    for k, v in pairs (t) do
        result[k] = v
    end
    return result
end

-- 深拷贝
table.copy = function(t, nometa)
    local result = {}

    if not nometa then
        setmetatable(result, getmetatable(t))
    end

    for k, v in pairs(t) do
        if type(v) == "table" then
            result[k] = table.copy(v)
        else
            result[k] = v
        end
    end
    return result
end

function table.deepcopy(t, nometa)
    local lookup_table = {}
    local function _copy(t,nometa)
        if type(t) ~= "table" then
            return t
        elseif lookup_table[t] then
            return lookup_table[t]
        end
        local new_table = {}
        lookup_table[t] = new_table
        for index, value in pairs(t) do
            new_table[_copy(index)] = _copy(value)
        end

        if not nometa then
           new_table = setmetatable(new_table, getmetatable(t))
        end
        
        return new_table
    end
    return _copy(t)
end

--合并
table.merge = function(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

--连接 
table.concatList = function (tb1,tb2)
    if not tb2 then 
        return 
    end
    for _,v in pairs(tb2) do 
        table.insert(tb1,v)
    end
end
-- 颠倒一个数组类型的table
table.reverse = function (tArray)
    if tArray == nil or #tArray == 0 then
        return {}
    end
    local tArrayReversed = {}
    local nArrCount = #tArray
    for i=1, nArrCount do
        tArrayReversed[i] = tArray[nArrCount-i+1]
    end
    return tArrayReversed
end

--table长度
table.len = function(tb)
    local length = 0
    for _,_ in pairs(tb) do
        length = length + 1
    end
    return length
end

--打乱数组
table.mix = function(arr)
    local sz = #arr
    for i = 1 , sz do
        local r = random(i, sz)
        local t = arr[i]
        arr[i] = arr[r]
        arr[r] = t
    end
end

--取子数组
table.sub = function(arr,star,n)
    local len = #arr
    if not n then 
        n = len
    end
    if len < n or len < star then 
        return {}
    end
    local tb = {}
    for i = star, n do
        table.insert(tb,arr[i])
    end    
    return tb
end

--取剩余的数据(不包含star,star+n)
table.subRest = function(arr,star,n)
    local len = #arr
    if not n then 
        n = len
    end
    local tb = {}
    for i=1, star-1 do
        table.insert(tb,arr[i])
    end
    for i=star+n,len do 
        table.insert(tb,arr[i])    
    end
    return tb
end

table.removeSub = function(tb,tbSub)
    if not tbSub or not next(tbSub) then 
        return
    end
    local tbRemove = {}
    local tb2 = table.copy(tb)
    for k,v in pairs(tb2) do 
        for _,card in pairs(tbSub) do 
            if v == card then 
                table.insert(tbRemove,k)
            end
        end
    end
    local function sort(a,b)
        return a>b
    end 
    table.sort(tbRemove,sort)
    for k,v in pairs(tbRemove) do 
        table.remove(tb2,v)
    end    
    return tb2
end
-----------------

----------------------------------------------------------------------
-- string扩展
----------------------------------------------------------------------

-- 下标运算
do
    local mt = getmetatable("")
    local _index = mt.__index

    mt.__index = function (s, ...)
        local k = ...
        if "number" == type(k) then
            return _index.sub(s, k, k)
        else
            return _index[k]
        end
    end
end

string.split = function(s, delim)
    -- if s == nil or s == '' or delim == nil then
    --     return nil
    -- end

    -- local result = {}
    -- for match in (s..delim):gmatch("(.-)"..delim) do
    --     table.insert(result, match)
    -- end

    -- return result

    local split = {}
    local pattern = "[^" .. delim .. "]+"
    string.gsub(s, pattern, function(v) table.insert(split, v) end)
    return split
end

string.ltrim = function(s, c)
    local pattern = "^" .. (c or "%s") .. "+"
    return (string.gsub(s, pattern, ""))
end

string.rtrim = function(s, c)
    local pattern = (c or "%s") .. "+" .. "$"
    return (string.gsub(s, pattern, ""))
end

string.trim = function(s, c)
    return string.rtrim(string.ltrim(s, c), c)
end

string.isnull = function(s)
    return s == nil
end

string.isempty = function(s)
    return s ~= nil and string.trim(s) == ""
end

string.isnull_or_empty = function(s)
    return s == nil or string.trim(s) == ""
end

function string.subUTF8String(s, n)
    local dropping = string.byte(s, n+1)  
    if not dropping then return s end 
    if dropping >= 128 and dropping < 192 then  
        return string.subUTF8String(s, n-1)  
    end 
    return string.sub(s, 1, n)
end

--去除sql中的特殊字符
function string.SQLStr( str_in, bNoQuotes )
    local str = tostring( str_in )
    str = str:gsub( "'", "''" )
    local null_chr = string.find( str, "\0" )
    if null_chr then
        str = string.sub( str, 1, null_chr - 1 )
    end
    if ( bNoQuotes ) then
        return str
    end
    return "'" .. str .. "'"
end

---不会死循环的dump
local function l_dump(tab, _tostring)
    _tostring = _tostring and _tostring or tostring

    local function getkey(k, ktype)
        if ktype == 'number' then
            return '[' .. k .. ']'
        elseif ktype == 'string' then
            return '["' .. k .. '"]'
        else
            return '[' .. _tostring(k) .. ']'  --key可能是table
        end
    end

    local tinsert = table.insert
    local mmax = math.max
    local rep = string.rep
    local gsub = string.gsub
    local format = string.format

    local function dump_obj(obj, key, sp, lv, st)
        local sp = '\t'

        if type(obj) ~= 'table' then
            return sp .. (key or '') .. ' = ' .. tostring(obj) .. '\n'
        end

        local ks, vs, s= { mxl = 0 }, {}
        lv, st =  lv or 1, st or {}

        st[obj] = key or '.' --table对象列表
        key = key or ''
        for k, v in pairs(obj) do
            local ktype, vtype = type(k), type(v)
            if k ~= 'class' and k ~= '__index' and vtype ~= 'function'then
                if vtype == 'table' then
                    if st[v] then --相互引用的table，直接输出
                        vs[#vs + 1] = '[' .. st[v] .. ']'
                        s = sp:rep(lv) .. getkey(k, ktype)
                        tinsert(ks, s)
                        ks.mxl = mmax(#s, ks.mxl)
                    else
                        st[v] = key .. '.' .. _tostring(k) --保存dump过的table，key可能也是table
                        vs[#vs + 1] = dump_obj(v, st[v], sp, lv + 1, st)
                        s = sp:rep(lv) .. getkey(k, ktype)
                        tinsert(ks, s)
                        ks.mxl = mmax(#s, ks.mxl)
                    end
                else
                    if vtype == 'string' then
                        vs[#vs + 1] = (('%q'):format(v):gsub('\\\10','\\n'):gsub('\\r\\n', '\\n'))
                    else
                        vs[#vs + 1] = tostring(v)
                    end
                    s = sp:rep(lv) .. getkey(k, ktype)
                    tinsert(ks, s)
                    ks.mxl = mmax(#s, ks.mxl);
                end
            end
        end

        s = ks.mxl
        for i, v in ipairs(ks) do
            vs[i] = v .. (' '):rep(s - #v) .. ' = ' .. vs[i] .. '\n'
        end

        return '{\n' .. table.concat(vs) .. sp:rep(lv-1) .. '}'
    end

    return dump_obj(tab)
end

dump = l_dump   --兼容需要
---其他地方需要使用原始的tostring
sys_tostring = tostring
do
    local _tostring = tostring
    tostring = function(v)
        if type(v) == 'table' then
            return l_dump(v, _tostring)
        else
            return _tostring(v)
        end
    end
end


----------------------------------------------------------------------
-- math扩展
----------------------------------------------------------------------
-- 
do
	local _floor = math.floor
	math.floor = function(n, p)
		if p and p ~= 0 then
			local e = 10 ^ p
			return _floor(n * e) / e
		else
			return _floor(n)
		end
	end
end

math.round = function(n, p)
        local e = 10 ^ (p or 0)
        return math.floor(n * e + 0.5) / e
end

--4舍5入
math.four_five = function(n)
    if n % 1 >=0.5 then 
        n = math.ceil(n)
    else
        n = math.floor(n)
    end
    return n
end

--设置随机种子
local _randomseed = math.randomseed
function math.randomseed(num)
    --https://www.cnblogs.com/gggzly/p/5947892.html
    if not num then 
        local time = tostring(os.time())
        math.randomseed(time:reverse():sub(1, 7))
    else
        _randomseed(num)
    end

end

----------------------------------------------------------------------
-- lua面向对象扩展
----------------------------------------------------------------------
-- 
function class(classname, super)
	local superType = type(super)
	local cls
	if superType ~= 'function' and superType ~= 'table' then
		superType = nil
		super = nil
	end

	if superType == 'function' or (super and super.__ctype == 1) then
		-- inherited from native C++ Object
		cls = {}
		if superType == 'table' then
			-- copy fields from super
			for k,v in pairs(super) do cls[k] = v end
			cls.__create = super.__create
			cls.super = super
		else
			cls.__create = super
			cls.ctor = function() end
		end
		cls.__cname = classname
		cls.__ctype = 1

		function cls.new(...)
			local instance = cls.__create(...)
			-- copy fields from class to  native object
			for k, v in pairs(cls) do instance[k] = v end
			instance.class = cls
			instance:ctor(...)
			return instance
		end
                cls.New = cls.new
	else
		-- inherited from Lua Object
		if super then
			cls = {}
			setmetatable(cls, {__index = super})
			cls.super = super
		else
			cls = {ctor = function() end}
		end
		cls.__cname = classname
		cls.__ctype = 2 --lua
		cls.__index = cls
        function cls.getName()
            return cls.__cname
        end
		function cls.new(...)
			local instance = setmetatable({}, cls)
			instance.class = cls
			instance:ctor(...)
			return instance
		end
        cls.New = cls.new
	end
	return cls
end

function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

function isclass(o, cname)
    if (not o) or (not cname) then return false end

    local ic = o and (o.__cname == cname)
    if (not ic) and (o and o.super) then
        return isclass(o.super, cname)
    else
        return ic
    end
end

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function tonumber_d(v, default)
    default = default or 0
    return tonumber(v) or default
end

function tostring_d(v, default)
    default = default or ""
    return (v == nil) and default or tostring(v)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------