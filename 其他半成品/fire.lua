--[=[
#      _____       _
#     |  __ \     (_)
#     | |__) |__ _ _ _ __  _   _
#     |  _  // _` | | '_ \| | | |
#     | | \ \ (_| | | | | | |_| |
#     |_|  \_\__,_|_|_| |_|\__, |
#                           __/ |
#                          |___/
    向火独行 V0.1  by 雨鸣于舟 20210606
    需使用Constant.lua , calculate.lua 模块 
    需使用dkjson库

        已完成  .fra 技能检定（对抗）功能
                .fsc 理智检定功能
        当前测试部分内容
    ]=]
    command = {}
    -- 向火独行
    command["(\\.|。)(fire)"] = "firehelp"
    -- 开始
    command["(\\.|。)(fire)\\s*(start)"] = "fireStart"
    command["(\\.|。)(fire)\\s*(start)"] = "fireStop"
    command["(\\.|。)(fire)\\s*(start)"] = "fireRestart"
    -- 所有指令类型
    command["(\\.|。|\\/)(goto)\\s*(\\d+)"] = "gotoRaw" -- .goto 123 前往页面123
    command["(\\.|。)(fra|ra)\\s*([bBpP]\\d?)?\\s*([\\D]+)?\\s*([\\d]*)"] = "fra" -- .ra(p) 斗殴 (60)
    command["(\\.|。)(fst|st)\\s*([\\D]+)?\\s*([\\d]*)"] = "fstSet" -- .st 测试 23
    command["(\\.|。)(fst|st)\\s*(([\\D]+)?\\s*([\\d]*)\\s*)+"] = "fstSetLong" -- .st 测试 23
    command["(\\.|。)(fst|st)\\s*([\\D]+)?\\s*(\\+|\\-)\\s*([0-9dD\\-\\+\\*]+)"] = "fstChange" -- .st 测试 -1d5
    command["(\\.|。)(fst|st)\\s*(del)\\s*([\\D]+)"] = "fstDel" -- .st 测试 -1d5
    command["(\\.|。)(fsc|sc)\\s*([0-9dD\\-\\+\\*]+)(/)([0-9dD\\-\\+\\*]+)"] = "fsc" -- .fsc 1/1d3
    command["(\\.|。)(repeat)"] = "frepeat" -- 复读
    command["(\\.|。|\\/)(fgoto)\\s*(\\d+)"] = "gotoForced" -- 强制翻页，用于测试
    command["(#set\\s*name)\\s*([\\D]+)"] =  "setName"
    function firehelp(msg)
        return "test"
    end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    package.path = package.path..";D:\\Rainy\\DICE\\MIRAI2\\Dice3614566160\\plugin\\lib\\?.lua"
    --   dice = require("dicetest")
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- 自定义函数部分 (Rainy.lua)
    basic_path = dice.DiceDir()
    dice.mkDir(basic_path.."\\RainyData\\group") -- 初始化存档路径
    dice.mkDir(basic_path.."\\RainyData\\QQ") -- 初始化存档路径
    package.cpath = package.cpath..";"..basic_path.."\\plugin\\lib\\?.dll"

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
            if userdata["isFireStarted"] == nil or type(userdata["isFireStarted"]) ~="boolean"  then
                userdata["isFireStarted"] = false
                ischanged = true
            end
            if userdata["QQ"] == nil or M.isnum(userdata["QQ"]) == false then
                userdata["QQ"] = target
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
        if isGroup == 4 then
            local groupdata = M.getUserState(target, 0)
            if userdata["isFireStarted"] == nil or type(userdata["isFireStarted"]) ~="boolean"then
                userdata["isFireStarted"] = groupdata["isFireStarted"]
                ischanged = true
            end
            if type(userdata["point"]) ~= "number" or userdata["point"] <= 0  then -- 当前回合玩家
                userdata["point"] = 1
                ischanged = true
            end
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
        local rollResult = 0
        local successLevel = 0
        local RD = require("calculate")
        local rankName = {"大成功","极难成功","困难成功","成功","失败","大失败",[0] = "【未知情况】"} -- 因为lua数组从1开始，所有rank也是1~6
        local setcoc = setcoc or {1, 0, 1, 0, 96, 0, 100, 0, 50}
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
            sign = -sign
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
    -- 获取向火独行数据模块
    local FireData = M.decjson(basic_path.."\\RainyData\\fire\\firedata.json")
    ---具体前往下一节点
    ---@param playerState table 玩家状态
    ---@param nextPoint string 下一节点名称
    ---@return boolean status 具体是否成功
    ---@return string text 下一节点回复内容
    local function gotoNextPoint(playerState,nextPoint)
        local point = tostring(nextPoint)
        local nowData = FireData[point]
        playerState.point = nextPoint
        local isAvailable,text = false,""
        if nowData.log ~= "nil" and playerState[nowData.log] == 0 then
            playerState[nowData.log] = 1
        elseif nowData.log ~= "nil" then
            playerState[nowData.log] = playerState[nowData.log] +1
        end
        if nowData.type == "once" then
            -- 已经前往过某一地点
            if playerState["exp"..point] > 1 then
                return false,"你已经去过那里了，无法再次前往"
            end
            nextPoint = nowData.autogoto
            isAvailable,text = gotoNextPoint(playerState,nextPoint)
            if isAvailable then
                return true ,text
            else
                return  false ,"未知错误x"
            end
        end
        M.saveUserState(playerState,playerState.QQ,4)
        text = nowData.text or ""
        return true , text
    end
    
    function setName(msg)
        local QQ = msg.fromQQ
        local playerState = M.getUserState(QQ,4)
        playerState.name = msg.str[2]
        M.saveUserState(playerState,QQ,4)
        return "成功将名称改为："..playerState.name
    end
    function fstSet(msg)
        local Constant = require("Constant")
        local QQ = msg.fromQQ
        local playerstate = M.getUserState(QQ, 4)
        local skillName = msg.str[4]
        local skillVal = tonumber(msg.str[4])
        -- 技能转义
        skillName = string.gsub(skillName," ","")
        if Constant.SkillNameReplace[skillName] ~= nil then
            skillName = Constant.SkillNameReplace[skillName]
        end
        playerstate.skill.skillName = skillVal
        M.saveUserState(playerstate,QQ,4)
        return "已将"..playerstate.name.."的【"..skillName.."】设置为"..skillVal
    end
    function fstChange(msg)
        return M.tabletostring(msg.str)
    end
    function fstDel(msg)
        return M.tabletostring(msg.str)
    end
    -- 开始游戏
    function fireStart(msg)
        local QQ = msg.fromQQ
        local playerState = M.getUserState(QQ, 4)
        if playerState["isFireStarted"] == true then
            return "向火独行模块已经开启，无需再次启动！"
        else
            playerState["isFireStarted"] = true
            M.saveUserState(playerState,QQ,4)
        end
        local resp = "已开启向火独行模块！\n.fire start 开始游戏\n.fire stop 暂停游戏 \n.fire restart 重启游戏\n.goto [数字] 翻页\f"
        local point = tostring(playerState["point"])
        local text = ""
        if type(FireData[point]["text"]) ~= "nil" then
            text = FireData[point]["text"]
        end
        resp = resp .. "当前页面【"..string.sub(point,-3,-1).."】\n"
        resp = resp .. text
        return resp
    end
    function fstSetLong(msg)
        -- statements
        return M.tabletostring(msg.str)
    end
    -- 关闭游戏
    function fireStop(msg)
        local QQ = msg.fromQQ
        local playerState = M.getUserState(QQ, 4)
        if playerState["isFireStarted"] == false then
            return "向火独行模块已经关闭"
        else
            playerState["isFireStarted"] = false
            M.saveUserState(playerState,QQ,4)
        end
        local resp = "已保存并关闭向火独行模块！\n.fire start 再次开始游戏\n.fire stop 暂停游戏 \n.fire restart 重启游戏\n.goto [数字] 翻页\f"
        return resp
    end
    -- 重启游戏
    function fireRestart(msg)
        local QQ = msg.fromQQ
        local playerState = {
            ["QQ"] = msg.fromQQ,
            ["point"] = 1,
            ["isFireStarted"] = true,
            ["setcoc"] = {1,0,1,0,96,0,100,0,50}
        }
        local resp = "已重置向火独行模块！\n.fire start 开始游戏\n.fire stop 暂停游戏 \n.fire restart 重启游戏\n.goto [数字] 翻页\f"
        local point = "1"
        local text = ""
        M.saveUserState(playerState,QQ,4)
        if type(FireData[point]["text"]) ~= "nil" then
            text = FireData[point]["text"]
        end
        resp = resp .. "当前页面【"..string.sub(point,-3,-1).."】\n"
        resp = resp .. text
        return resp
    end
    function frepeat(msg)
        local QQ = msg.fromQQ
        local playerState = M.getUserState(QQ,4)
        if playerState["isFireStarted"] == false then
            return "当前向火独行模块已关闭！\n请先使用.fire start 开始游戏！"
        end
        local point = tostring(playerState["point"])
        local nowData = FireData[point]
        if nowData.type == "once" then
            local nextPoint  = nowData.autogoto
            local status , text = gotoNextPoint(playerState,nextPoint)
            if status == false then
                return "未知错误，请重置游戏！"
            end
            return text
        end
        return nowData.text
    end
    -- 开始游戏
    function gotoRaw(msg)
        local QQ = msg.fromQQ
        local playerState = M.getUserState(QQ, 4)
        if playerState["isFireStarted"] == false then
            return "当前向火独行模块已关闭！\n请先使用.fire start 开始游戏！"
        end
        local point = tostring(playerState["point"])
        local fGoto = msg.str[3]
       -- local text = ""
        local nowData = FireData[point]
        local nextData = FireData[fGoto]
        local isAvailable = false       -- 可以前往目标页

        -- 判断各类节点类型
        if nowData["type"] == "norm" then               -- 标准节点 norm
            if nowData["to"] ~= nil then
                for i = 1, #nowData["to"] do
                    -- statements
                    if tostring(nowData["to"][i])==fGoto then
                        isAvailable = true
                    end
                end
                if not isAvailable then
                    return "当前位置【"..string.sub(point,-3,-1).."】\n你无法前往目标页面"
                end
            end
        elseif nowData["type"] == "hist" then           -- 特殊节点 hist （判断用户是否经历过某节点）
            local reqval = nowData["hist"]["name"]      -- 需求变量
            local level = nowData["hist"]["level"]      -- 数量
            local result = playerState[reqval] or 0     -- 具体数值
            if result < level then
                for i = 1, #nowData["hist"]["low"] do
                    -- statements
                    if tostring(nowData["to"][i])==fGoto then
                        isAvailable = true
                    end
                end
                if not isAvailable and nowData["hist"]["lower"][fGoto] ~= nil then
                    return "当前位置【"..string.sub(point,-3,-1).."】\n"..nowData["hist"]["lower"][fGoto]
                elseif not isAvailable then
                    return "当前位置【"..string.sub(point,-3,-1).."】\n你无法前往目标页面"
                end
            else
                for i = 1, #nowData["hist"]["high"] do
                    -- statements
                    if tostring(nowData["to"][i])==fGoto then
                        isAvailable = true
                    end
                end
                if not isAvailable and nowData["hist"]["higher"][fGoto] ~= nil then
                    return "当前位置【"..string.sub(point,-3,-1).."】\n"..nowData["hist"]["higher"][fGoto]
                elseif not isAvailable then
                    return "当前位置【"..string.sub(point,-3,-1).."】\n你无法前往目标页面"
                end
            end
        elseif nowData["type"] == "fight" then
            -- 暂时懒得搞这些，就先全部放了
            isAvailable = true
        else
            isAvailable = true
        end
        -- 检测下一节点是否可以进入
        if isAvailable then
            if nextData.type == "once" and playerState["exp"..fGoto] ~= nil then
                return "你已经去过那里了，无法再次进入！"
            end
        else
            return "你无法前往那里"
        end
        local status ,text = gotoNextPoint(playerState,fGoto)
        if status == false then
            return "你无法前往那里!"..text
        end
        return text
    end

    function gotoForced(msg)
        -- statements
        local QQ = msg.fromQQ
        local playerstate = M.getUserState(QQ,4)
        local fgoto = msg.str[3]
        local status,text = gotoNextPoint(playerstate,fgoto)
        if status == false then
            playerstate = M.getUserState(QQ,4)
            return "发生错误！当前playerstate:\n"..M.tabletostring(playerstate)
        end
        return text
    end


-- print(Ra("test","skill",60,5))

    function fra(msg)
        local group = msg.fromGroup
        local QQ = msg.fromQQ
        local playerstate = M.getUserState(QQ, 4)
        local rawSign = msg.str[3]      -- 奖励骰
        local skillName = msg.str[4]
        local skillVal = tonumber(msg.str[5]) or 0
        local sign = 0          -- 奖励骰惩罚骰，+为奖励骰
        local resp = ""
        local Constant = require("Constant")
        -- 技能转义
        skillName = string.gsub(skillName," ","")           -- 去除匹配时多余的空格
        if Constant.SkillNameReplace[skillName] ~= nil then
            skillName = Constant.SkillNameReplace[skillName]
        end
        if skillVal == 0 then
            skillVal = dice.getPcSkill(QQ,group,skillName)
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
        local successLevel
        resp,successLevel = Ra(playerstate.name,skillName,skillVal,sign,playerstate.setcoc)
        --[[ 进行节点处理 ]]
        -- 获取关于当前节点信息
        local point = tostring(playerstate.point)
        local nowData=FireData[point]
        -- 特殊节点处理
        if nowData.type == "lualib" then
            local filename = "firelib"..tostring(point)
            local lualib = pcall(require(filename))     -- 导入特殊节点专用lualib
            if lualib == false then
                return resp
            end
            local result = lualib.main(playerstate,"fra",successLevel)
            if result.isAvailable == false then
                if result.text ~= nil then
                    resp = resp .."\f"..result.text
                end
                return resp
            else
                playerstate.point = result.nextPoint       -- 设置前往下一节点
                local err,text = gotoNextPoint(playerstate,result.nextPoint)
                if err == false then
                    return "错误！"..text
                else
                    resp = resp .. "\f"..text
                end
                return resp
            end
        end
        -- 如果节点不是ra/rx类型，则无视本次检定结果直接结束
        if nowData.type ~= "ra" and nowData.type ~= "rv" or playerstate.isFireStarted == false then
            return resp
        end
        if nowData[skillName] == nil then
            resp = resp .. "\f检定技能与需求技能不符！应检定【"
            if type(nowData.skill) == "string" then
                resp = resp .. nowData.skill.."】"
            elseif type(nowData.skill) == "table" then
                for i = 1,#nowData.skill-1,1 do
                    resp = resp ..nowData.skill[i].."】【"
                end
                resp = resp .. nowData.skill[#nowData.skill].."】"
            end
            return resp
        elseif  (nowData[skillName]["sign"]) ~= nil then
            if sign ~= nowData[skillName]["sign"] then
                resp = resp .. "\f检定技能奖励骰或惩罚骰数量错误，投掷表达式因为【.ra"
                if sign >=2 then
                    resp = resp .."b"..tostring(sign).." "..skillName.."】"
                elseif sign == 1 then
                    resp = resp .."b "..skillName.."】"
                elseif sign == 0 then
                    resp = resp.. " "..skillName.."】"
                elseif sign == -1 then
                    resp = resp .."p "..skillName.."】"
                elseif sign <= -2 then
                    resp = resp .."p"..tostring(sign).." "..skillName.."】"
                end
                return resp
            end
        elseif (nowData[skillName]["sign"]) == nil then
            if sign ~= 0 then
                resp = resp .. "\f检定技能奖励骰或惩罚骰数量错误，投掷表达式因为【.ra "..skillName.."】"
                return resp
            end
        end

        -- ra节点前往下一格
        if nowData.type == "ra" then
            local nextPoint = nowData[skillName]["ragoto"][successLevel]
            if nowData[skillName]["ratext"][successLevel] ~= "" then
                resp = resp .."\n".. nowData[skillName]["ratext"][successLevel].."\f"
            else
                resp = resp .."\f"
            end
            playerstate.point = nextPoint       -- 设置前往下一节点
            local err,text = gotoNextPoint(playerstate,nextPoint)
            if err == false then
                return "错误！"..text
            else
                resp = resp .. "\f"..text
            end
            return resp
        end

        -- rv节点前往下一格
        if nowData.type == "rv" then

            -- npc 检定
            local npcSign = nowData[skillName]["npcSign"] or 0
            local npcSkillVal = nowData[skillName]["npcSkill"] or 0
            local npcName = nowData[skillName]["npcName"] or ""
            local npcSuccessLevel, tempResp
            local level = nowData[skillName]["level"]
            tempResp,npcSuccessLevel = Ra(npcName,skillName,npcSkillVal,npcSign,playerstate.setcoc)
            resp = resp.."\n"..tempResp
            local nextPoint
            if successLevel>level and npcSuccessLevel>level then    -- 均失败，平局
                resp = resp .. "\n对抗平局！\t请重新投掷"
                return resp
            elseif successLevel < npcSuccessLevel then              -- 对抗成功
                resp = resp .. "\n对抗成功！"
                nextPoint = nowData[skillName]["rvgoto"][1]
                if nowData[skillName]["rvtext"][1] ~= "" then
                    resp = resp .. "\n"..nowData[skillName]["rvtext"][1].."\f"
                else
                    resp = resp .. "\f"
                end
            elseif successLevel > npcSuccessLevel then              -- 对抗失败
                resp = resp .. "\n对抗失败！"
                nextPoint = nowData[skillName]["rvgoto"][2]
                if nowData[skillName]["rvtext"][2] ~= "" then
                    resp = resp .. "\n"..nowData[skillName]["rvtext"][2].."\f"
                else
                    resp = resp .. "\f"
                end
            elseif successLevel == npcSuccessLevel then             -- 成功等级相同，比较技能值
                if skillVal < npcSkillVal then
                    resp = resp .. "\n对抗失败！"
                    nextPoint = nowData[skillName]["rvgoto"][2]
                    if nowData[skillName]["rvtext"][2] ~= "" then
                        resp = resp .. "\n"..nowData[skillName]["rvtext"][2].."\f"
                    else
                        resp = resp .. "\f"
                    end
                elseif skillVal > npcSkillVal then
                    resp = resp .. "\n对抗成功！"
                    nextPoint = nowData[skillName]["rvgoto"][1]
                    if nowData[skillName]["rvtext"][1] ~= "" then
                        resp = resp .. "\n"..nowData[skillName]["rvtext"][1].."\f"
                    else
                        resp = resp .. "\f"
                    end
                elseif skillVal == npcSkillVal then
                    resp = resp .. "\n对抗平局！\t请重新投掷"
                    return resp
                end
            end
            playerstate.point = nextPoint       -- 设置前往下一节点
            local err,text = gotoNextPoint(playerstate,nextPoint)
            if err == false then
                return "错误！"..text
            else
                resp = resp .. "\f"..text
            end
            return resp
--[[        旧版本跳转，先留着谁知道呢
            playerstate.point = nextPoint       -- 设置前往下一节点
            point = tostring(nextPoint)
            nowData = FireData[point]
            if nowData.log ~= "nil" and playerstate[nowData.log] == 0 then
                playerstate[nowData.log] = 1
            elseif nowData.log ~= "nil" then
                playerstate[nowData.log] = playerstate[nowData.log] +1
            end
            M.saveUserState(playerstate,QQ,4)       -- 保存用户数据
            resp = resp .."\f".. nowData.text
            return resp
            ]]
        end
        return resp
    end

    -- SANCHECK! 理智检定部分
    function fsc(msg)
        local successExpression = string.lower(msg.str[3])
        local failExpression = string.lower(msg.str[5])
        local playerState = M.getUserState(QQ,4)
        -- 需使用calculate.lua 四则运算算法实现
        local RD = require("calculate")
        local QQ = msg.fromQQ
        local group = msg.fromGroup
        local resp = playerState.name.."进行理智检定：\n"
        -- 检定部分
        local san = dice.getPcSkill(QQ,group,"san")
        local rollResult = RD.Random(1, 100)
        local sanLose = 0

        local scResult 
        if rollResult <= san then
            local err = ""
            err,sanLose = pcall(RD.Calculate,successExpression)
            if not sanLose then
                resp = "表达式错误！请检查对应表达式x\n 错误信息："..err
                return resp
            end
            resp = resp .. "D100 = ".. tostring(rollResult).."/"..san.." 成功！\n"
            resp = resp .."理智损失："..successExpression.." = "..sanLose.." , "
            san = san - sanLose
            resp = resp .. "当前理智："..san
            scResult = true
        else
            local err = ""
            err,sanLose= pcall(RD.Calculate,failExpression)
            if not err then
                resp = "表达式错误！请检查对应表达式x\n 错误信息："..sanLose
                return resp
            end
            resp = resp .. "D100 = ".. tostring(rollResult).."/"..san.." 失败！\n"
            resp = resp .."理智损失："..failExpression.." = "..sanLose.." , "
            san = san - sanLose
            resp = resp .. "当前理智："..san
            scResult = false
        end

        -- 节点判断部分
        local point = tostring(playerState.point)
        local nowData = FireData[point]
        if playerState.isFireStarted == false then
            dice.setPcSkill(QQ,group,"san",san)     -- 写入人物卡
            return resp                          -- 标准sc流程结束
        end
        -- 特殊节点处理
        if nowData.type == "lualib" then
            local filename = "firelib"..tostring(point)
            local lualib = pcall(require(filename))     -- 导入特殊节点专用lualib
            if lualib == false then
                return resp
            end
            local result = lualib.main(playerState,"fsc",scResult)
            if result.isAvailable == false then
                if result.text ~= nil then
                    resp = resp .."\f"..result.text
                end
                return resp
            else
                playerState.point = result.nextPoint       -- 设置前往下一节点
                local err,text = gotoNextPoint(playerState,result.nextPoint)
                if err == false then
                    return "错误！"..text
                else
                    resp = resp .. "\f"..text
                end
                return resp
            end
        end
        -- 判断其他节点直接结束
        if nowData.type ~= "san" then
            return "当前你无法这么做，如果需要sc请先使用【.fire stop】关闭向火独行模块x"
        end 
        local scGoto,scText = 0,""
        local reqSuccessExpression,reqFailExpression = nowData.san.sc[1],nowData.san.sc[2]
        if reqSuccessExpression ~= successExpression or reqFailExpression ~= failExpression then
            resp = "SC表达式错误x\n应为【.fsc "..reqSuccessExpression.."/"..reqFailExpression.."】"
            return resp
        end
        if scResult then
            scGoto = nowData.san.scgoto[1]
            scText = nowData.san.sctext[1]
        else
            scGoto = nowData.san.scgoto[2]
            scText = nowData.san.sctext[2]
        end
        if scText ~= "" then
            resp = resp .."\f"..scText
        end
        resp = resp .."\f"
        -- 设置前往下一节点
        local err,text = gotoNextPoint(playerState,scGoto)
        if err == false then
            return "错误！"..text
        else
            resp = resp .. "\f"..text
        end
        dice.setPcSkill(QQ,group,"san",san)     -- 写入人物卡
        return resp
    end


