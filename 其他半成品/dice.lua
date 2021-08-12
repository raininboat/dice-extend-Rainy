
--[=[
#      _____       _
#     |  __ \     (_)
#     | |__) |__ _ _ _ __  _   _
#     |  _  // _` | | '_ \| | | |
#     | | \ \ (_| | | | | | |_| |
#     |_|  \_\__,_|_|_| |_|\__, |
#                           __/ |
#                          |___/
Dice V0.2  by 雨鸣于舟 20210614
需使用Constant.lua , calculate.lua 模块
需使用dkjson库

luaDice重构
已完成：    .st
            .ra
            .sc
            .nn
]=]

command = {}
-- 所有指令类型
command["(\\.|。)(fra|ra)\\s*([bBpP]\\d?)?\\s*([\\D]+)?\\s*([\\d]*)"] = "fra" -- .ra(p) 斗殴 (60)
command["(\\.|。)(frav|rav)\\s*([\\D]+)?\\s*([\\d]*)\\s*(\\[CQ:at,qq=)(\\d{4,})\\]\\s*"] = "frav" -- .rav 斗殴 @群成员
command["(\\.|。)(ti)\\s*(.*)"] = "RollTempInsanity"
command["(\\.|。)(li)\\s*(.*)"] = "RollLongInsanity"
command["(\\.|。)(fst|st)\\s*(.*)"] = "fst"
command["(\\.|。)(fsc|sc)\\s*([0-9dD\\-\\+\\*]+)(/)([0-9dD\\-\\+\\*]+)"] = "fsc" -- .fsc 1/1d3
command["(#set\\s*name|.nn)\\s*([\\D]+)"] =  "setName"
command["([#\\.。])(next\\s*day)\\s*"] =  "nextDay"
command["([#\\.。])(weapon\\s*change)\\s*([\\d]+)"] =  "changeWeapon"
command["([#\\.。])(weapon\\s*add)\\s*([\\D]+)\\s+([\\D]+)\\s+([0-9dDbB\\-\\+\\*]+)"] =  "addWeapon"    -- 添加武器
command["([#\\.。])(weapon\\s*add)\\s*([\\d\\D]+)"] =  "addWeaponAuto"    -- 添加武器
command["([#\\.。])(weapon\\s*list|weapon)"] =  "listWeapon"
-- 本地测试专用信息，正式版需删除
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
package.path = package.path..";D:\\Rainy\\DICE\\XQ_diceserver\\Dice3614566160\\plugin\\lib\\?.lua"
dice = require("dicetest")
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 自定义函数部分 (Rainy.lua)
basic_path = dice.DiceDir()
dice.mkDir(basic_path.."\\RainyData\\group") -- 初始化存档路径
dice.mkDir(basic_path.."\\RainyData\\QQ") -- 初始化存档路径
-- 设置正式版lib位置，正式版需打开
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
package.cpath = package.cpath..";"..basic_path.."\\plugin\\lib\\?.dll"
package.path = package.path..";"..basic_path.."\\plugin\\lib\\?.lua"
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local RD = require("calculate")
local Constant = require("Constant")

-- 自定义部分回复
--[[local customReply = {
    ["stHelp"] = "",
    ["raHelp"] = "",
    ["scHelp"] = ""
}]]

local M = {}
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
    elseif isGroup == 4 then
        userPath = userPath .. "\\RainyData\\QQ\\Fire" .. tostring(target) .. ".json"
    else
        userPath = userPath .. "\\RainyData\\QQ\\QQ" .. tostring(target) .. ".json"
    end
    return userPath
end
-- 获取当前用户（QQ/Group）数据
-- isGroup 判断窗口类型，0为QQ，1为Group , 2为战斗轮（群组） ，3 为追逐轮(未完成) , 4 为向火独行模块
function M.getUserState(target, isGroup)
    -- 获取用户数据
    isGroup = isGroup or 1
    local userPath = M.getPath(target, isGroup)
    local userdata = M.decjson(userPath)
    local ischanged = false
    if isGroup == 0 then
        if userdata["QQ"] == nil or M.isnum(userdata["QQ"]) == false then
            userdata["QQ"] = target
            ischanged = true
        end
        if userdata["name"] == nil then
            userdata["name"] = dice.getPcName(target,0)
            ischanged = true
        end
        if userdata["setcoc"] == nil then
            userdata["setcoc"] = {1, 0, 1, 0, 96, 0, 100, 0, 50}
            ischanged = true
        end
        if type(userdata.skill) ~= "table" then
            userdata.skill= {}
            ischanged = true
        end
        if type(userdata.status) ~= "table" then
            userdata.status= {}
            ischanged = true
        end
        if type(userdata.weapon) ~= "table" then
            userdata.weapon= {
                [1] = {
                    ["name"] = "徒手伤害",
                    ["skill"] = "斗殴",
                    ["damage"] = "1D3+[DB]"
                }
            }
            ischanged = true
        end
        if type(userdata.today) ~= "table" then
            userdata.today= {}
            ischanged = true
        end
        if type(userdata.history) ~= "table" then
            userdata.history= {}
            ischanged = true
        end
        if type(userdata.temp) ~= "table" then
            userdata.temp= {}
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

---返回table内容
---@param table table
---@return string string
function M.tabletostring(table)
    table = table or ""
    local J = require("dkjson")
    local encdata = J.encode(table, {indent = true})
    return encdata
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

-- 获取Master信息（通过console.xml)
function M.getMaster()
    local path = dice.DiceDir().."\\conf\\Console.xml"
    local data = M.read_file(path)      -- 获取xml内容
    if data == "" then
        return 0
    end
    local a,b,_
    _,a = string.find(data,"<master>")
    b,_ = string.find(data,"</master>")
    if a == nil or b == nil then
        return 0
    end
    local master = tonumber(string.sub(data,a+1,b-1))
    return master
end
---检定成功等级判断，1~6为大成功~大失败
---@param total integer 技能值
---@param val integer 检定结果
---@param setcoc table 检定规则
---@return integer rank  检定结果，1~6成功等级，1为大成功
function M.Rasuccess(total,val,setcoc)
    setcoc = setcoc or {1,0,1,0,96,0,100,0,50}
    local i = tonumber(setcoc[9])
    local x = total or 0
    local y = val or 0
    local rank
    if ((y < i) and (x <= tonumber(setcoc[1])+tonumber(setcoc[2])*val)) or ((y >= i) and (x <= tonumber(setcoc[3])+tonumber(setcoc[4])*val)) then
        rank = 1 -- 大成功
    elseif ((y < i) and (x >= tonumber(setcoc[5])+tonumber(setcoc[6])*val)) or ((y >= i) and (x >= tonumber(setcoc[7])+tonumber(setcoc[8])*val)) then
        rank = 6 -- 大失败
    elseif x <= y/5 then
        rank = 2 -- 极难成功
    elseif x <= y/2 then
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
---Ra功能具体实现
---@param nick string 人物名称
---@param skillName string 技能名称
---@param skillVal integer 技能值
---@param sign integer 【可选】奖励骰 or 惩罚骰
---@param setcoc table 【可选】检定规则（大成功大失败判定）
---@return string resp 返回检定信息
---@return integer successLevel 成功度
---{测试昵称} 进行 {技能名称} 检定\n D100= {结果} / {技能值}   {检定结果}
local function Ra(nick,skillName,skillVal,sign,setcoc)
    sign = sign or 0
    local resp = nick.."进行"..skillName.."检定：\n"
    local rollResult
    local successLevel = 0
--    local RD = require("calculate")
    local rankName = {"大成功","极难成功","困难成功","成功","失败","大失败",[0] = "【未知情况】"} -- 因为lua数组从1开始，所有rank也是1~6
    setcoc = setcoc or {1, 0, 1, 0, 96, 0, 100, 0, 50}
    if sign == 0 then
        rollResult = RD.Random(1,100)
        successLevel = M.Rasuccess(rollResult,skillVal,setcoc)
        resp = resp.."D100 = "..tostring(rollResult).."/"..tostring(skillVal).."\t"..rankName[successLevel]
    elseif sign < 0 then
        local rollStep = {}
        local ten = 0
        local one = RD.Random(0,9)
        sign = -sign
        for i = 1, sign+1 , 1 do
            rollStep[i] = RD.Random(0,9)
            if rollStep[i] > ten then
                ten = rollStep[i]
            elseif one == 0 and rollStep[i]==0 then
                ten = 10
                rollStep[i] = 10
            end
        end
        rollResult = ten * 10 + one
        successLevel = M.Rasuccess(rollResult,skillVal)
        resp = resp.."P"..sign.." = "..tostring(rollStep[1])..tostring(one).."[惩罚骰："
        for i = 2,sign,1 do
            resp = resp .. tostring(rollStep[i])..","
        end
        resp = resp..tostring(rollStep[sign+1]).."] = "..rollResult.."/"..tostring(skillVal).."\t"..rankName[successLevel]
    elseif sign > 0 then
        local rollStep = {}
        local ten = 10
        local one = RD.Random(0,9)
        for i = 1, sign+1 , 1 do
            rollStep[i] = RD.Random(0,9)
            if one == 0 and rollStep[i]==0  then
                ten = 10
                rollStep[i] = 10
            elseif rollStep[i] < ten then
                ten = rollStep[i]
            end
        end
        rollResult = ten * 10 + one
        successLevel = M.Rasuccess(rollResult,skillVal)
        resp = resp.."B"..sign.." = "..tostring(rollStep[1])..tostring(one).."[奖励骰："
        for i = 2,sign,1 do
            resp = resp .. tostring(rollStep[i])..","
        end
        resp = resp..tostring(rollStep[sign+1]).."] = "..rollResult.."/"..tostring(skillVal).."\t"..rankName[successLevel]
    end
    return resp,successLevel
end


function setName(msg)
    local QQ = msg.fromQQ
    local playerState = M.getUserState(QQ,0)
    playerState.name = msg.str[2]
    M.saveUserState(playerState,QQ,0)
    return "成功将名称改为："..playerState.name
end

local   function fstHelp()
    return "属性记录：.st (del/clr/show) ([属性名]:[属性值])\n用户默认所有群使用同一张卡\n.st力量:50 体质:55 体型:65 敏捷:45 外貌:70 智力:75 意志:35 教育:65 幸运:75\n.st hp-1 后接+/-时视为从原值上变化\n.st san+1d6 修改属性时可使用掷骰表达式\n.st del kp裁决	//删除已保存的属性\n.st clr	//清空当前卡\n.st show 灵感	//查看指定属性\n.st show	//无参数时查看所有属性，请使用只st加点过技能的半自动人物卡！\n部分COC属性会被视为同义词，如智力/灵感、理智/san、侦查/侦察"
end
--[[
    function fstSet(msg)
    --    local Constant = require("Constant")
        local QQ = msg.fromQQ
        local playerState = M.getUserState(QQ,0)
        local skillName = msg.str[3]
        local skillVal = tonumber(msg.str[4])
        -- 技能转义
        skillName = string.gsub(skillName," ","")
        if Constant.SkillNameReplace[skillName] ~= nil then
            skillName = Constant.SkillNameReplace[skillName]
        end
        playerState.skill[skillName] = skillVal
        M.saveUserState(playerState,QQ,0)
        return "已将"..playerState.name.."的【"..skillName.."】设置为"..skillVal
    end
]]
---Change set skill .st xxx + 1d6
---@param QQ integer
---@param skillName string
---@param playerState table
---@param changeExpression string +1d6
---@return string
local function fstChange(QQ,skillName,playerState,changeExpression)
--    local RD = require("calculate")
--    local Constant = require("Constant")
    local resp = "已记录{playerName}的属性变化：\n{skillName}：{skillVal}{changeExpression}={skillVal}+({changeResult})={skillValResult}"
    local err,result = pcall(RD.Calculate,changeExpression)
    if err == false then
        return "计算表达式错误！请检查表达式x\n计算式："..changeExpression.."\n错误信息："..result
    end
    local skillVal = playerState.skill[skillName] or 0
    if skillVal == 0 and Constant.SkillDefaultVal[skillName]~= nil then
        skillVal = Constant.SkillDefaultVal[skillName]
    end
    resp = string.gsub(resp,"{playerName}",playerState.name)
    resp = string.gsub(resp,"{skillName}",skillName)
    resp = string.gsub(resp,"{skillVal}",skillVal)
    resp = string.gsub(resp,"{changeExpression}",changeExpression)
    resp = string.gsub(resp,"{changeResult}",result)
--    resp = resp .. skillName.."："..skillVal..changeExpression.."="..skillVal.."+("..result..")="
        skillVal = skillVal + result
    resp = string.gsub(resp,"{skillValResult}",skillVal)
    playerState.skill[skillName] = skillVal
    M.saveUserState(playerState,QQ,0)
    return resp
end
---.st del xxx
---@param QQ integer
---@param playerState table
---@param skillName string
---@return string
local function fstDel(QQ,playerState,skillName)
--    local Constant = require("Constant")
    if playerState.skill[skillName] ~= nil then
        playerState.skill[skillName] = nil
        M.saveUserState(playerState,QQ,0)
        return "已将"..playerState.name.."的技能【"..skillName.."】删除"
    else
        return "技能【"..skillName.."】不存在x"
    end
--        return M.tabletostring(msg.str)
end

-- 标准人物卡st导入，使用溯洄，shiki Exp10版之前的st指令（最最早的不带稀奇古怪的那些名称啥的的那种）
local function fstSetLong(QQ,playerState,text)
    local skillName,skillValStr,skillVal
--    local Constant = require("Constant")
    text = string.gsub(text,"[%%%[%]{}%(%)\'\"]","")
    local skillCount = 0
    while text ~= "" do
        skillCount = skillCount+1
        skillName,skillValStr = string.match(text,"(%D+)(%d+)")
        text = string.gsub(text,"(%D+)(%d+)","",1)
        if skillName == nil or skillValStr == nil then
            break
        end
        skillName = string.gsub(skillName," ","")
        if Constant.SkillNameReplace[skillName] ~= nil then
            skillName = Constant.SkillNameReplace[skillName]
        end
        if skillName ~= "" then
            skillVal = tonumber(skillValStr)
            playerState.skill[skillName] = skillVal
        end
        -- print(skillName,skillVal)
    end
    if skillCount == 1 then
        return "技能设置失败x"
--    elseif skillCount == 2 then
--        M.saveUserState(playerState,QQ,0)
--        return "已将"..playerState.name.."的"..skillName.."设置为："..skillVal
    else
        M.saveUserState(playerState,QQ,0)
        return "技能设置成功！"
    end
end
---.st clr
---@param QQ integer
---@param playerState table
---@return string
local function fstClr(QQ,playerState)
    playerState.skill = {}
    M.saveUserState(playerState,QQ,0)
    return "清除人物卡数据成功！"
end
---st show
---@param playerState table
---@return string
local function fstShowAll(playerState)
    local resp = playerState.name.."的技能列表为：\n"
    for i, v in pairs(playerState.skill) do
        resp = resp .. i..":"..v.." "
    end
    return resp
end
---st show xxx
---@param playerState table
---@param skillName string
---@return string
local function fstShowSingle(playerState,skillName)
    local resp = "{playerName}的{skillName}技能值为：{skillVal}"
    local skillVal = playerState.skill[skillName] or 0
    resp = string.gsub(resp,"{playerName}",playerState.name)
    resp = string.gsub(resp,"{skillName}",skillName)
    resp = string.gsub(resp,"{skillVal}",skillVal)
    return resp
end
function fst(msg)
    --[[
##        command["(\\.|。)(fst|st)\\s*(del)\\s*([\\D]+)"] = "fstDel" -- .st 测试 -1d5
##        command["(\\.|。)(fst|st)\\s*(clr)"] = "fstClr" -- .st 测试 -1d5
##        command["(\\.|。)(fst|st)\\s*(show)"] = "fstShow" -- .st 测试 -1d5
##        command["(\\.|。)(fstl|stl)\\s*([\\D\\d]+)\\s*"] = "fstSetLong" -- .st 测试 23
##        command["(\\.|。)(fst|st)\\s*([\\D]+)?\\s*(\\+|\\-)\\s*([0-9dD\\-\\+\\*]+)"] = "fstChange" -- .st 测试 -1d5
    ]]
--    local Constant = require("Constant")
    local QQ = msg.fromQQ
    local playerState = M.getUserState(QQ,0)
    local resp
    local text = string.gsub(msg.str[3],"%s","")
    text = string.gsub(text,"[%%%[%]{}%(%)\'\"]","")
    -- .st
    if text == "" or string.sub(text,1,4) == "help" then
        resp = fstHelp()
        return resp
    end
    -- .st show
    if string.sub(text,1,4) == "show"  then
        if string.len(text) == 4 then
            resp = fstShowAll(playerState)
            return resp
        else
            local skillName = string.sub(text,5,-1)
                -- 技能转义
            skillName = string.gsub(skillName," ","")           -- 去除匹配时多余的空格
            if Constant.SkillNameReplace[skillName] ~= nil then
                skillName = Constant.SkillNameReplace[skillName]
            end
            resp = fstShowSingle(playerState,skillName)
            return resp
        end
    end
    -- .st clr
    if string.sub(text,1,3) == "clr" then
        resp = fstClr(QQ,playerState)
        return resp
    end
    -- .st del xxx
    if string.sub(text,1,3) == "del" then
        local skillName = string.sub(text,4,-1)
        if skillName == ""then
            return "请输入删除技能名称x"
        end
            -- 技能转义
        skillName = string.gsub(skillName," ","")           -- 去除匹配时多余的空格
        if Constant.SkillNameReplace[skillName] ~= nil then
            skillName = Constant.SkillNameReplace[skillName]
        end
        resp = fstDel(QQ,playerState,skillName)
        return resp
    end
    -- .st xxx +1d6
    local setChangeLocation = string.find(text,"[%-%+]")        -- .set xxx [+-] 1d6
    if setChangeLocation ~= nil then
        local skillName = string.sub(text,1,setChangeLocation-1)
            -- 技能转义
        skillName = string.gsub(skillName," ","")           -- 去除匹配时多余的空格
        if Constant.SkillNameReplace[skillName] ~= nil then
            skillName = Constant.SkillNameReplace[skillName]
        end
        local changeExpression = string.sub(text,setChangeLocation,-1)
        resp = fstChange(QQ,skillName,playerState,changeExpression)
        return resp
    end
    -- 其他的st情况(标准st)
    resp = fstSetLong(QQ,playerState,text)
    return resp
end
function fra(msg)
    local QQ = msg.fromQQ
    local playerState = M.getUserState(QQ,0)
    local rawSign = msg.str[3]      -- 奖励骰
    local skillName = msg.str[4]
    local skillVal = tonumber(msg.str[5]) or 0
    local sign = 0          -- 奖励骰惩罚骰，+为奖励骰
    local resp
--    local Constant = require("Constant")
    -- 技能转义
    skillName = string.gsub(skillName," ","")           -- 去除匹配时多余的空格
    if Constant.SkillNameReplace[skillName] ~= nil then
        skillName = Constant.SkillNameReplace[skillName]
    end
    if skillVal == 0 then
        skillVal = playerState.skill[skillName] or 0
        if skillVal == 0 and Constant.SkillDefaultVal[skillName] ~= 0  then
            skillVal = Constant.SkillDefaultVal[skillName]
        end
    end
    --[[ 进行骰点操作 ]]
    -- 奖励骰惩罚骰处理
    if rawSign ~= "" then
        rawSign = string.lower(rawSign)
        if string.len(rawSign) == 1 then
            if rawSign == "b" then
                sign = 1
            elseif rawSign == "p" then
                sign = -1
            else
                sign = 0
            end
        else
            local bp = string.sub(rawSign,1,1)
            local num = string.sub(rawSign,2,-1)
            if bp == "b" then
                sign = tonumber(num)
            elseif bp == "p" then
                sign = -tonumber(num)
            else
                sign = 0
            end
        end
    end
    resp = Ra(playerState.name,skillName,skillVal,sign,playerState.setcoc)
    return resp
end

function frv(msg)
-- command["(\\.|。)(frav|rav)\\s*([\\D]+)?\\s*([\\d]*)\\s*(\\[CQ:at,qq=)(\\d{4,})\\]\\s*"] = "frav" -- .rav 斗殴 @群成员
    local QQ = msg.fromQQ
    local playerState = M.getUserState(QQ,0)
    local skillName = msg.str[3]
    local skillVal = tonumber(msg.str[5]) or 0
    local sign = 0          -- 奖励骰惩罚骰，+为奖励骰
    local resp
--    local Constant = require("Constant")
    -- 技能转义
    skillName = string.gsub(skillName," ","")           -- 去除匹配时多余的空格
    if Constant.SkillNameReplace[skillName] ~= nil then
        skillName = Constant.SkillNameReplace[skillName]
    end
    if skillVal == 0 then
        skillVal = playerState.skill[skillName] or 0
        if skillVal == 0 and Constant.SkillDefaultVal[skillName] ~= 0  then
            skillVal = Constant.SkillDefaultVal[skillName]
        end
    end
    local successLevel
    resp,successLevel = Ra(playerState.name,skillName,skillVal,sign,playerState.setcoc)

    -- 对手检定
    local rivalQQ = tonumber(msg.str[6])
    local rivalPlayerstate = M.getUserState(rivalQQ, 4)
    local rivalSkillVal
    local rivalSuccessLevel, tempResp

    rivalSkillVal = rivalPlayerstate.skill[skillName] or 0
    if rivalSkillVal == 0 and Constant.SkillDefaultVal[skillName] ~= 0  then
        rivalSkillVal = Constant.SkillDefaultVal[skillName]
    end
    tempResp,rivalSuccessLevel = Ra(rivalPlayerstate.name,skillName,rivalSkillVal,0,playerState.setcoc)
    resp = resp.."\n"..tempResp
    local level = 4 -- 困难度，暂时只能普通
    if successLevel>level and rivalSuccessLevel>level then    -- 均失败，平局
        resp = resp .. "\n对抗平局！\t请重新投掷"
    elseif successLevel < rivalSuccessLevel then              -- 对抗成功
        resp = resp .. "\n对抗成功！"
    elseif successLevel > rivalSuccessLevel then              -- 对抗失败
        resp = resp .. "\n对抗失败！"
    elseif successLevel == rivalSuccessLevel then             -- 成功等级相同，比较技能值
        if skillVal < rivalSkillVal then
            resp = resp .. "\n对抗失败！"
        elseif skillVal > rivalSkillVal then
            resp = resp .. "\n对抗成功！"
        elseif skillVal == rivalSkillVal then
            resp = resp .. "\n对抗平局！\t请重新投掷"
        end
    end
    return resp
end
function nextDay(msg)
    local QQ = msg.fromQQ
    local playerState = M.getUserState(QQ,0)
    playerState.today = {
        ["maxSan"] = playerState.skill["理智"] or 0
    }
end
-- SANCHECK! 理智检定部分
function fsc(msg)
    local QQ = msg.fromQQ
    local successExpression = string.lower(msg.str[3])
    local failExpression = string.lower(msg.str[5])
    local playerState = M.getUserState(QQ,0)
    -- 需使用calculate.lua 四则运算算法实现
--    local RD = require("calculate")
--    local group = msg.fromGroup
    local resp = playerState.name.."进行理智检定：\n"
    -- 检定部分
    local san = playerState.skill["理智"] or 0
    if san <= 0 then
        return "理智值未输入或无效，请使用.fst将其设置为正整数"
    end
    local rollResult = RD.Random(1, 100)
    local sanLose
    if playerState.today.maxSan == nil then
        playerState.today.maxSan = san
    elseif playerState.today.maxSan == 0 and san ~= 0 then
        playerState.today.maxSan = san
    end
    if rollResult <= san then
        local err
        err,sanLose = pcall(RD.Calculate,successExpression)
        if not err then
            resp = "成功san损失表达式错误！请检查对应表达式x\n计算式："..successExpression.."\n错误信息："..sanLose
            return resp
        end
        resp = resp .. "D100 = ".. tostring(rollResult).."/"..san.." 成功！\n"
        resp = resp .."理智损失："..successExpression.." = "..sanLose.." , "
        san = san - sanLose
        resp = resp .. "当前理智："..san
    else
        local err
        err,sanLose= pcall(RD.Calculate,failExpression)
        if not err then
            resp = "失败san损失表达式错误！请检查对应表达式x\n计算式："..failExpression.."\n错误信息："..sanLose
            return resp
        end
        resp = resp .. "D100 = ".. tostring(rollResult).."/"..san.." 失败！\n"
        resp = resp .."理智损失："..failExpression.." = "..sanLose.." , "
        san = san - sanLose
        resp = resp .. "当前理智："..san.."\n"
    end

    playerState.skill["理智"]=san    -- 写入人物卡
    if playerState.today.sanLose == nil then
        playerState.today.sanLose = sanLose
    else
        playerState.today.sanLose = playerState.today.sanLose + sanLose
    end
    resp = resp .. "今日已损失："..playerState.today.sanLose.."/"..playerState.today.maxSan.."点(可用.nextday进行重置)"
    if playerState.today.sanLose * 5 >= playerState.today.maxSan then
        resp = resp .."\n已不定性疯狂！"
    elseif sanLose >= 5 then
        resp = resp .."\n已临时性疯狂！"
    end
    M.saveUserState(playerState,QQ,0)
    return resp                          -- 标准sc流程结束
end
function RollTempInsanity(msg)
    local QQ = msg.fromQQ
    local playerState = M.getUserState(QQ,0)
	local status = RD.Random(1,10)
	local text = playerState.name.."疯狂发作-临时症状：\n1D10="..status.."\n"..Constant.TempInsanity[status]
	local temp = RD.Random(1,10)
	local addTxt = "1D10="..tostring(temp)
	text = string.gsub(text,"{0}",addTxt)
	if status == 9 then
		temp = RD.Random(1,100)
		addTxt = "1D100="..tostring(temp)
		text = string.gsub(text,"{1}",addTxt)
		addTxt = Constant.strFear[temp]
		text = string.gsub(text,"{2}",addTxt)
	elseif status == 10 then
		temp = RD.Random(1,100)
		addTxt = "1D100="..tostring(temp)
		text = string.gsub(text,"{1}",addTxt)
		addTxt = Constant.strPanic[temp]
		text = string.gsub(text,"{2}",addTxt)
	end
	return text
end
function RollLongInsanity(msg)
    local QQ = msg.fromQQ
    local playerState = M.getUserState(QQ,0)
	local status = RD.Random(1,10)
	local text = playerState.name.."疯狂发作-总结症状：\n1D10="..status.."\n"..Constant.LongInsanity[status]
	local temp = RD.Random(1,10)
	local addTxt = "1D10="..tostring(temp)
	text = string.gsub(text,"{0}",addTxt)
	if status == 9 then
		temp = RD.Random(1,100)
		addTxt = "1D100="..tostring(temp)
		text = string.gsub(text,"{1}",addTxt)
		addTxt = Constant.strFear[temp]
		text = string.gsub(text,"{2}",addTxt)
	elseif status == 10 then
		temp = RD.Random(1,100)
		addTxt = "1D100="..tostring(temp)
		text = string.gsub(text,"{1}",addTxt)
		addTxt = Constant.strPanic[temp]
		text = string.gsub(text,"{2}",addTxt)
	end
	return text
end

function changeWeapon(msg)
    
end
function listWeapon(msg)
    
end
function addWeapon(msg)
--    local Constant = require("Constant")
    local QQ = msg.fromQQ
    local playerState = M.getUserState(QQ,0)
    local skillName = msg.str[3]
    local skillVal = tonumber(msg.str[4])
    -- 技能转义
    skillName = string.gsub(skillName," ","")
    if Constant.SkillNameReplace[skillName] ~= nil then
        skillName = Constant.SkillNameReplace[skillName]
    end
    playerState.skill[skillName] = skillVal
    M.saveUserState(playerState,QQ,0)
    return "已将"..playerState.name.."的【"..skillName.."】设置为"..skillVal
end

-- 测试部分！

local testmsg = {
    ["fromQQ"] = 10000000,
    ["fromGroup"] = 12345678,
    ["msgType"] = 1,
    ["targetId"] = 12345678,
    ["msg"] = "1",
    ["str"] = {
        [1] = ".",
        [2] = "st",
        [3] = "hp12san"
--        [3] = "力量35str35敏捷70dex70意志87pow87体质45con45外貌55app55教育73edu73体型80siz80智力80灵感80int80san74san值74理智74理智值74幸运45运气45mp17魔法17hp12体力12会计5人类学1估价5考古学50取悦15魅惑15攀爬32计算机5计算机使用5电脑5信用40信誉40信用评级40克苏鲁6克苏鲁神话6cm6乔装5闪避53汽车20驾驶20汽车驾驶20电气维修10电子学1话术5斗殴30斧50手枪50急救50历史45恐吓15跳跃20拉丁文31母语73法律5图书馆65图书馆使用65聆听22开锁1撬锁1锁匠1机械维修10医学1博物学10自然学10领航48导航48神秘学45重型操作1重型机械1操作重型机械1重型1说服10精神分析1心理学10骑术5妙手10侦查75潜行20生存10游泳20投掷20追踪10驯兽5潜水1爆破1读唇1催眠1炮术1																							"
    }
}
print(fst(testmsg))