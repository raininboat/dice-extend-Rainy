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

command = {}
-- 战斗轮开始
command["(\\.|。)(fight|combat)\\s*(start|on)"] = "combatStart"
-- 参与角色录入
command["(\\.|。)(fight|combat)\\s*(add)\\s*"] = "combatAdd" -- .combat add
command["(\\.|。)(fight|combat)\\s*(add)\\s*(\\D[\\w]*?)"] = "combatAddName" -- .fight add [name]
command["(\\.|。)(fight|combat)\\s*(add)\\s*(\\D[\\w]*?)\\s+([\\d]+?)"] = "combatAddNameDex" -- .fight add [name] [dex]
command["(\\.|。)(fight|combat)\\s*(add)\\s*(\\D[\\w]*?)\\s+([\\d]+?)\\s+([\\d]+?)"] = "combatAddNameDexFight" -- .fight add [name] [dex] [fight]
command["(\\.|。)(fight|combat)\\s*(add)\\s*([\\d]+?)"] = "combatAddDex" -- .fight add [dex]
-- 下一回合
command["(\\.|。)(fight|combat)\\s*(skip|next)"] = "combatNextTurn"
-- command["(\\.|。|\\\\|\\/)(next)"] = "combatNextTurn" -- \next /next
-- 战斗轮结束
command["(\\.|。)(fight|combat)\\s*(stop|off)"] = "combatStop" -- .fight stop
-- 战斗轮人员移除(PC)
command["(\\.|。)(fight|combat)\\s*(rm|remove)\\s*(\\[CQ:at,qq=)(\\d{4,})\\]"] = "combatRemovePC" -- .fight rm [at]
-- 战斗轮人员移除(NPC)
command["(\\.|。)(fight|combat)\\s*(rm|remove)\\s*(\\D[\\w]*?)"] = "combatRemoveNPC" -- .fight rm [name]
-- 清空战斗轮
command["(\\.|。)(fight|combat)\\s*(clr|clear|reset)"] = "combatClear" -- .combat clr
-- 显示当前战斗轮参与角色列表
command["(\\.|。)(fight|combat)\\s*(show)"] = "combatShow" -- .combat show
-- 战斗轮功能设置

local Mod = require("Rainy")

-- 战斗轮开始
function combatStart(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local resp
    local group = tonumber(msg.fromGroup)
    local combat = Mod.getUserState(group,2)
    if combat.start then
        resp = "本群已经开启战斗轮模式，无法再次开启！"
        return resp
    end
    if type(combat.list) == "table" then
        combat.start = true
        resp = "已开启战斗轮并恢复先前保留战斗轮模式数据！\n"
        resp = resp .. "当前战斗轮回合玩家为：【"..combat.round.."】 "
        resp = resp .. combat.list[combat.round]["name"].." ("..combat.list[combat.round]["QQ"]..")\n"
        resp = resp .. "### 当前战斗人员列表：\n"
        for i = 1, Mod.table_leng(combat.list), 1 do
            resp = resp .."["..i.."] "..combat.list[i]["name"].." ("
            resp = resp .. combat.list[i]["QQ"]..")  DEX = "..combat.list[i]["Dex"].."\n"
        end
    else
        combat.start = true
        resp = "已开启战斗轮！"
    end
    Mod.saveUserState(combat,group,2)
    return ""..resp
end
function combatAdd(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local QQ = msg.fromQQ
    local name = dice.getPcName(QQ,group)
    local dex = dice.getPcSkill(QQ,group,"敏捷")
    local fight = dice.getPcSkill(QQ,group,"斗殴")
    combatAddMain(group,name,dex,QQ,fight)
end
function combatAddName(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local QQ = msg.fromQQ
    local name = msg.str[4]
    local dex = dice.getPcSkill(QQ,group,"敏捷")
    local fight = dice.getPcSkill(QQ,group,"斗殴")
    combatAddMain(group,name,dex,QQ,fight)
end
function combatAddNameDex(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local QQ = msg.fromQQ
    local name = msg.str[4]
    local dex = tonumber(msg.str[5])
    combatAddMain(group,name,dex,QQ)
end
function combatAddNameDexFight(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local QQ = msg.fromQQ
    local name = msg.str[4]
    local dex = tonumber(msg.str[5])
    local fight = tonumber(msg.str[6])
    combatAddMain(group,name,dex,QQ,fight)
end
function combatAddDex(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local QQ = msg.fromQQ
    local name = dice.getPcName(QQ,group)
    local dex = tonumber(msg.str[4])
    local fight = dice.getPcSkill(QQ,group,"斗殴")
    combatAddMain(group,name,dex,QQ,fight)
end
-- 角色录入主程序
-- 输入： group 群号； name 角色名称； dex 角色敏捷值（用于排攻击顺序）； qq 角色所属qq号
-- 返回： list 攻击顺序表, err 发生错误
function combatAddMain(group,name,dex,qq,fight)
    local combat = Mod.getUserState(group,2)
    local resp = "添加角色【"..name.."】成功！\n"
    if combat.start == false then
        dice.send("当前战斗轮已关闭，请开启后使用！",group,1)
        return
    end
    local s = 1
    while s <= Mod.table_leng(combat.list) do
        if combat.list[s]["name"] == name then
            resp = "设置战斗轮新角色失败！\n"..""
            dice.send("当前战斗轮已关闭，请开启后使用！",group,1)
            return
        end
        s = s+1
    end
    fight = tonumber(fight) or 0
    table.insert(combat["list"],{name = name , QQ = tonumber(qq) ,Dex = tonumber(dex),Fight = tonumber(fight) })
    table.sort(combat["list"],function (a, b)
        if a.Dex == b.Dex then 
            a.fight =a.fight or 0
            b.fight = b.fight or 0
            return a.fight > b.fight
        end
        return a.Dex > b.Dex
    end)
    Mod.saveUserState(combat,group,2)
    resp = resp .. "### 当前战斗角色列表：\n"
    for i = 1, Mod.table_leng(combat.list), 1 do
        resp = resp .."["..i.."] "..combat.list[i]["name"].." ("
        resp = resp .. combat.list[i]["QQ"]..")  DEX = "..combat.list[i]["Dex"].."\n"
    end
    dice.send(resp,group,1)
end
-- 显示当前战斗轮状态
function combatShow(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local combat = Mod.getUserState(group,2)
    if combat.start == false then
        return "当前战斗轮已关闭，请开启后使用！"
    end
    local resp
    resp = "当前战斗轮回合角色为：【"..combat.round.."】 "
    resp = resp .. combat.list[combat.round]["name"].." ("..combat.list[combat.round]["QQ"]..")\n"
    resp = resp .. "### 当前战斗角色列表：\n"
    for i = 1, Mod.table_leng(combat.list), 1 do
        resp = resp .."["..i.."] "..combat.list[i]["name"].." ("
        resp = resp .. combat.list[i]["QQ"]..")  DEX = "..combat.list[i]["Dex"].."\n"
    end
    return resp
end
-- 下回合
function combatNextTurn(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local combat = Mod.getUserState(group,2)
    if combat.start == false then
        return "当前战斗轮已关闭，请开启后使用！"
    end
    local resp
    resp = "角色 【"..combat.list[combat.round]["name"].."】("..combat.list[combat.round]["QQ"]..") 的回合结束\n"
    combat.round = combat.round + 1
    local leng = Mod.table_leng(combat.list)
    if combat.round > leng then combat.round = 1 end
    resp = resp .. "角色 ["..combat.round.."] 【"..combat.list[combat.round]["name"].."】 [CQ:at,qq="..combat.list[combat.round]["QQ"]
    resp = resp .. "] 回合开始！\f"
    resp = resp .. "### 当前战斗角色列表：\n"
    for i = 1, leng , 1 do
        resp = resp .."["..i.."] "..combat.list[i]["name"].." ("
        resp = resp .. combat.list[i]["QQ"]..")  DEX = "..combat.list[i]["Dex"].."\n"
    end
    Mod.saveUserState(combat,group,2)
    return resp
end

function combatClear(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local combat = Mod.getUserState(group,2)
    combat.list = nil
    combat.round = 1
    combat.start = false
    Mod.saveUserState(combat,group,2)
    local resp = "已清除本群战斗轮信息！"
    return resp
end

function combatStop(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local group = msg.fromGroup
    local combat = Mod.getUserState(group,2)
    combat.start = false
    Mod.saveUserState(combat,group,2)
    local resp = "本群战斗轮已暂停！\n"
    resp = resp .. "如需恢复请使用 .combat on \n "
    resp = resp .. "如需清除数据请使用 .combat clr"
    return resp
end

function combatRemovePC(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local combat = Mod.getUserState(group,2)
    if combat.start == false then
        return "当前战斗轮已关闭，请开启后使用！"
    end
    local resp
    local QQ = tonumber(msg.str[5])
    local group = tonumber(msg.fromGroup)
    local s = 1
    local count = 0
    local del = 0
    while s <= Mod.table_leng(combat.list) do
        if combat.list[s]["QQ"] == QQ then
            count = count + 1
            del = s
        end
        s = s+1
    end
    if count > 1 then
        resp = "你有多个角色正在参与战斗论，请使用 .combat rm [角色名] 进行删除!"
            return resp
    elseif count == 0 then
        resp = "你没有角色正参与战斗论，无法删除！"
        return resp
    elseif del == 0 then
        resp = "没有该角色！"
        return resp
    end
    resp = "删除战斗论列表角色【"..combat.list[del]["name"].."】成功！\n"
    
    local leng = Mod.table_leng(combat.list)
    if leng <= 1 then
        combat.round = 1
        combat.list = nil
        combat.start = false
        Mod.saveUserState(combat,group,2)
        resp = resp .. "当前战斗轮列表无角色！\n"
        resp = resp .. "已自动关闭战斗论模式！如需使用请重新开启！"
        return resp
    elseif leng > 1 then
        if combat.round > del then
            combat.round = combat.round - 1
        end
    end

    if del >= 1 and del <= leng then 
        combat.list[del] , combat.list[leng] = combat.list[leng],nil 
    else 
        return "未知错误！\ndel = "..tostring(del).." ; leng = "..tostring(leng)
    end

    table.sort(combat["list"],function (a, b)
        if a.Dex == b.Dex then 
            a.fight =a.fight or 0
            b.fight = b.fight or 0
            return a.fight > b.fight
        end
        return a.Dex > b.Dex
    end)

    Mod.saveUserState(combat,group,2)
        resp = resp .. "### 当前战斗角色列表：\n"
    for i = 1, Mod.table_leng(combat.list), 1 do
        resp = resp .."["..i.."] "..combat.list[i]["name"].." ("
        resp = resp .. combat.list[i]["QQ"]..")  DEX = "..combat.list[i]["Dex"].."\n"
    end
    return resp
end

function combatRemoveNPC(msg)
    if msg.msgType == 0 then
        return "请在群聊中使用该指令"
    end
    local combat = Mod.getUserState(group,2)
    if combat.start == false then
        return "当前战斗轮已关闭，请开启后使用！"
    end
    local resp
    local name = msg.str[4]
    local group = tonumber(msg.fromGroup)
    local s = 1
    local count = 0
    local del = 0
    while s <= Mod.table_leng(combat.list) do
        if combat.list[s]["name"] == name then
            count = count + 1
            del = s
        end
        s = s+1
    end
    if count > 1 then
        resp = "发生错误！有多个同名角色正在参与战斗轮！\n请尽快使用 .combat clr 进行复位！"
        return resp
    elseif del == 0 then
        resp = "没有该名称【"..name.."】角色！"
        return resp
    elseif count == 0 then
        resp = "你没有角色正参与战斗论，无法删除！"
        return resp
    end
    resp = "删除战斗论列表角色【"..combat.list[del]["name"].."】成功！\n"
    
    local leng = Mod.table_leng(combat.list)
    if leng <= 1 then
        combat.round = 1
        combat.list = nil
        combat.start = false
        Mod.saveUserState(combat,group,2)
        resp = resp .. "当前战斗轮列表无角色！\n"
        resp = resp .. "已自动关闭战斗论模式！如需使用请重新开启！"
        return resp
    elseif leng > 1 then
        if combat.round > del then
            combat.round = combat.round - 1
        end
    end

    if del >= 1 and del <= leng then 
        combat.list[del] , combat.list[leng] = combat.list[leng],nil 
    else 
        return "未知错误！\ndel = "..tostring(del).." ; leng = "..tostring(leng)
    end

    table.sort(combat["list"],function (a, b)
        if a.Dex == b.Dex then 
            a.fight =a.fight or 0
            b.fight = b.fight or 0
            return a.fight > b.fight
        end
        return a.Dex > b.Dex
    end)

    Mod.saveUserState(combat,group,2)
        resp = resp .. "### 当前战斗角色列表：\n"
    for i = 1, Mod.table_leng(combat.list), 1 do
        resp = resp .."["..i.."] "..combat.list[i]["name"].." ("
        resp = resp .. combat.list[i]["QQ"]..")  DEX = "..combat.list[i]["Dex"].."\n"
    end
    return resp
end
