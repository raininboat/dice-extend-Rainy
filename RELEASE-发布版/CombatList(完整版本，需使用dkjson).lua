--[=[
#      _____       _
#     |  __ \     (_)
#     | |__) |__ _ _ _ __  _   _
#     |  _  // _` | | '_ \| | | |
#     | | \ \ (_| | | | | | |_| |
#     |_|  \_\__,_|_|_| |_|\__, |
#                           __/ |
#                          |___/
    战斗轮回合提醒 V1.1  by 雨鸣于舟 20210530
    （独立版本） 需使用dkjson库

        修复了部分bug，增加了简易help文档
    ]=]
command = {}
-- 战斗轮开始
command["(\\.|。)(fight|combat)\\s*(start|on)"] = "combatStart"
-- 参与角色录入
command["(\\.|。)(fight|combat)\\s*(add)\\s*"] = "combatAdd" -- .combat add
command["(\\.|。)(fight|combat)\\s*(add)\\s*([^\\s]+?)"] = "combatAddName" -- .fight add [name]
command["(\\.|。)(fight|combat)\\s*(add)\\s*([^\\s]+?)\\s+([\\d]{1,3})"] = "combatAddNameDex" -- .fight add [name] [dex]
command["(\\.|。)(fight|combat)\\s*(add)\\s*([^\\s]+?)\\s+([\\d]{1,3})\\s+([\\d]{1,3})"] = "combatAddNameDexFight" -- .fight add [name] [dex] [fight]
command["(\\.|。)(fight|combat)\\s*(add)\\s*([\\d]{1,3})"] = "combatAddDex" -- .fight add [dex]
-- 下一回合
command["(\\.|。)(fight|combat)\\s*(skip|next)"] = "combatNextTurn" -- .fight next
-- command["(\\.|。|\\\\|\\/)(next)"] = "combatNextTurn" -- \next /next
-- 战斗轮结束
command["(\\.|。)(fight|combat)\\s*(stop|off)"] = "combatStop" -- .fight stop
-- 战斗轮人员移除(PC)
command["(\\.|。)(fight|combat)\\s*(rm|remove)\\s*(\\[CQ:at,qq=)(\\d{4,})\\]\\s*"] = "combatRemovePC" -- .fight rm [at]
-- 战斗轮人员移除(NPC)
command["(\\.|。)(fight|combat)\\s*(rm|remove)\\s*([^\\s^\\[\\]]+?)"] = "combatRemoveNPC" -- .fight rm [name]
-- 清空战斗轮
command["(\\.|。)(fight|combat)\\s*(clr|clear|reset)"] = "combatClear" -- .combat clr
-- 显示当前战斗轮参与角色列表
command["(\\.|。)(fight|combat)\\s*(show)"] = "combatShow" -- .combat show
-- 战斗轮功能设置

-- 战斗轮help
command["(\\.|。)(fight|combat)\\s*(help)"] = "combatHelp" -- .combat help




-- 自定义函数部分 (Rainy.lua)
basic_path = dice.DiceDir()
dice.mkDir(basic_path.."\\RainyData\\group") -- 初始化存档路径
dice.mkDir(basic_path.."\\RainyData\\QQ") -- 初始化存档路径


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
    else
        userPath = userPath .. "\\RainyData\\QQ\\QQ" .. tostring(target) .. ".json"
    end
    return userPath
end
-- 获取当前用户（QQ/Group）数据
-- isGroup 判断窗口类型，0为QQ，1为Group , 2为战斗轮（群组） ，3 为追逐轮
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
        if userdata["Group"] == nil or M.isnum(userdata["Group"]) == false then
            userdata["Group"] = target
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


--[=[
#      _____       _
#     |  __ \     (_)
#     | |__) |__ _ _ _ __  _   _
#     |  _  // _` | | '_ \| | | |
#     | | \ \ (_| | | | | | |_| |
#     |_|  \_\__,_|_|_| |_|\__, |
#                           __/ |
#                          |___/
    战斗轮回合提醒  by 雨鸣于舟 20201226
]=]


local Mod = M

-- 战斗轮开始
function combatStart(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local resp
    local group = tonumber(msg.fromGroup)
    local combat = Mod.getUserState(group, 2)
    if combat.start then
        resp = "本群已经开启战斗轮模式，无法再次开启！"
        return resp
    end
    local leng = Mod.table_leng(combat.list)
    if leng >= 1 then
        combat.start = true
        resp = "已开启战斗轮并恢复先前保留战斗轮模式数据！\n"
        resp = resp .. "当前战斗轮回合玩家为：【" .. combat.round .. "】 "
        resp = resp .. combat.list[combat.round]["name"] .. " (" .. combat.list[combat.round]["QQ"] .. ")\n"
        resp = resp .. "### 当前战斗人员列表：\n"
        for i = 1, Mod.table_leng(combat.list), 1 do
            resp = resp .. "[" .. i .. "] " .. combat.list[i]["name"] .. " ("
            resp = resp .. combat.list[i]["QQ"] .. ")  DEX = " .. combat.list[i]["Dex"] .. "\n"
        end
    else
        combat.start = true
        resp = "已开启战斗轮！"
    end
    Mod.saveUserState(combat, group, 2)
    return "" .. resp
end
function combatAdd(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local QQ = msg.fromQQ
    local name = dice.getPcName(QQ, group)
    local dex = dice.getPcSkill(QQ, group, "敏捷")
    local fight = dice.getPcSkill(QQ, group, "斗殴")
    combatAddMain(group, name, dex, QQ, fight)
    return ""
end
function combatAddName(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local QQ = msg.fromQQ
    local name = msg.str[4]
    local dex = dice.getPcSkill(QQ, group, "敏捷")
    local fight = dice.getPcSkill(QQ, group, "斗殴")
    combatAddMain(group, name, dex, QQ, fight)
    return ""
end
function combatAddNameDex(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = tonumber(msg.fromGroup)
    local QQ = tonumber(msg.fromQQ)
    local name = msg.str[4]
    local dex = tonumber(msg.str[5])
    combatAddMain(group, name, dex, QQ)
    return ""
end
function combatAddNameDexFight(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = tonumber(msg.fromGroup)
    local QQ = tonumber(msg.fromQQ)
    local name = msg.str[4]
    local dex = tonumber(msg.str[5])
    local fight = tonumber(msg.str[6])
    combatAddMain(group, name, dex, QQ, fight)
    return ""
end
function combatAddDex(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = tonumber(msg.fromGroup)
    local QQ = tonumber(msg.fromQQ)
    local name = dice.getPcName(QQ, group)
    local dex = tonumber(msg.str[4])
    local fight = dice.getPcSkill(QQ, group, "斗殴")
    combatAddMain(group, name, dex, QQ, fight)
end
-- 角色录入主程序
-- 输入： group 群号； name 角色名称； dex 角色敏捷值（用于排攻击顺序）； qq 角色所属qq号
-- 返回： list 攻击顺序表, err 发生错误
function combatAddMain(group, name, dex, qq, fight)
    local combat = Mod.getUserState(group, 2)
    local resp = "添加角色【" .. name .. "】成功！\n"
    if combat.start == false then
        dice.send("当前战斗轮已关闭，请开启后使用！", group, 1)
        return nil
    end
    local s = 1
    while s <= Mod.table_leng(combat.list) do
        if combat.list[s]["name"] == name then
            resp = "设置战斗轮新角色失败！\n"
            resp = resp .. "该名称【" .. name .. "】已经存在"
            dice.send(resp, group, 1)
            return nil
        end
        s = s + 1
    end
    fight = tonumber(fight) or 0
    table.insert(combat["list"], {name = name, QQ = tonumber(qq), Dex = tonumber(dex), fight = tonumber(fight)})
    table.sort(
        combat["list"],
        function(a, b)
            if a.Dex == b.Dex then
                a.fight = a.fight or 0
                b.fight = b.fight or 0
                return a.fight > b.fight
            end
            return a.Dex > b.Dex
        end
    )
    Mod.saveUserState(combat, group, 2)
    resp = resp .. "### 当前战斗角色列表：\n"
    for i = 1, Mod.table_leng(combat.list), 1 do
        resp = resp .. "[" .. i .. "] " .. combat.list[i]["name"] .. " ("
        resp = resp .. combat.list[i]["QQ"] .. ")  DEX = " .. combat.list[i]["Dex"] .. "\n"
    end
    dice.send(resp, group, 1)
end
-- 显示当前战斗轮状态
function combatShow(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local combat = Mod.getUserState(group, 2)
    if combat.start == false then
        return "当前战斗轮已关闭，请开启后使用！"
    end
    local resp
    local leng = Mod.table_leng(combat.list)
    if leng == 0 then
        return "当前战斗轮为空，请先使用.combat add 添加角色！"
    end
    resp = "当前战斗轮回合角色为：【" .. combat.round .. "】 "
    resp = resp .. combat.list[combat.round]["name"] .. " (" .. combat.list[combat.round]["QQ"] .. ")\n"
    resp = resp .. "### 当前战斗角色列表：\n"
    for i = 1, Mod.table_leng(combat.list), 1 do
        resp = resp .. "[" .. i .. "] " .. combat.list[i]["name"] .. " ("
        resp = resp .. combat.list[i]["QQ"] .. ")  DEX = " .. combat.list[i]["Dex"] .. "\n"
    end
    return resp
end
-- 下回合
function combatNextTurn(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local combat = Mod.getUserState(group, 2)
    if combat.start == false then
        return "当前战斗轮已关闭，请开启后使用！"
    end
    local resp
    local leng = Mod.table_leng(combat.list)
    if leng == 0 then
        return "当前战斗轮为空，请先使用.combat add 添加角色！"
    end
    resp = "角色 【" .. combat.list[combat.round]["name"] .. "】(" .. combat.list[combat.round]["QQ"] .. ") 的回合结束\n"
    combat.round = combat.round + 1

    if combat.round > leng then
        combat.round = 1
    end
    resp = resp .. "角色 [" .. combat.round .. "] 【" .. combat.list[combat.round]["name"] .. "】 [CQ:at,qq="
    resp = resp .. combat.list[combat.round]["QQ"] .. "] 回合开始！\f"
    resp = resp .. "### 当前战斗角色列表：\n"
    for i = 1, leng, 1 do
        resp = resp .. "[" .. i .. "] " .. combat.list[i]["name"] .. " ("
        resp = resp .. combat.list[i]["QQ"] .. ")  DEX = " .. combat.list[i]["Dex"] .. "\n"
    end
    Mod.saveUserState(combat, group, 2)
    return resp
end

function combatClear(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local combat = Mod.getUserState(group, 2)
    combat.list = {}
    combat.round = 1
    combat.start = false
    Mod.saveUserState(combat, group, 2)
    local resp = "已清除本群战斗轮信息！"
    return resp
end

function combatStop(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local combat = Mod.getUserState(group, 2)
    combat.start = false
    Mod.saveUserState(combat, group, 2)
    local resp = "本群战斗轮已暂停！\n"
    resp = resp .. "如需恢复请使用 .combat on \n "
    resp = resp .. "如需清除数据请使用 .combat clr"
    return resp
end

function combatRemovePC(msg)
    local resp
    local QQ = tonumber(msg.str[5])
    local group = tonumber(msg.fromGroup)
    local s = 1
    local count = 0
    local del = 0
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local combat = Mod.getUserState(group, 2)
    if combat.start == false then
        return "当前战斗轮已关闭，请开启后使用！"
    end
    local leng = Mod.table_leng(combat.list)
    if leng == 0 then
        return "当前战斗轮为空，请先使用.combat add 添加角色！"
    end

    while s <= Mod.table_leng(combat.list) do
        if combat.list[s]["QQ"] == QQ then
            count = count + 1
            del = s
        end
        s = s + 1
    end
    if count > 1 then
        resp = "有多个角色正在参与战斗论，请使用 .combat rm [角色名] 进行删除!"
        return resp
    elseif count == 0 then
        resp = "你没有角色正参与战斗论，无法删除！"
        return resp
    elseif del == 0 then
        resp = "没有该角色！"
        return resp
    end
    resp = "删除战斗论列表角色【" .. combat.list[del]["name"] .. "】成功！\n"

    leng = Mod.table_leng(combat.list)
    if leng <= 1 then
        combat.round = 1
        combat.list = {}
        combat.start = false
        Mod.saveUserState(combat, group, 2)
        resp = resp .. "当前战斗轮列表无角色！\n"
        resp = resp .. "已自动关闭战斗论模式！如需使用请重新开启！"
        return resp
    else
        if combat.round > del then
            combat.round = combat.round - 1
        end
    end

    if del >= 1 and del < leng then
        combat.list[del], combat.list[leng] = combat.list[leng], nil
    elseif del == leng then
        combat.list[leng] = nil
    else
        return "未知错误！\ndel = " .. tostring(del) .. " ; leng = " .. tostring(leng)
    end

    table.sort(
        combat["list"],
        function(a, b)
            if a.Dex == b.Dex then
                a.fight = a.fight or 0
                b.fight = b.fight or 0
                return a.fight > b.fight
            end
            return a.Dex > b.Dex
        end
    )

    Mod.saveUserState(combat, group, 2)
    resp = resp .. "### 当前战斗角色列表：\n"
    for i = 1, Mod.table_leng(combat.list), 1 do
        resp = resp .. "[" .. i .. "] " .. combat.list[i]["name"] .. " ("
        resp = resp .. combat.list[i]["QQ"] .. ")  DEX = " .. combat.list[i]["Dex"] .. "\n"
    end
    return resp
end

function combatRemoveNPC(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end

    local resp = ""
    local name = msg.str[4]
    local group = tonumber(msg.fromGroup)
    local combat = Mod.getUserState(group, 2)
    local s = 1
    local count = 0
    local del = 0
    if combat.start == false then
        return "当前战斗轮已关闭，请开启后使用！"
    end
    local leng = Mod.table_leng(combat.list)
    if leng == 0 then
        return "当前战斗轮为空，请先使用.combat add 添加角色！"
    end

    while s <= Mod.table_leng(combat.list) do
        if combat.list[s]["name"] == name then
            count = count + 1
            del = s
        end

        s = s + 1
    end
    if count > 1 then
        resp = "发生错误！有多个同名角色正在参与战斗轮！\n请尽快使用 .combat clr 进行复位！"
        return resp
    elseif del == 0 then
        resp = "没有该名称【" .. name .. "】角色！"
        return resp
    elseif count == 0 then
        resp = "你没有角色正参与战斗论，无法删除！"
        return resp
    end
    resp = "删除战斗论列表角色"..del.."【" .. combat.list[del]["name"] .. "】成功！\n"

    leng = Mod.table_leng(combat.list)
    if leng <= 1 then
        combat.round = 1
        combat.list = {}
        combat.start = false
        Mod.saveUserState(combat, group, 2)
        resp = resp .. "当前战斗轮列表无角色！\n"
        resp = resp .. "已自动关闭战斗论模式！如需使用请重新开启！"
        return resp
    elseif leng > 1 then
        if combat.round > del then
            combat.round = combat.round - 1
        end
    end

    if del >= 1 and del < leng then
        combat.list[del], combat.list[leng] = combat.list[leng], nil
    elseif del == leng then
        combat.list[leng] = nil
    else
        return "未知错误！\ndel = " .. tostring(del) .. " ; leng = " .. tostring(leng)
    end

    table.sort(
        combat["list"],
        function(a, b)
            if a.Dex == b.Dex then
                a.fight = a.fight or 0
                b.fight = b.fight or 0
                return a.fight > b.fight
            end
            return a.Dex > b.Dex
        end
    )

    Mod.saveUserState(combat, group, 2)
    resp = resp .. "### 当前战斗角色列表：\n"
    for i = 1, Mod.table_leng(combat.list), 1 do
        resp = resp .. "[" .. i .. "] " .. combat.list[i]["name"] .. " ("
        resp = resp .. combat.list[i]["QQ"] .. ")  DEX = " .. combat.list[i]["Dex"] .. "\n"
    end
    return resp
end

function combatHelp(msg)
    local resp =   "添加战斗轮角色  .combat add ([角色名称]) ([敏捷]) ([斗殴]) \n"
    resp = resp .. "下一角色 .combat next \n"
    resp = resp .. "战斗轮开始|停止|清空|显示 .combat start|stop|clr|show \n"
    resp = resp .. "删除某pl角色 .combat rm [at某PL] \n   或者 .fight rm [角色名称] \n"
    return resp
end

