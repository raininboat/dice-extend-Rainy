--[[
#             _   __  _____                 ____       _             
#            | | / / |  __ \               |  _ \ __ _(_)_ __  _   _ 
#            | |/ /  | |__| |              | |_) / _` | | '_ \| | | |
#            |   <   | ____/               |  _ < (_| | | | | | |_| |
#       _    | |\ \  | |              by   |_| \_\__,_|_|_| |_|\__, |
#      |_|   |_| \_\ |_|                                       |___/ 

.KP系列带团指令
            --- by雨鸣于舟（QQ1620706761） Last Edit： 2020/12/14
    .kp设置：
        .kp 帮助菜单，未完全写完
        .kp set 设置群聊带团KP
        .kp info 查询本群当前配置状态
        .kp clr .kp del
        .kp xra 查询xra模式状态
        .kp xra 0/1/2/3 设置xra模式状态
            xra状态：
                    0 全体群员可用（默认）
                    1 仅限群管和KP可用
                    2 仅限KP可用
                    3 均不可用（关闭）
        .kp xstshow 查询xstshow模式状态
        .kp xstshow 0/1/2/3 设置xstshow模式状态
            xstshow状态：
                    0 全体群员可用
                    1 仅限群管和KP可用（默认）
                    2 仅限KP可用
                    3 均不可用（关闭）
        .kp setcoc 查询检定房规（同setcoc规则）
        .kp setcoc 0\1\2\3\4\5 设置检定房规（同setcoc规则）
    .xra(h)(b/p) 【技能名称】 【at 群员】
        用于代替投掷检定
        e.g:
            .xrah 心理学 @某位PL
                kp暗骰pl心理学
            .xra 手枪 @某位PL
                替某位鸽子进行检定
    现阶段问题： 部分情况下表达式解析易出现问题（如无法读取at信息等）
    .xst show 【技能名称】 【at群员】
        用于显示某位群员的某项技能值

    #################
    #！！！注意！！！# 当前有时含有at的匹配会出现不可知变异（匹配错误），初步怀疑可能是框架问题or正则问题，故将该情况加入单独回复后发布
    #################

--]]

--  ############################################################################
--  #强烈建议将初始化mkDirs步骤（下方5行内容）单独写入一个空脚本，每次重载只运行一次#
--  ############################################################################
function mkDirs(path)
    os.execute('mkdir "' .. path .. '"')
end
basic_path = dice.DiceDir() .. "\\user\\Rainy_plugin\\groups\\" -- 这里设置一下存档的初始地址
mkDirs(basic_path) -- >>>初始化存档路径<<<    就是这里！

--------------------------------
command = {}

command["(\\.|。|＊|\\*)(kp|KP)\\s*"] = "KP_help"
    --[[.kp 查询相关帮助文档--]]
command["(\\.|。|＊|\\*)(kp|KP)\\s*set"] = "KP_set"
    --[[.kp set 设置kp--]]
command["(\\.|。|＊|\\*)(kp|KP)\\s*info"] = "KP_info"
    --[[.kp info 查询本群KP--]]
command["(\\.|。|＊|\\*)(kp|KP)\\s*(clr|del)"] = "KP_clr"
    --[[.kp clr/del 清除本群KP--]]
command["(\\.|。|＊|\\*)(kp|KP)\\s*xra\\s*([0123]?)"] = "Xra_conf_set"
    --[[.kp xra 0\1\2\3 设置xra模式 (0（默认） 所有人，1 群管+KP，2 KP，3 关闭) --]]
command["(\\.|。|＊|\\*)(kp|KP)\\s*setcoc\\s*([012345]?)"] = "Xra_setcoc"
    --[[.kp setcoc 0\1\2\3\4\5 设置xra检定房规 （详见原版.help setcoc） --]]
command["(\\.|。|＊|\\*)(kp|KP)\\s*setcoc"] = "Xra_setcoc_show"
    --[[.kp setcoc 0\1\2\3\4\5 设置xra检定房规 （详见原版.help setcoc） --]]
command["(\\.|。|＊|\\*)(kp|KP)\\s*xra"] = "Xra_conf_show"
    --[[.kp xra 查询xra模式 --]]
command["(\\.|。|＊|\\*)(xra|xr)([bBpP]\\d?)?\\s*([^\\d]+?)\\s*(\\[CQ:at,qq=)(\\d{4,})\\]"] = "Xra"
    --[[.xra 查询xra模式 --]]
command["(\\.|。|＊|\\*)(xrah|xrh)([bBpP]\\d?)?\\s*([^\\d]+?)\\s*(\\[CQ:at,qq=)(\\d{4,})\\]"] = "Xrah"
    --[[.kp xstshow 0\1\2\3 设置xstshow模式 (0 所有人，1 群管+KP（默认），2 KP，3 关闭) --]]    
command["(\\.|。|＊|\\*)(kp|KP)\\s*xst\\s*show\\s*([0123]?)"] = "Xst_show_set"
    --[[.kp xstshow 查询xstshow模式 --]]
command["(\\.|。|＊|\\*)(kp|KP)\\s*xst\\s*show"] = "Xst_show_show"
    --[[.kp xstshow 0\1\2\3 设置xstshow模式 (0 所有人，1 群管+KP（默认），2 KP，3 关闭) --]]    
command["(\\.|。|＊|\\*)(kp|KP)\\s*xst\\s*(set)?\\s*([0123]?)"] = "Xst_set_set"
    --[[.kp xstshow 查询xstshow模式 --]]
command["(\\.|。|＊|\\*)(kp|KP)\\s*xst\\s*(set)?"] = "Xst_set_show"
    --[[.xst show 心理学 @xxx 查询xst --]]
command["(\\.|。|＊|\\*)(xst|xST)\\s*(show)\\s*([^\\d]+?)\\s*(\\[CQ:at,qq=)(\\d{4,})\\]"] = "Xst_show_skill"
    --[[.xst 心理学 25 @xxx 设置xst --]]
command["(\\.|。|＊|\\*)(xst|xST)\\s*([^\\d]+?)\\s*([+-]?)(\\d+?)\\s*(\\[CQ:at,qq=)(\\d{4,})\\]"] = "Xst_set_skill"
--------------------------------
--[[初始化文件路径]]
function read_file(path)
    local text = ""
    local file = io.open(path, "r") -- 打开了文件读写路径
    if (file ~= nil) then -- 如果文件不是空的
        text = file.read(file, "*a") -- 读取内容
        io.close(file) -- 关闭文件
    end
    return text
end
--[[↑读取对应的文件]]
function write_file(path, text)
    local file = io.open(path, "w") -- 以只写的方式
    file.write(file, text) -- 写入内容
    io.close(file) -- 关闭文件
end
--[[↑写入对应的文件]]
function split_data(s)
    local t = {}
    for k, v in string.gmatch(s, "(%w+)=([%d-]+);\n") do
        t[k] = v
    end
    return t
end
--[[分割保存的  文件成为数组]]

--[[检测是否为数值]]
function isnum(text)
    return tonumber(text) ~= nil
end

--[[将数组转化为字符串等待保存]]
function tabletostring(table)
    local a=""
    for key, value in pairs(table) do
        a=a..key.."="..value..";\n"
    end
    --a=string.sub(a, 1, -2)
    return a
end

--打印各正则表达式
function printstr(Msg)
   local resp =""
    for i = 0,(Msg.str_max-1), 1 do
        resp = resp .."str"..tostring(i)..':"'..Msg.str[i]..'"\t'
    end
    return resp
end
-----------------------
--[[获取群组情况数组]]
function GetGroupState(group)
    local file,group_state= "", ""
    local patha=basic_path.."group"..tostring(group)..".txt"
    file = read_file(patha)         --读取群聊data
    group_state=split_data(file)    --转换为数组
    local ischanged = false
   --[[ Team接口(未完成)
   group_state.team[""]=0
   ]]
    if group_state["KP"] == nil or isnum(group_state["KP"])==false  then
        group_state["KP"] = 0
        ischanged = true
    end
    if group_state["Xrastate"] == nil or isnum(group_state["Xrastate"])==false  then
        group_state["Xrastate"] = 0
        ischanged = true
    end
    if group_state["Xstshow"] == nil or isnum(group_state["Xstshow"])==false  then
        group_state["Xstshow"] = 1
        ischanged = true
    end
    if group_state["Xstset"] == nil or isnum(group_state["Xstset"])==false  then
        group_state["Xstset"] = 1
        ischanged = true
    end
    if group_state["Group"] == nil or isnum(group_state["Group"])==false  then
        group_state["Group"] = group
        ischanged = true
    end
    if group_state["Xrasetcoc"] == nil or isnum(group_state["Xrasetcoc"])==false  then
        group_state["Xrasetcoc"] = 0
        ischanged = true
    end
    if ischanged then
        file = tabletostring(group_state)
        write_file(patha,file)
    end
    return group_state
end

--[[获取用户状态（1 KP，2 群管，4 DICE_Admin）--]]
function GetQQState(QQ,Msg)
    --[[
    trust =
            1 0x0001 KP
            2 0x0010 管理，群主
            4 0x0100 DICE_Admin
            8 0x1000 Team(未做)

            3 0x0011 KP + 管理
            5 0x0101 KP + DICE_Admin
            6 0x0110 群管 + DICE_Admin
            7 0x0111 KP + 群管 + DICE_Admin
            8+ Team人员（未编写）
        --]]
    local group = tonumber(Msg.fromGroup)
    local group_state = GetGroupState(group)
    local trust = 0
    if QQ == group_state["KP"] then
        trust = trust + 1           --0x0001 KP
    end

    if tonumber(Msg.fromQQInfo) >= 2 then
        trust = trust + 2           --0x0010 群管
    end

    if tonumber(Msg.fromQQTrust) >= 4 then
        trust = trust + 4           --0x0100 DICE_Admin
    end

    --[[
    if QQ == group_state["Team"] then
        trust = trust + 8           --0x1000 Team
    end
--]]
    return trust
end
function KP_set(msg)        -- 设置KP
    local file,group_state,resp = "", "","\n"
    local QQ = msg.fromQQ           --发送者QQ
    local Group = msg.fromGroup     --群号
    local KP = 0                    --初始化
    local patha=basic_path.."group"..tostring(Group)..".txt"
    group_state = GetGroupState(Group)
    group_state["Group"]=Group
    if group_state["KP"] == nil or isnum(group_state["KP"])==false then
        KP = 0
        group_state["KP"]=0
        file = tabletostring(group_state)
        write_file(patha,file)
    else
        KP = tonumber(group_state["KP"])
    end
    if KP == QQ then
        resp = "{nick}（"..QQ.."）已经是群（"..Group.."）的KP了"
    elseif KP ~= QQ and KP ~= 0 then
        resp = "设置失败！\n本群已有KP（"..KP.."），请群管或原KP本人使用指令 .kp clr 进行清除！"
    elseif KP ~= QQ and KP == 0 then
        KP=QQ
        resp = "设置带团群成功！\n已将{nick}（"..QQ.."）设置为群（"..Group.."）的KP！"

        group_state["KP"]=KP
        file = tabletostring(group_state)
        write_file(patha,file)
    end
    return resp
end

function KP_info(msg)       --查询本群kp
    local group_state,resp = "", "","\n"
    --local QQ = msg.fromQQ           --发送者QQ
    local Group = msg.fromGroup     --群号
    local KP = 0                    --初始化
    group_state=GetGroupState(Group)
    KP = tonumber(group_state["KP"])
    if KP == 0 then
        resp="本群尚未设置带团KP，使用指令.kp set进行设置！"
    else
        resp = "本群当前KP为：（"..tostring(KP).."）\n本群当前XRa(他人代骰)状态为："
        local Xrastate = tonumber(group_state["Xrastate"] )
        resp = resp..Xrastate.." "
        if (Xrastate == 0 )then
            resp = resp.."所有人均可使用"
        elseif (Xrastate == 1) then
            resp = resp.."群管和KP可以使用"
        elseif (Xrastate == 2) then
            resp = resp.."仅KP可以使用"
        elseif (Xrastate == 3) then
        resp = resp.."所有人均不可使用（关闭）"
        end
        resp = resp .."\n本群当前Xstshow（查询他人技能值）模式为："
        local Xstshow = tonumber(group_state["Xstshow"] )
        resp = resp..Xstshow.." "
        if (Xstshow == 0 )then
            resp = resp.."所有人均可使用"
        elseif (Xstshow == 1) then
            resp = resp.."群管和KP可以使用"
        elseif (Xstshow == 2) then
            resp = resp.."仅KP可以使用"
        elseif (Xstshow == 3) then
        resp = resp.."所有人均不可使用（关闭）"
        end
    end
   -- resp = resp.."\n".."debug:file\n"..file.."\n".."KP="..group_state["KP"].."\n"

    return resp
end

function KP_clr(msg)        --清除本群kp
    local isadmin = msg.fromQQInfo
    local file,group_state,resp = "", "","\n"
    local QQ = msg.fromQQ           --发送者QQ
    local Group = msg.fromGroup     --群号
    local KP = 0                    --初始化
    local patha=basic_path.."group"..tostring(Group)..".txt"
        --群data存储的位置,basic_path 在第8行
    file = read_file(patha)         --读取群聊data
    group_state=split_data(file)    --转换为数组
    if group_state["KP"] == nil or isnum(group_state["KP"])==false then
        KP = 0
        group_state["KP"]=0
        file = tabletostring(group_state)
        write_file(patha,file)
    else
        KP = tonumber(group_state["KP"])
    end

    if (KP==QQ or isadmin==2 or isadmin==3) then
        group_state["KP"]=0
        resp = "已将本群KP（"..KP.."）清除\n可使用.kp set 再次进行设置！"
        KP=0
        file = tabletostring(group_state)
        write_file(patha,file)
    elseif (KP==0) then
        resp = "清除失败X\n本群尚未设置带团KP，请先使用.kp set 进行设置！"
    else
        resp = "清除失败X\n请联系群管理或者KP本人进行清除！"
    end
    return resp
end
--帮助文档
function KP_help(msg)
    local resp = "<第一页>.kp设置：\n.kp 帮助菜单\n.kp set 设置群聊带团KP\n.kp info 查询本群当前设置状态\n.kp clr .kp del 清除当前群带团KP设定\f<第二页>.kp xra 查询xra模式状态\n.kp xra 0/1/2/3 设置xra模式状态\nxra状态：0 全体群员可用（默认）\n1 仅限群管和KP可用\n2 仅限KP可用\n3 均不可用（关闭）\f<第三页>.kp xstshow 查询xstshow模式状态\n.kp xstshow 0/1/2/3 设置xstshow模式状态\nxstshow状态：0 全体群员可用\n1 仅限群管和KP可用（默认）\n2 仅限KP可用\n3 均不可用（关闭）\f<第四页>.xra(h)(b/p) 【技能名称】 【at 群员】\n用于代替投掷检定e.g:\n.xrah 心理学 @某位PL  (kp暗骰某位pl心理学)\n.xra 手枪 @某位PL\n替某位鸽子进行检定\n.xst show 【技能名称】 【at群员】  用于显示某位群员的某项技能值\f注意！！！\n由于框架原因，部分情况下@可能会匹配失常导致功能无法使用，可以尝试重新发送一遍！"
    return resp
end
----------------------------
--设置xra状态
function Xra_conf_set(msg)
    local isadmin = msg.fromQQInfo
    local file,group_state,resp = "", "","1\n"
    local QQ = msg.fromQQ           --发送者QQ
    local Group = msg.fromGroup     --群号
    local Xrastate = 0                    --初始化
    local patha=basic_path.."group"..tostring(Group)..".txt"
    local KP = 0
        --群data存储的位置,basic_path 在第8行
    file = read_file(patha)         --读取群聊data
    group_state=split_data(file)    --转换为数组

    --读取KP
    if isnum(group_state["KP"]) then
        KP = tonumber(group_state["KP"])
    else
        group_state["KP"]= 0
        KP = 0
        file = tabletostring(group_state)
        write_file(patha,file)
    end

    if isnum(tonumber(msg.str[msg.str_max-1])) then
        Xrastate=tonumber(msg.str[msg.str_max-1])
    else
        resp = "表达式错误！\n"..printstr(msg)
        return resp
    end
    if (isadmin==2 or isadmin==3 or KP==QQ) then
        group_state["Xrastate"]=Xrastate
        resp = "已将本群xra设置改为：\n"..Xrastate.." "
        file = tabletostring(group_state)
        write_file(patha,file)
        Xrastate=tonumber(Xrastate)
            if (Xrastate == 0 )then
        resp = resp.."所有人均可使用"
    elseif (Xrastate == 1) then
        resp = resp.."群管和KP可以使用"
    elseif (Xrastate == 2) then
        resp = resp.."仅KP可以使用"
    elseif (Xrastate == 3) then
        resp = resp.."所有人均不可使用（关闭）"
    end
    else
        resp = "设置失败X\n请由群管理或者KP进行设置！"
    end


    return resp
end
--查询xra状态
function Xra_conf_show(msg)
    local file,group_state,resp = "", "","\n"
    local Group = msg.fromGroup     --群号
    local patha=basic_path.."group"..tostring(Group)..".txt"
    local Xrastate = 0
        --群data存储的位置,basic_path 在第8行

    group_state=GetGroupState(Group)
    --读取xrastate
    if isnum(group_state["Xrastate"]) then
        Xrastate= tonumber(group_state["Xrastate"])
    else
        Xrastate = 0
        group_state["Xrastate"]=0
        file = tabletostring(group_state)
        write_file(patha,file)
    end
    resp = "本群xra设置为：\n"..Xrastate.." "
    Xrastate=tonumber(Xrastate)
    if Xrastate==0 then
        resp = resp.."所有人均可使用"
    elseif Xrastate==1 then
        resp = resp.."群管和KP可以使用"
    elseif Xrastate==2 then
        resp = resp.."仅KP可以使用"
    elseif Xrastate==3 then
        resp = resp.."所有人均不可使用（关闭）"
    end
    return resp
end
function Xra_setcoc(Msg)
    local resp,file = "" , ""
    local fromQQ = tonumber(Msg.fromQQ)
    local trust = GetQQState(fromQQ,Msg)
    local group = tonumber(Msg.fromGroup)
    local group_state = GetGroupState(group)
    local Xrasetcoc
    local path=basic_path.."group"..tostring(group)..".txt"
    if isnum(tonumber(Msg.str[Msg.str_max-1])) then
        Xrasetcoc=tonumber(Msg.str[Msg.str_max-1])
    else
        resp = "表达式错误！\n"..printstr(Msg)
        return resp
    end
    if fromQQ ~= tonumber(group_state["KP"]) and trust == 0 then 
        resp = "你没有权限设置群聊Xst模式！\n请由群管理或者KP进行设置!"
        return resp
    else
        group_state["Xrasetcoc"]=Xrasetcoc
        resp = "已将本群Xra房规改为：\n"..tostring(Xrasetcoc).." "

        if (Xrasetcoc == 0 )then
            resp = resp.." 规则书\n出1大成功\n不满50出96 - 100大失败，满50出100大失败"
        elseif (Xrasetcoc == 1) then
            resp = resp.."\n不满50出1大成功，满50出1 - 5大成功\n不满50出96 - 100大失败，满50出100大失败"
        elseif (Xrasetcoc == 2) then
            resp = resp.."\n出1 - 5且 <= 成功率大成功\n出100或出96 - 99且 > 成功率大失败"
        elseif (Xrasetcoc == 3) then
            resp = resp.."\n出1 - 5大成功\n出96 - 100大失败"
        elseif (Xrasetcoc == 4) then
            resp = resp.."\n出1 - 5且 <= 十分之一大成功\n不满50出 >= 96 + 十分之一大失败，满50出100大失败"
        elseif (Xrasetcoc == 5) then
            resp = resp.."\n出1 - 2且 < 五分之一大成功\n不满50出96 - 100大失败，满50出99 - 100大失败"
        end
    end
        file = tabletostring(group_state)
        write_file(path,file)
    return resp
end
function Xra_setcoc_show(Msg)
    local resp = "本群Xra房规为：\n"
    local group = tonumber(Msg.fromGroup)
    local group_state = GetGroupState(group)
    local Xrasetcoc = tonumber(group_state["Xrasetcoc"])
    resp = resp..tostring(Xrasetcoc).." "
    if (Xrasetcoc == 0 )then
        resp = resp.." 规则书\n出1大成功\n不满50出96 - 100大失败，满50出100大失败"
    elseif (Xrasetcoc == 1) then
        resp = resp.."\n不满50出1大成功，满50出1 - 5大成功\n不满50出96 - 100大失败，满50出100大失败"
    elseif (Xrasetcoc == 2) then
        resp = resp.."\n出1 - 5且 <= 成功率大成功\n出100或出96 - 99且 > 成功率大失败"
    elseif (Xrasetcoc == 3) then
        resp = resp.."\n出1 - 5大成功\n出96 - 100大失败"
    elseif (Xrasetcoc == 4) then
        resp = resp.."\n出1 - 5且 <= 十分之一大成功\n不满50出 >= 96 + 十分之一大失败，满50出100大失败"
    elseif (Xrasetcoc == 5) then
        resp = resp.."\n出1 - 2且 < 五分之一大成功\n不满50出96 - 100大失败，满50出99 - 100大失败"
    end
    return resp
end
--[[判断ra成功率房规判定--]]
function RAsuccess(total,Skill_val,Group)
    local Group_state = GetGroupState(Group)
    local Xrasetcoc = tonumber(Group_state["Xrasetcoc"])
    if not isnum(Skill_val) then return "" end
    Skill_val = tonumber(Skill_val)
    if (Xrasetcoc == 0 )then
        if (total >= 96 and  Skill_val < 50 ) or (total == 100 and  Skill_val >= 50 ) then
            return "大失败！"
        elseif total == 1 then
            return "大成功！"
        elseif total > Skill_val then
            return "失败！"
        elseif total <= Skill_val and total > Skill_val/2 and total ~= 1 then
            return "成功！"
        elseif total <= Skill_val/2 and total > Skill_val/5 and total ~= 1 then
            return "困难成功！"
        elseif total <= Skill_val/5 and total ~= 1 then
            return "极难成功！"
        end
        --  规则书\n出1大成功\n不满50出96 - 100大失败，满50出100大失败"
    elseif (Xrasetcoc == 1) then
        if (total >= 96 and  Skill_val < 50 ) or (total == 100 and  Skill_val >= 50 ) then
            return "大失败！"
        elseif (total == 1 and  Skill_val < 50 ) or (total <= 5 and  Skill_val >= 50 )then
            return "大成功！"
        elseif total > Skill_val then
            return "失败！"
        elseif total <= Skill_val and total > Skill_val/2 then
            return "成功！"
        elseif total <= Skill_val/2 and total > Skill_val/5 then
            return "困难成功！"
        elseif total <= Skill_val/5 then
            return "极难成功！"     --and ((total ~= 1 and Skill_val < 50) or (total > 5 and Skill_val >50))
        end
        --"\n不满50出1大成功，满50出1 - 5大成功\n不满50出96 - 100大失败，满50出100大失败"
    elseif (Xrasetcoc == 2) then
        if (total >= 96 and  Skill_val < total ) or (total == 100) then
            return "大失败！"
        elseif (total <= 5 and  Skill_val >= total)then
            return "大成功！"
        elseif total > Skill_val then
            return "失败！"
        elseif total <= Skill_val and total > Skill_val/2 and total > 5 then
            return "成功！"
        elseif total <= Skill_val/2 and total > Skill_val/5 and total > 5 then
            return "困难成功！"
        elseif total <= Skill_val/5 and total > 5 then
            return "极难成功！"
        end
        --resp = resp.."\n出1 - 5且 <= 成功率大成功\n出100或出96 - 99且 > 成功率大失败"
    elseif (Xrasetcoc == 3) then
        if (total >= 96 ) then
            return "大失败！"
        elseif (total <= 5) then
            return "大成功！"
        elseif total > Skill_val then
            return "失败！"
        elseif total <= Skill_val and total > Skill_val/2 and total > 5 then
            return "成功！"
        elseif total <= Skill_val/2 and total > Skill_val/5 and total > 5 then
            return "困难成功！"
        elseif total <= Skill_val/5 and total > 5 then
            return "极难成功！"
        end
        --resp = resp.."\n出1 - 5大成功\n出96 - 100大失败"
    elseif (Xrasetcoc == 4) then
        if (total >= (96 + Skill_val/10 ) and  Skill_val < 50 ) or (total == 100 and Skill_val >= 50) then
            return "大失败！"
        elseif (total <= 5 and total <= Skill_val/10)then
            return "大成功！"
        elseif total > Skill_val then
            return "失败！"
        elseif total <= Skill_val and total > Skill_val/2  then
            return "成功！"
        elseif total <= Skill_val/2 and total > Skill_val/5 then
            return "困难成功！"
        elseif total <= Skill_val/5 then
            return "极难成功！"
        end
        --resp = resp.."\n出1 - 5且 <= 十分之一大成功\n不满50出 >= 96 + 十分之一大失败，满50出100大失败"
    elseif (Xrasetcoc == 5) then
        if (total >= 96  and  Skill_val < 50 ) or (total >= 99 and Skill_val >= 50) then
            return "大失败！"
        elseif (total <= 5 and total <= Skill_val/5) then
            return "大成功！"
        elseif total > Skill_val then
            return "失败！"
        elseif total <= Skill_val and total > Skill_val/2  then
            return "成功！"
        elseif total <= Skill_val/2 and total > Skill_val/5 then
            return "困难成功！"
        elseif total <= Skill_val/5 then
            return "极难成功！"
        end
        --resp = resp.."\n出1 - 2且 < 五分之一大成功\n不满50出96 - 100大失败，满50出99 - 100大失败"
    end
    return ""
end
function Xra(msg)
    local Skill = ""                                --技能名称
    local Skill_Val = 0                             --技能数值
    local fromQQ = tonumber(msg.fromQQ)             --发送者
    local Group = tonumber(msg.fromGroup)           --群组
    local isadmin = tonumber(msg.fromQQInfo)        --发送者权限
    local targetQQ = 0                              --at目标QQ
    local rbp = ""                                  --惩罚&奖励骰
    local resp = "\n"                               --回复消息
    local group_state = GetGroupState(Group)        --群组参数
    local total = 0                                 --rd最终结果
    --[[判断是否有权限检定--]]
    if tonumber(group_state["Xrastate"]) == 1 and tonumber(isadmin) <= 1 and tonumber(group_state["KP"]) ~= fromQQ then
        resp = "你没有权限进行xra检定\n当前群聊模式为：1 群管和KP可以使用\n如需更改请使用.kp xra 0/1/2/3 进行设置"
        return resp
    end
    if tonumber(group_state["Xrastate"]) == 2 and tonumber(group_state["KP"]) ~= fromQQ then
        resp = "你没有权限进行xra检定\n当前群聊模式为：2 仅KP可以使用\n如需更改请使用.kp xra 0/1/2/3 进行设置"
        return resp
    end
    if tonumber(group_state["Xrastate"]) == 3 then
        resp = "你没有权限进行xra检定\n当前群聊模式为：3 均不可以使用（关闭）\n如需更改请使用.kp xra 0/1/2/3 进行设置"
        return resp
    end
    --[[获取投掷表达式各项数值--]]
    if tonumber(msg.str_max)==7 then
        --[[str0:".xrab9 cm @雨鸣于舟"	str1:"."	str2:"xra"	str3:"b9"	str4:"cm"	str5:"[CQ:at,qq="	str6:"162****761"--]]
        rbp = msg.str[3]
        Skill = msg.str[4]
        targetQQ = tonumber(msg.str[6])
        if targetQQ == nil then
            resp = "哎呀！at信息好像没有被提取到欸，要不再去重新发一遍试试？\n"
            if Skill == nil then Skill = "nil" end
            if targetQQ == nil then targetQQ = "nil" end
            if Group == nil then Group = "nil" end
            local test = "\ftargetqq:"..targetQQ.."\ngroup:"..Group.."\nskill:"..Skill.."\f正则匹配情况："
            test=test..printstr(msg)--##############debug###############################################################
            return resp..test

        elseif targetQQ == 0 then
            resp = "哎呀！at信息好像没有被提取到欸，要不再去重新发一遍试试？\n"
            if Skill == nil then Skill = "nil" end
            if targetQQ == nil then targetQQ = "nil" end
            if Group == nil then Group = "nil" end
            local test = "\ftargetqq:"..targetQQ.."\ngroup:"..Group.."\nskill:"..Skill.."\f正则匹配情况："
            test=test..printstr(msg)--##############debug###############################################################
            return resp..test
        end
        
    else
        resp = "输入内容错误！请确认输入的式子符合规范，尤其是确认空格是否添加！！！\n正确格式：.xra(h)(bp3) 【技能名称】 【at目标PC】"
        
        return resp
    end
    --[[取技能值判断是否为0--]]
    Skill_Val = tonumber(dice.getPcSkill(targetQQ,Group,Skill))           --取技能值
    if Skill_Val == 0 then                                      --判断是否为0
        resp = "请先设置" .. Skill .. "的技能值！"
        if Skill == nil then Skill = "nil" end
        if targetQQ == nil then targetQQ = "nil" end
        if Group == nil then Group = "nil" end
        local test = "\ftargetqq:"..targetQQ.."\ngroup:"..Group.."\nskill:"..Skill.."\f"
        test=test..printstr(msg)--##############debug###############################################################
        return resp
    end
    --[[处理奖励&惩罚骰部分--]]
    if rbp ~= "" then
        rbp = string.lower(rbp)
        local sign = string.sub(rbp,1,1)                          --b p
        local b=0
        if string.len(rbp)>1 then 
            b = tonumber(string.sub(rbp,2,-1))               --0~9
        else
            b = 1                                         --省略为1
        end
        if b >= 10 then 
            resp = "投掷失败！\n奖励骰or惩罚骰最多为9个"        --奖励惩罚骰过多
            return resp
        end
        if b == 0 or b == nil then
            resp = "你究竟要不要骰奖励骰和惩罚骰啊？"
            return resp
        end
            local diceresult ={}
            local ten = 0                   --10
            local one = 0                  --1
        if sign == "p" then
            ten = 0
            one = dice.rd("1D10")-1
            for i = 1, (b+1), 1 do
                diceresult[i]=dice.rd("1D10")-1
                if diceresult[i] > ten then
                    ten = diceresult[i]
                elseif (one == 0 and diceresult[i]==0) then
                    ten = 10
                    diceresult[i]=10
                end
            end
            total = ten*10 + one
            resp = "{nick}代替[CQ:at,qq="..tostring(targetQQ).."]进行"..Skill.."检定\n"
            resp = resp.."D100="..tostring(diceresult[1])..tostring(one).."[惩罚骰："
            for i=2,b,1 do
                resp = resp..tostring(diceresult[i])..","
            end
            resp = resp..tostring(diceresult[b+1]).."] = "..total.."/"..tostring(Skill_Val).."\t"
            resp = resp..RAsuccess(total,Skill_val,Group)
        elseif sign == "b" then
            ten = 10
            one = dice.rd("1D10")-1
            for i = 1, (b+1), 1 do
                diceresult[i]=dice.rd("1D10")-1
                if diceresult[i] < ten and diceresult[i] > 0 then
                    ten = diceresult[i]
                elseif (one == 0 and diceresult[i]==0) then
                    diceresult[i]=10
                elseif one ~= 0 and diceresult[i]==0 then
                    diceresult[i] = 0
                    ten = 0
                end
            end
            total = ten*10 + one
            resp = "{nick}代替[CQ:at,qq="..tostring(targetQQ).."]进行"..Skill.."检定\n"
            resp = resp.."D100="..tostring(diceresult[1])..tostring(one).."[奖励骰："
            for i=2,b,1 do
                resp = resp..tostring(diceresult[i])..","
            end
            resp = resp..tostring(diceresult[b+1]).."] = "..total.."/"..tostring(Skill_Val).."\t"
            resp = resp..RAsuccess(total,Skill_Val,Group)
        end
    else
        total = dice.rd("1D100")
        resp = "{nick}代替[CQ:at,qq="..tostring(targetQQ).."]进行"..Skill.."检定\n"
        resp = resp.."D100="..total.."/"..tostring(Skill_Val).."\t"
        resp = resp..RAsuccess(total,Skill_Val,Group)
    end

    return resp
end
function Xrah(msg)
    local Skill = ""                                --技能名称
    local Skill_Val = 0                             --技能数值
    local fromQQ = tonumber(msg.fromQQ)             --发送者
    local Group = tonumber(msg.fromGroup)           --群组
    local isadmin = tonumber(msg.fromQQInfo)        --发送者权限
    local targetQQ = 0                              --at目标QQ
    local rbp = ""                                  --惩罚&奖励骰
    local resp = "\n"                               --回复消息
    local group_state = GetGroupState(Group)        --群组参数
    local total = 0                                 --rd最终结果
    --[[判断是否有权限检定--]]
    if tonumber(group_state["Xrastate"]) == 1 and tonumber(isadmin) <= 1 and tonumber(group_state["KP"]) ~= fromQQ then
        resp = "你没有权限进行xra检定\n当前群聊模式为：1 群管和KP可以使用\n如需更改请使用.kp xra 0/1/2/3 进行设置"
        return resp
    end
    if tonumber(group_state["Xrastate"]) == 2 and tonumber(group_state["KP"]) ~= fromQQ then
        resp = "你没有权限进行xra检定\n当前群聊模式为：2 仅KP可以使用\n如需更改请使用.kp xra 0/1/2/3 进行设置"
        return resp
    end
    if tonumber(group_state["Xrastate"]) == 3 then
        resp = "你没有权限进行xra检定\n当前群聊模式为：3 均不可以使用（关闭）\n如需更改请使用.kp xra 0/1/2/3 进行设置"
        return resp
    end

    --[[获取投掷表达式各项数值--]]
    if tonumber(msg.str_max)==7 then
        --[[str0:".xrahb cm @Rainy"	str1:"."	str2:"xrah"	str3:"b"	str4:"cm"	str5:"[CQ:at,qq="	str6:"340****331"	--]]
        rbp = msg.str[3]
        Skill = msg.str[4]
        targetQQ = tonumber(msg.str[6])
        if targetQQ == nil then
            resp = "哎呀！at信息好像没有被提取到欸，要不再去重新发一遍试试？\n"
            if Skill == nil then Skill = "nil" end
            if targetQQ == nil then targetQQ = "nil" end
            if Group == nil then Group = "nil" end
            local test = "\ftargetqq:"..targetQQ.."\ngroup:"..Group.."\nskill:"..Skill.."\f正则匹配情况："
            test=test..printstr(msg)--##############debug###############################################################
            return resp..test

        elseif targetQQ == 0 then
            resp = "哎呀！at信息好像没有被提取到欸，要不再去重新发一遍试试？\n"
            if Skill == nil then Skill = "nil" end
            if targetQQ == nil then targetQQ = "nil" end
            if Group == nil then Group = "nil" end
            local test = "\ftargetqq:"..targetQQ.."\ngroup:"..Group.."\nskill:"..Skill.."\f正则匹配情况："
            test=test..printstr(msg)--##############debug###############################################################
            return resp..test
        end
    else
        resp = "输入内容错误！请确认输入的式子符合规范，尤其是确认空格是否添加！！！\n正确格式：.xra(h)(bp3) 【技能名称】 【at目标PC】"
        return resp
    end
    --[[取技能值判断是否为0--]]
    Skill_Val = tonumber(dice.getPcSkill(targetQQ,Group,Skill))           --取技能值
    if Skill_Val == 0 then                                      --判断是否为0
        if Skill == nil then Skill = "nil" end
        if targetQQ == nil then targetQQ = "nil" end
        if Group == nil then Group = "nil" end
        resp = "请先设置" .. Skill .. "的技能值！"
        local test = "\ftargetqq:"..targetQQ.."\ngroup:"..Group.."\nskill:"..Skill.."\f"
        test=test..printstr(msg)--##############debug###############################################################
        return resp
    end
    --[[处理奖励&惩罚骰部分--]]
    if rbp ~= "" then
        rbp = string.lower(rbp)
        local sign = string.sub(rbp,1,1)                          --b p
        local b=0
        if string.len(rbp)>1 then 
            b = tonumber(string.sub(rbp,2,-1))               --0~9
        else
            b = 1                                         --省略为1
        end
        if b >= 10 then 
            resp = "投掷失败！\n奖励骰or惩罚骰最多为9个"        --奖励惩罚骰过多
            return resp
        end
        if b == 0 or b == nil then
            resp = "你究竟要不要骰奖励骰和惩罚骰啊？"
            return resp
        end
            local diceresult ={}
            local ten = 0                   --10
            local one = 0                  --1
        if sign == "p" then
            ten = 0
            one = dice.rd("1D10")-1
            for i = 1, (b+1), 1 do
                diceresult[i]=dice.rd("1D10")-1
                if diceresult[i] > ten then
                    ten = diceresult[i]
                elseif (one == 0 and diceresult[i]==0) then
                    ten = 10
                    diceresult[i]=10
                end
            end
            total = ten*10 + one
            resp = "在群聊（"..tostring(Group).."）中，你代替[CQ:at,qq="..tostring(targetQQ).."]("
            resp = resp..tostring(targetQQ)..")进行"..Skill.."检定\n".."D100="..tostring(diceresult[1])..tostring(one).."[惩罚骰："
            for i=2,b,1 do
                resp = resp..tostring(diceresult[i])..","
            end
            resp = resp..tostring(diceresult[b+1]).."] = "..total.."/"..tostring(Skill_Val).."\t"
            resp = resp..RAsuccess(total,Skill_Val,Group)
        elseif sign == "b" then
            ten = 10
            one = dice.rd("1D10")-1
            for i = 1, (b+1), 1 do
                diceresult[i]=dice.rd("1D10")-1
                if diceresult[i] < ten and diceresult[i] > 0 then
                    ten = diceresult[i]
                elseif (one == 0 and diceresult[i]==0) then
                    diceresult[i]=10
                elseif one ~= 0 and diceresult[i]==0 then
                    diceresult[i] = 0
                    ten = 0
                end
            end
            total = ten*10 + one
            resp = "在群聊（"..tostring(Group).."）中，你代替[CQ:at,qq="..tostring(targetQQ).."]("
            resp = resp..tostring(targetQQ)..")进行"..Skill.."检定\n".."D100="..tostring(diceresult[1])..tostring(one).."[奖励骰："
            for i=2,b,1 do
                resp = resp..tostring(diceresult[i])..","
            end
            resp = resp..tostring(diceresult[b+1]).."] = "..total.."/"..tostring(Skill_Val).."\t"
            resp = resp..RAsuccess(total,Skill_Val,Group)
        end
    else
        total = dice.rd("1D100")
        resp = "在群聊（"..tostring(Group).."）中，你代替[CQ:at,qq="..tostring(targetQQ).."]("
        resp = resp..tostring(targetQQ)..")进行"..Skill.."检定\n".."D100="..total.."/"..tostring(Skill_Val).."\t"
        resp = resp..RAsuccess(total,Skill_Val,Group)
    end
    dice.send(resp,fromQQ,0)

    return "一颗骰子在帷幕之后滚落\n{nick}代替[CQ:at,qq="..tostring(targetQQ).."] ("..tostring(targetQQ)..")进行了一次暗鉴定"
end

----------------------------------
--[[设置xst模式--]]
function Xst_show_set(msg)
    local resp,file = "" , ""
    local fromQQ = tonumber(msg.fromQQ)
    local trust = GetQQState(fromQQ,msg)
    local group = tonumber(msg.fromGroup)
    local group_state = GetGroupState(group)
    local Xstshow
    local path=basic_path.."group"..tostring(group)..".txt"
    if isnum(tonumber(msg.str[msg.str_max-1])) then
        Xstshow=tonumber(msg.str[msg.str_max-1])
    else
        resp = "表达式错误！\n"..printstr(msg)
        return resp
    end
    if fromQQ ~= tonumber(group_state["KP"]) and trust == 0 then 
        resp = "你没有权限设置群聊Xst模式！\n请由群管理或者KP进行设置!"
        return resp
    else
        group_state["Xstshow"]=Xstshow
        resp = "已将本群xstshow(查询他人技能值)模式改为：\n"..tostring(Xstshow).." "

        if (Xstshow == 0 )then
            resp = resp.."所有人均可使用"
        elseif (Xstshow == 1) then
            resp = resp.."群管和KP可以使用"
        elseif (Xstshow == 2) then
            resp = resp.."仅KP可以使用"
        elseif (Xstshow == 3) then
            resp = resp.."所有人均不可使用（关闭）"
        end
    end
        file = tabletostring(group_state)
        write_file(path,file)
    return resp
end
--[[查询xst状态--]]
function Xst_show_show(msg)
    local resp = "本群Xstshow(查询他人技能值)模式为：\n"
    local group = tonumber(msg.fromGroup)
    local group_state = GetGroupState(group)
    local Xstshow = tonumber(group_state["Xstshow"])
    resp = resp..tostring(Xstshow).." "
    if (Xstshow == 0 )then
        resp = resp.."所有人均可使用"
    elseif (Xstshow == 1) then
        resp = resp.."群管和KP可以使用"
    elseif (Xstshow == 2) then
        resp = resp.."仅KP可以使用"
    elseif (Xstshow == 3) then
        resp = resp.."所有人均不可使用（关闭）"
    end
    return resp
end
--[[查询某个PC技能数值]]
function Xst_show_skill(msg)
    local resp = ""
    local fromQQ = tonumber(msg.fromQQ)
    local trust = GetQQState(fromQQ,msg)
    local group = tonumber(msg.fromGroup)
    local targetQQ = 0
    local skill = ""
    local skill_val = 0
    local group_state = GetGroupState(group)
    local Xstshow = tonumber(group_state["Xstshow"])
    --[[判断权限 0全员 1KP+群管 2KP 3关闭 --]]
    if Xstshow == 1 and trust == 0 then 
        resp = "你没有权限查询他人技能值\n当前群聊模式为：1 群管和KP可以使用\n如需更改请使用.kp xstshow 0/1/2/3 进行设置"
        return resp
    elseif Xstshow == 2 and fromQQ ~= group_state["KP"] then
        resp = "你没有权限查询他人技能值\n当前群聊模式为：2 仅KP可以使用\n如需更改请使用.kp xstshow 0/1/2/3 进行设置"
        return resp
    elseif Xstshow == 3 then 
        resp = "当前本群查询他人技能值已关闭！\n如需更改请使用.kp xstshow 0/1/2/3 进行设置"
        return resp
    end
    --[[
    trust =
            1 0x001 KP
            2 0x010 管理，群主
            4 0x100 DICE_Admin

            3 0x011 KP + 管理
            5 0x101 KP + DICE_Admin
            6 0x110 群管 + DICE_Admin
            7 0x111 KP + 群管 + DICE_Admin
        --]]
    --[[获取投掷表达式各项数值--]]
    if tonumber(msg.str_max)==7 then
    --[[str0:".xst show 心理学 @testdice"	str1:"."	str2:"xst"	str3:"show"	str4:"心理学"	str5:"[CQ:at,qq="	str6:"36******60"--]]
        skill = msg.str[4]
        targetQQ = tonumber(msg.str[6])
        if targetQQ == nil then
            resp = "哎呀！at信息好像没有被提取到欸，要不再去重新发一遍试试？\n"
            if skill == nil then skill = "nil" end
            if targetQQ == nil then targetQQ = "nil" end
            if group == nil then group = "nil" end
            local test = "\ftargetqq:"..targetQQ.."\ngroup:"..group.."\nskill:"..skill.."\f正则匹配情况："
            test=test..printstr(msg)--##############debug###############################################################
            return resp..test

        elseif targetQQ == 0 then
            resp = "哎呀！at信息好像没有被提取到欸，要不再去重新发一遍试试？\n"
            if skill == nil then skill = "nil" end
            if targetQQ == nil then targetQQ = "nil" end
            if group == nil then group = "nil" end
            local test = "\ftargetqq:"..targetQQ.."\ngroup:"..group.."\nskill:"..skill.."\f正则匹配情况："
            test=test..printstr(msg)--##############debug###############################################################
            return resp..test
        end
    else
        resp = "输入内容错误！请确认输入的式子符合规范，尤其是确认空格是否添加！！！\n正确格式：.xst show 【技能名称】 【at目标PC】"
        return resp
    end
        --[[取技能值--]]
    skill_val = tonumber(dice.getPcSkill(targetQQ,group,skill))           --取技能值
    --[[判断是否为0 认为当0的时候也可以输出，故关闭检查
    if skill_val == 0 then                                      --判断是否为0
        if skill == nil then skill = "nil" end
        if targetQQ == nil then targetQQ = 0 end
        if group == nil then group = "nil" end
        resp = "请先设置" .. skill .. "的技能值！"
        local test = "\ftargetqq:"..targetQQ.."\ngroup:"..group.."\nskill:"..skill.."\f"
        test=test..printstr(msg)--##############debug###############################################################
        return resp..test
    end
    --]]
    if skill == nil then skill = "nil" end
    if targetQQ == nil then targetQQ = 0 end
    resp = "当前[CQ:at,qq="..tostring(targetQQ).."]("..tostring(targetQQ)..")的【"
    resp = resp ..skill.."】数值为："..tostring(skill_val)
    return resp
end
--[[设置xst模式--]]
function Xst_set_set(msg)
    local resp,file = "" , ""
    local fromQQ = tonumber(msg.fromQQ)
    local trust = GetQQState(fromQQ,msg)
    local group = tonumber(msg.fromGroup)
    local group_state = GetGroupState(group)
    local Xstset
    local path=basic_path.."group"..tostring(group)..".txt"
    if isnum(tonumber(msg.str[msg.str_max-1])) then
        Xstset=tonumber(msg.str[msg.str_max-1])
    else
        resp = "表达式错误！\n"..printstr(msg)
        return resp
    end
    if fromQQ ~= tonumber(group_state["KP"]) and trust == 0 then 
        resp = "你没有权限设置群聊Xst模式！\n请由群管理或者KP进行设置!"
        return resp
    else
        group_state["Xstset"]=Xstset
        resp = "已将本群xstset(设置他人技能值)模式改为：\n"..tostring(Xstset).." "

        if (Xstset == 0 )then
            resp = resp.."所有人均可使用"
        elseif (Xstset == 1) then
            resp = resp.."群管和KP可以使用"
        elseif (Xstset == 2) then
            resp = resp.."仅KP可以使用"
        elseif (Xstset == 3) then
            resp = resp.."所有人均不可使用（关闭）"
        end
    end
        file = tabletostring(group_state)
        write_file(path,file)
    return resp
end
--[[查询xst状态--]]
function Xst_set_show(msg)
    local resp = "本群Xst(设置他人技能值)模式为：\n"
    local group = tonumber(msg.fromGroup)
    local group_state = GetGroupState(group)
    local Xstset = tonumber(group_state["Xstset"])
    resp = resp..tostring(Xstset).." "
    if (Xstset == 0 )then
        resp = resp.."所有人均可使用"
    elseif (Xstset == 1) then
        resp = resp.."群管和KP可以使用"
    elseif (Xstset == 2) then
        resp = resp.."仅KP可以使用"
    elseif (Xstset == 3) then
        resp = resp.."所有人均不可使用（关闭）"
    end
    return resp
end
--[[设置某个PC技能数值]]
function Xst_set_skill(msg)
    local resp = ""
    local fromQQ = tonumber(msg.fromQQ)
    local trust = GetQQState(fromQQ,msg)
    local group = tonumber(msg.fromGroup)
    local targetQQ = 0
    local skill = ""
    local sign
    local skill_val = 0
    local target_val = 0
    local group_state = GetGroupState(group)
    local Xstset = tonumber(group_state["Xstset"])
    --[[判断权限 0全员 1KP+群管 2KP 3关闭 --]]
    if Xstset == 1 and trust == 0 then 
        resp = "你没有权限设置他人技能值\n当前群聊模式为：1 群管和KP可以使用\n如需更改请使用.kp xstshow 0/1/2/3 进行设置"
        return resp
    elseif Xstset == 2 and fromQQ ~= group_state["KP"] then
        resp = "你没有权限设置他人技能值\n当前群聊模式为：2 仅KP可以使用\n如需更改请使用.kp xstshow 0/1/2/3 进行设置"
        return resp
    elseif Xstset == 3 then 
        resp = "当前本群设置他人技能值已关闭！\n如需更改请使用.kp xstshow 0/1/2/3 进行设置"
        return resp
    end
    --[[
    trust =
            1 0x001 KP
            2 0x010 管理，群主
            4 0x100 DICE_Admin

            3 0x011 KP + 管理
            5 0x101 KP + DICE_Admin
            6 0x110 群管 + DICE_Admin
            7 0x111 KP + 群管 + DICE_Admin
        --]]
    --[[获取投掷表达式各项数值--]]
    if tonumber(msg.str_max)==8 then
            --[[.xst 心理学 25 @xxx 设置xst --]]
    --command["(\\.|。|＊|\\*)(xst|xST)\\s*([^\\d]+?)\\s*(\\d+?)\\s*(\\[CQ:at,qq=)(\\d{4,})\\]"] = "Xst_set_skill"
    --[[str0:".xst 心理学 25 @testdice"	str1:"."	str2:"xst"	str3:"心理学"	str4:"+"	str5:"25"	str6:"[CQ:at,qq="	str7:"36******60"--]]
        skill = msg.str[3]
        targetQQ = tonumber(msg.str[7])
        target_val = tonumber(msg.str[5])
        if target_val == nil then
            resp = "请填写目标技能值!"
            return resp
        end
        sign = msg.str[4]
        if sign == "" or sign == nil then
            sign = "set"
        end
        if targetQQ == nil then
            resp = "哎呀！at信息好像没有被提取到欸，要不再去重新发一遍试试？\n"
            if skill == nil then skill = "nil" end
            if targetQQ == nil then targetQQ = "nil" end
            if target_val == nil then target_val = "nil" end
            if group == nil then group = "nil" end
            local test = "\ftargetqq:"..targetQQ.."\ngroup:"..group.."\nskill:"..skill.."\ntarget_val:"..target_val.."\f正则匹配情况："
            test=test..printstr(msg)--##############debug###############################################################
            return resp..test

        elseif targetQQ == 0 then
            resp = "哎呀！at信息好像没有被提取到欸，要不再去重新发一遍试试？\n"
            if skill == nil then skill = "nil" end
            if targetQQ == nil then targetQQ = "nil" end
            if target_val == nil then target_val = "nil" end
            if group == nil then group = "nil" end
            local test = "\ftargetqq:"..targetQQ.."\ngroup:"..group.."\nskill:"..skill.."\ntarget_val:"..target_val.."\f正则匹配情况："
            test=test..printstr(msg)--##############debug###############################################################
            return resp..test
        end
    else
        resp = "输入内容错误！请确认输入的式子符合规范，尤其是确认空格是否添加！！！\n正确格式：.xst show 【技能名称】 【at目标PC】"
        return resp
    end
        --[[取技能值--]]
    skill_val = tonumber(dice.getPcSkill(targetQQ,group,skill)) or 0           --取技能值
    if skill == nil then
        resp = "请检技能名称内容是否正确！"
        return resp
    end
    --[[根据sign判断设置方式]]
    if sign == "set" then
        --dice.setPcSkill(QQ,Group,Skill,Skill_Val)
        dice.setPcSkill(targetQQ,group,skill,target_val)
        resp = "调整PC技能值成功！\n"
        resp = resp.."已将[CQ:at,qq="..tostring(targetQQ).."]("..tostring(targetQQ)..")的【"
        resp = resp..skill.."】数值改为：\n".."原数值："..tostring(skill_val).." ==> 现数值："
        resp = resp..tostring(target_val)
        return resp
    elseif sign == "+" then
        local skill_change = target_val
        target_val = skill_val + target_val
        dice.setPcSkill(targetQQ,group,skill,target_val)
        resp = "调整PC技能值成功！\n"
        resp = resp.."已将[CQ:at,qq="..tostring(targetQQ).."]("..tostring(targetQQ)..")的【"
        resp = resp..skill.."】数值改为：\n".."原数值："..tostring(skill_val).."（+ "..tostring(skill_change)
        resp = resp.."） ==> 现数值："..tostring(target_val)
        return resp
    elseif sign == "-" then
        local skill_change = target_val
        target_val = skill_val - target_val
        dice.setPcSkill(targetQQ,group,skill,target_val)
        resp = "调整PC技能值成功！\n"
        resp = resp.."已将[CQ:at,qq="..tostring(targetQQ).."]("..tostring(targetQQ)..")的【"
        resp = resp..skill.."】数值改为：\n".."原数值："..tostring(skill_val).."（- "..tostring(skill_change)
        resp = resp.."） ==> 现数值："..tostring(target_val)
        return resp
    else
        return "设置失败，请确定表达式是否正确！\nsign: \""..sign..'"'
    end
    --[[
    --if targetQQ == nil then targetQQ = 0 end
    resp = "当前[CQ:at,qq="..tostring(targetQQ).."]("..tostring(targetQQ)..")的【"
    resp = resp ..skill.."】数值改为：\n"..tostring(skill_val)
    ]]

    return "设置失败，未知错误x"
end
--[[
function Xst_set(msg)
  local Group = tonumber(msg.fromGroup)
  local fromQQ = tonumber(msg.fromQQ)
  local group_state = GetGroupState(Group)
  local trust = tonumber(GetQQState(fromQQ,msg))
  Xstset = tonumber(group_state["Xstset"])
  local resp = ""
  local Skill = ""
  local Skill_val = 0
  local targetQQ = 0
  
  if Xstset == 1 and trust == 0 then 

        resp = "你没有权限查询他人技能值\n当前群聊模式为：1 群管和KP可以使用\n如需更改请使用.kp xstshow 0/1/2/3 进行设置"

        return resp
    elseif Xstset == 2 and fromQQ ~= group_state["KP"] then
        resp = "你没有权限查询他人技能值\n当前群聊模式为：2 仅KP可以使用\n如需更改请使用.kp xstshow 0/1/2/3 进行设置"
        return resp
    elseif Xstset == 3 then 
        resp = "当前本群查询他人技能值已关闭！\n如需更改请使用.kp xstshow 0/1/2/3 进行设置"
        return resp
    end
  if tonumber(msg.sr_max)-1 == 5 then
  -- 1 .xst 2 SKILL 3 +- 4 123 5 targetQQ
    
  else
    
    
  end
  
end
]]
--[[可用的接口
    传入参数
        --{0,1}全{0,1}图{0,1}介{0,1}
        msg.msg 本条消息
        msg.str[int] 正则表达式的第int个子表达式，为0时为原消息
        msg.str_max 上一条中int可达到的最大值
        msg.msgType 消息类型，0为私聊，1为群聊
        msg.selfId 本机QQ
        msg.fromQQ 本条消息发送者QQ
        msg.fromGroup 本条消息所在群号
        msg.tergetId 如果为私聊则为本条消息发送者QQ，否则为本条消息所在群号
        msg.fromQQTrust 本条消息发送者的信任度
        msg.fromQQInfo 本条消息发送者的群内权限，0为私聊，1为群员，2为管理，3为群主
    dice模块
        dice.draw(msg)
        dice.send(msg,tergetId,msgType)
        dice.int2string(msg)
        dice.rd(msg)
        dice.md5(msg)
        dice.DiceDir()
        dice.GBKtoUTF8(str)
        dice.UTF8toGBK(str)
        dice.getPcSkill(QQ,Group,Skill)
        dice.setPcSkill(QQ,Group,Skill,Skill_Val)
]]

--[[初始setcoc规则
    为当前群或讨论组设置COC房规，如.setcoc 1,当前参数0-5
0 规则书
出1大成功
不满50出96 - 100大失败，满50出100大失败
1
不满50出1大成功，满50出1 - 5大成功
不满50出96 - 100大失败，满50出100大失败
2
出1 - 5且 <= 成功率大成功
出100或出96 - 99且 > 成功率大失败
3
出1 - 5大成功
出96 - 100大失败
4
出1 - 5且 <= 十分之一大成功
不满50出 >= 96 + 十分之一大失败，满50出100大失败
5
出1 - 2且 < 五分之一大成功
不满50出96 - 100大失败，满50出99 - 100大失败
如果其他房规可向开发者反馈
无论如何，群内检定只会调用群内设置，否则后果将是团内成员不对等

--]]