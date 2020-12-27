--[=[
local modname = "Rainy"
local M = {}
_G[modname] = M
package.loaded[modname] = M

--setmetatable(M,{__index = _G})
--setfenv(1,M)
]=]

M = {}
-- 获取对应目标的存档位置（QQ/Group）
-- target 为目标窗口（QQ or Group）
-- isGroup 为标志，1为群组，0为私聊, 2为战斗轮，3为追逐轮
function M.getPath(target, isGroup)
    isGroup = isGroup or 1
    local userPath = dice.DiceDir()
    if isGroup == 1 then
        userPath = userPath .. "\\RainyData\\Group\\Group" .. tostring(target) .. ".json"
    elseif isGroup == 2 then
        userPath = userPath .. "\\RainyData\\Group\\Combat" .. tostring(target) .. ".json"
    elseif isGroup == 3 then
        userPath = userPath .. "\\RainyData\\Group\\Chase" .. tostring(target) .. ".json"
    else
        userPath = userPath .. "\\RainyData\\QQ\\QQ" .. tostring(target) .. ".json"
    end
    return userPath
end
-- 获取当前用户（QQ/Group）数据
-- isGroup 判断窗口类型，0为QQ，1为Group
function M.getUserState(target, isGroup)
    -- 获取用户数据
    isGroup = isGroup or 1
    local userPath = M.getPath(target, isGroup)
    local userdata = M.decjson(userPath)
    local ischanged = false
    if isGroup == 1 then
        if userdata["KP"] == nil or M.isnum(userdata["KP"]) == false then
            userdata["KP"] = 0
            ischanged = true
        end
        if userdata["Xrastate"] == nil or M.isnum(userdata["Xrastate"]) == false then
            userdata["Xrastate"] = 0
            ischanged = true
        end
        if userdata["Xstshow"] == nil or M.isnum(userdata["Xstshow"]) == false then
            userdata["Xstshow"] = 0
            ischanged = true
        end
        if userdata["Xstset"] == nil or M.isnum(userdata["Xstset"]) == false then
            userdata["Xstset"] = 0
            ischanged = true
        end
        if userdata["Group"] == nil or M.isnum(userdata["Group"]) == false then
            userdata["Group"] = target
            ischanged = true
        end
        if userdata["Xrasetcoc"] == nil or M.isnum(userdata["Xrasetcoc"]) == false then
            userdata["Xrasetcoc"] = 0
            ischanged = true
        end
        if userdata["setcoc"] == nil then
            userdata["setcoc"] = {1, 0, 1, 0, 96, 0, 100, 0, 50}
            ischanged = true
        end
        if ischanged then
            M.saveUserState(userdata, target, isGroup)
        end
    end
    if isGroup == 2 then
        local groupdata = M.getUserState(target, 1)
        if userdata["KP"] == nil or M.isnum(userdata["KP"]) == false then
            userdata["KP"] = groupdata["KP"]
            ischanged = true
        end
        if type(userdata["start"]) ~= "boolean" then -- 战斗轮是否开始
            userdata["start"] = false
            ischanged = true
        end
        if type(userdata["round"]) ~= "number" then -- 当前回合玩家
            userdata["round"] = 1
            ischanged = true
        end
        if userdata["Group"] == nil or M.isnum(userdata["Group"]) == false then
            userdata["Group"] = target
            ischanged = true
        end
        if userdata["setcoc"] == nil then
            userdata["setcoc"] = groupdata["setcoc"]
            ischanged = true
        end
        if type(userdata.list) ~= "table" then
            userdata.list = {}
            ischanged = true
        end
        if ischanged then
            M.saveUserState(userdata, target, isGroup)
        end
    end
    return userdata
end
-- 保存用户数据
-- data 为待保存table
-- target 为窗口号（QQ or Group）
-- isGroup 判断窗口类型，0为QQ，1为Group
function M.saveUserState(data, target, isGroup)
    -- 保存用户数据
    isGroup = isGroup or 1
    local userPath = M.getPath(target, isGroup)
    M.saveTab(data, userPath)
    --return userdata
end
-- 解析json为table
function M.decjson(path)
    -- statements
    local J = require("dkjson")
    local data = M.read_file(path)
    if data == "" then
        return {}
    end
    local dec, pos, err = J.decode(data, 1, nil)
    if err then
        error("Error:" .. err)
    end
    return dec
end
-- 将table变为json后存储在path
function M.saveTab(data, path)
    -- statements
    data = data or ""
    local J = require("dkjson")
    local encdata = J.encode(data, {indent = true})
    --local dec = json.decode(data)
    M.write_file(path, encdata)
end

function M.tabletostring(table)
    local a = ""
    for key, value in pairs(table) do
        a = a .. key .. "=" .. value .. ";\n"
    end
    --a=string.sub(a, 1, -2)
    return a
end

-- 读取对应的文件
-- path -> str ----- 文件路径
function M.read_file(path)
    local text = ""
    local file = io.open(path, "r") -- 打开了文件读写路径
    if (file ~= nil) then -- 如果文件不是空的
        text = file.read(file, "*a") -- 读取内容
        io.close(file) -- 关闭文件
    end
    return text
end

-- 写入对应的文件
-- path -> str ----- 文件路径
-- data -> str ----- 写入内容（全部覆盖写入）
function M.write_file(path, data)
    local file = io.open(path, "w") -- 以只写的方式
    file.write(file, data) -- 写入内容
    io.close(file) -- 关闭文件
end

-- 检测是否为数值
function M.isnum(text)
    return tonumber(text) ~= nil
end

-- 打印各正则表达式
-- Msg  ->  table ----- 为Dice给出聊天信息表
function M.printstr(Msg)
    Msg = Msg or {}
    local resp = ""
    for i = 0, (Msg.str_max - 1), 1 do
        resp = resp .. "str[" .. tostring(i) .. ']:"' .. Msg.str[i] .. '"\n'
    end
    return resp
end

-- 获取数组长度
function M.table_leng(t)
    local leng = 0
    if t == nil then
        return 0
    end
    for k, v in pairs(t) do
        leng = leng + 1
    end
    return leng
end

function M.Rasuccess(total, val, setcoc)
    setcoc = setcoc or {1, 0, 1, 0, 96, 0, 100, 0, 50}
    local i = tonumber(setcoc[9])
    local x = total or 0
    local y = val or 0
    local rank
    if
        ((y < i) and (x <= tonumber(setcoc[1]) + tonumber(setcoc[2]) * val)) or
            ((y >= i) and (x <= tonumber(setcoc[3]) + tonumber(setcoc[4]) * val))
     then
        rank = 1 -- 大成功
    elseif
        ((y < i) and (x >= tonumber(setcoc[5]) + tonumber(setcoc[6]) * val)) or
            ((y >= i) and (x >= tonumber(setcoc[7]) + tonumber(setcoc[8]) * val))
     then
        rank = 6 -- 大失败
    elseif x <= y / 5 then
        rank = 2 -- 极难成功
    elseif x <= y / 2 then
        rank = 3 -- 困难成功
    elseif x <= y then
        rank = 4 -- 成功
    elseif x > y then
        rank = 5 -- 失败
    else
        rank = 0
    end
    return rank
end

return M
