local modname = "Rainy"
local M = {}
_G[modname] = M
package.loaded[modname] = M

setmetatable(M,{__index = _G})
setfenv(1,M)

-- 读取对应的文件
-- path -> str ----- 文件路径
function read_file(path)
    path = path or ""
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
function write_file(path, data)
    path = path or "\\"
    data = data or ""
    local file = io.open(path, "w") -- 以只写的方式
    file.write(file, data) -- 写入内容
    io.close(file) -- 关闭文件
end


-- 检测是否为数值
function isnum(text)
    return tonumber(text) ~= nil
end

-- 打印各正则表达式
-- Msg  ->  table ----- 为Dice给出聊天信息表
function printstr(Msg)
    Msg = Msg or {}
    local resp =""
     for i = 0,(Msg.str_max-1), 1 do
         resp = resp .."str"..tostring(i)..':"'..Msg.str[i]..'"\t'
     end
     return resp
 end

-- COC RA 成功率房规判定
-- total -> int ----- 投掷出目
-- Skill_val -> int ----- 技能值
-- setcoc -> int ----- 当前房规（0~5 详见 Dice！系列官方手册）
-- （可选 ifReturnNum -> int ） ----- 返回值类型 （0~2 0为纯文本，1为数据[其中1~6从大成功到大失败依次递增]，2 为文本+数据）
function RAsuccess(total,Skill_val,setcoc,ifReturnNum)
    total = total or 0
    Skill_val = Skill_val or 0
    setcoc = setcoc or 0
    local mode = ifReturnNum or 0

    -- 非法数据强制合法化为默认值
    if mode > 2 or mode < 0 then mode = 0 end
    if setcoc > 5 or setcoc < 0 then setcoc = 0 end

    if mode == 0 then       -- 返回文本版成功or失败
        if (setcoc == 0 )then
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
        elseif (setcoc == 1) then
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
        elseif (setcoc == 2) then
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
        elseif (setcoc == 3) then
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
        elseif (setcoc == 4) then
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
        elseif (setcoc == 5) then
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

    elseif mode == 1 then           -- 返回数字版成功 or 失败

        if (setcoc == 0 )then
            if (total >= 96 and  Skill_val < 50 ) or (total == 100 and  Skill_val >= 50 ) then
                return 6		-- 大失败
            elseif total == 1 then
                return 1		-- 大成功
            elseif total > Skill_val then
                return 5		-- 失败
            elseif total <= Skill_val and total > Skill_val/2 and total ~= 1 then
                return 4		-- 成功
            elseif total <= Skill_val/2 and total > Skill_val/5 and total ~= 1 then
                return 3		-- 困难成功
            elseif total <= Skill_val/5 and total ~= 1 then
                return 2		-- 极难成功
            end
            --  规则书\n出1大成功\n不满50出96 - 100大失败，满50出100大失败"
        elseif (setcoc == 1) then
            if (total >= 96 and  Skill_val < 50 ) or (total == 100 and  Skill_val >= 50 ) then
                return 6		-- 大失败
            elseif (total == 1 and  Skill_val < 50 ) or (total <= 5 and  Skill_val >= 50 )then
                return 1		-- 大成功
            elseif total > Skill_val then
                return 5		-- 失败
            elseif total <= Skill_val and total > Skill_val/2 then
                return 4		-- 成功
            elseif total <= Skill_val/2 and total > Skill_val/5 then
                return 3		-- 困难成功
            elseif total <= Skill_val/5 then
                return 2		-- 极难成功     --and ((total ~= 1 and Skill_val < 50) or (total > 5 and Skill_val >50))
            end
            --"\n不满50出1大成功，满50出1 - 5大成功\n不满50出96 - 100大失败，满50出100大失败"
        elseif (setcoc == 2) then
            if (total >= 96 and  Skill_val < total ) or (total == 100) then
                return 6		-- 大失败
            elseif (total <= 5 and  Skill_val >= total)then
                return 1		-- 大成功
            elseif total > Skill_val then
                return 5		-- 失败
            elseif total <= Skill_val and total > Skill_val/2 and total > 5 then
                return 4		-- 成功
            elseif total <= Skill_val/2 and total > Skill_val/5 and total > 5 then
                return 3		-- 困难成功
            elseif total <= Skill_val/5 and total > 5 then
                return 2		-- 极难成功
            end
            --resp = resp.."\n出1 - 5且 <= 成功率大成功\n出100或出96 - 99且 > 成功率大失败"
        elseif (setcoc == 3) then
            if (total >= 96 ) then
                return 6		-- 大失败
            elseif (total <= 5) then
                return 1		-- 大成功
            elseif total > Skill_val then
                return 5		-- 失败
            elseif total <= Skill_val and total > Skill_val/2 and total > 5 then
                return 4		-- 成功
            elseif total <= Skill_val/2 and total > Skill_val/5 and total > 5 then
                return 3		-- 困难成功
            elseif total <= Skill_val/5 and total > 5 then
                return 2		-- 极难成功
            end
            --resp = resp.."\n出1 - 5大成功\n出96 - 100大失败"
        elseif (setcoc == 4) then
            if (total >= (96 + Skill_val/10 ) and  Skill_val < 50 ) or (total == 100 and Skill_val >= 50) then
                return 6		-- 大失败
            elseif (total <= 5 and total <= Skill_val/10)then
                return 1		-- 大成功
            elseif total > Skill_val then
                return 5		-- 失败
            elseif total <= Skill_val and total > Skill_val/2  then
                return 4		-- 成功
            elseif total <= Skill_val/2 and total > Skill_val/5 then
                return 3		-- 困难成功
            elseif total <= Skill_val/5 then
                return 2		-- 极难成功
            end
            --resp = resp.."\n出1 - 5且 <= 十分之一大成功\n不满50出 >= 96 + 十分之一大失败，满50出100大失败"
        elseif (setcoc == 5) then
            if (total >= 96  and  Skill_val < 50 ) or (total >= 99 and Skill_val >= 50) then
                return 6		-- 大失败
            elseif (total <= 5 and total <= Skill_val/5) then
                return 1		-- 大成功
            elseif total > Skill_val then
                return 5		-- 失败
            elseif total <= Skill_val and total > Skill_val/2  then
                return 4		-- 成功
            elseif total <= Skill_val/2 and total > Skill_val/5 then
                return 3		-- 困难成功
            elseif total <= Skill_val/5 then
                return 2		-- 极难成功
            end
            --resp = resp.."\n出1 - 2且 < 五分之一大成功\n不满50出96 - 100大失败，满50出99 - 100大失败"
        end
    elseif mode == 2 then
        if (setcoc == 0 )then
            if (total >= 96 and  Skill_val < 50 ) or (total == 100 and  Skill_val >= 50 ) then
                return "大失败！" , 6		-- 大失败
            elseif total == 1 then
                return "大成功！" , 1		-- 大成功
            elseif total > Skill_val then
                return "失败！" , 5		-- 失败
            elseif total <= Skill_val and total > Skill_val/2 and total ~= 1 then
                return "成功！" , 4		-- 成功
            elseif total <= Skill_val/2 and total > Skill_val/5 and total ~= 1 then
                return "困难成功！" , 3		-- 困难成功
            elseif total <= Skill_val/5 and total ~= 1 then
                return "极难成功！" , 2		-- 极难成功
            end
            --  规则书\n出1大成功\n不满50出96 - 100大失败，满50出100大失败"
        elseif (setcoc == 1) then
            if (total >= 96 and  Skill_val < 50 ) or (total == 100 and  Skill_val >= 50 ) then
                return "大失败！" , 6		-- 大失败
            elseif (total == 1 and  Skill_val < 50 ) or (total <= 5 and  Skill_val >= 50 )then
                return "大成功！" , 1		-- 大成功
            elseif total > Skill_val then
                return "失败！" , 5		-- 失败
            elseif total <= Skill_val and total > Skill_val/2 then
                return "成功！" , 4		-- 成功
            elseif total <= Skill_val/2 and total > Skill_val/5 then
                return "困难成功！" , 3		-- 困难成功
            elseif total <= Skill_val/5 then
                return "极难成功！" , 2		-- 极难成功     --and ((total ~= 1 and Skill_val < 50) or (total > 5 and Skill_val >50))
            end
            --"\n不满50出1大成功，满50出1 - 5大成功\n不满50出96 - 100大失败，满50出100大失败"
        elseif (setcoc == 2) then
            if (total >= 96 and  Skill_val < total ) or (total == 100) then
                return "大失败！" , 6		-- 大失败
            elseif (total <= 5 and  Skill_val >= total)then
                return "大成功！" , 1		-- 大成功
            elseif total > Skill_val then
                return "失败！" , 5		-- 失败
            elseif total <= Skill_val and total > Skill_val/2 and total > 5 then
                return "成功！" , 4		-- 成功
            elseif total <= Skill_val/2 and total > Skill_val/5 and total > 5 then
                return "困难成功！" , 3		-- 困难成功
            elseif total <= Skill_val/5 and total > 5 then
                return "极难成功！" , 2		-- 极难成功
            end
            --resp = resp.."\n出1 - 5且 <= 成功率大成功\n出100或出96 - 99且 > 成功率大失败"
        elseif (setcoc == 3) then
            if (total >= 96 ) then
                return "大失败！" , 6		-- 大失败
            elseif (total <= 5) then
                return "大成功！" , 1		-- 大成功
            elseif total > Skill_val then
                return "失败！" , 5		-- 失败
            elseif total <= Skill_val and total > Skill_val/2 and total > 5 then
                return "成功！" , 4		-- 成功
            elseif total <= Skill_val/2 and total > Skill_val/5 and total > 5 then
                return "困难成功！" , 3		-- 困难成功
            elseif total <= Skill_val/5 and total > 5 then
                return "极难成功！" , 2		-- 极难成功
            end
            --resp = resp.."\n出1 - 5大成功\n出96 - 100大失败"
        elseif (setcoc == 4) then
            if (total >= (96 + Skill_val/10 ) and  Skill_val < 50 ) or (total == 100 and Skill_val >= 50) then
                return "大失败！" , 6		-- 大失败
            elseif (total <= 5 and total <= Skill_val/10)then
                return "大成功！" , 1		-- 大成功
            elseif total > Skill_val then
                return "失败！" , 5		-- 失败
            elseif total <= Skill_val and total > Skill_val/2  then
                return "成功！" , 4		-- 成功
            elseif total <= Skill_val/2 and total > Skill_val/5 then
                return "困难成功！" , 3		-- 困难成功
            elseif total <= Skill_val/5 then
                return "极难成功！" , 2		-- 极难成功
            end
            --resp = resp.."\n出1 - 5且 <= 十分之一大成功\n不满50出 >= 96 + 十分之一大失败，满50出100大失败"
        elseif (setcoc == 5) then
            if (total >= 96  and  Skill_val < 50 ) or (total >= 99 and Skill_val >= 50) then
                return "大失败！" , 6		-- 大失败
            elseif (total <= 5 and total <= Skill_val/5) then
                return "大成功！" , 1		-- 大成功
            elseif total > Skill_val then
                return "失败！" , 5		-- 失败
            elseif total <= Skill_val and total > Skill_val/2  then
                return "成功！" , 4		-- 成功
            elseif total <= Skill_val/2 and total > Skill_val/5 then
                return "困难成功！" , 3		-- 困难成功
            elseif total <= Skill_val/5 then
                return "极难成功！" , 2		-- 极难成功
            end
            --resp = resp.."\n出1 - 2且 < 五分之一大成功\n不满50出96 - 100大失败，满50出99 - 100大失败"
        end
    else
        error("未知错误 RainyMods #337 mode不合法")
    end
end

--[==[
    获取群组情况等内容，由于目前准备进行保存方式升级，暂时不开放

-- 分割保存的文件成为数组
function split_data(s)
    local t = {}
    for k, v in string.gmatch(s, "(%w+)=([%d-]+);\n") do
        t[k] = v
    end
    return t
end

-- 将数组转化为字符串等待保存
function tabletostring(table)
    local a=""
    for key, value in pairs(table) do
        a=a..key.."="..value..";\n"
    end
    --a=string.sub(a, 1, -2)
    return a
end

-- 获取群组情况数组
function GetGroupState(group)
    local file,group_state= "", ""
    local patha=basic_path.."group"..tostring(group)..".txt"
    file = read_file(patha)         -- 读取群聊data
    group_state=split_data(file)    -- 转换为数组
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


-- 获取用户状态（1 KP，2 群管，4 DICE_Admin）
-- 由于当前无查询群员状态函数，故使用 Msg （只能获取当前发送者的QQ）
-- QQ   ->  int    ----- 待查询QQ号
-- Msg  ->  table  ----- Dice给出聊天信息表
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
    QQ = QQ or 0
    Msg = Msg or {}
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
]==]