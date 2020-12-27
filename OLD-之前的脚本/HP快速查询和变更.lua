command = {};
local pc_hp,resp,QQ,Group,change,sign,hp_changed,change_abs

--[[
    HP快速查询和变更 V1.0 by 雨鸣于舟（1620706761）
    由于。hp在DICE！中已经占用（暗偷惩罚骰），故。hp .hp无法使用
    直接使用(。HP .HP 目前无法使用)*hp ＊hp可以查询当前HP
    使用*|＊ HP +-123可以快速修改当前hp
]]--
function HP(Msg)
    QQ = Msg.fromQQ
    Group = Msg.fromGroup
    resp=""
    sign=""
    pc_hp = dice.getPcSkill(QQ,Group,"hp")

    if (Msg.str_max==5)
    --[[
        1 nil
        2 nil
        3 为符号
        4 为变更数据
    ]]--
    then
        sign = Msg.str[3]
        change_abs = tonumber(Msg.str[4])
        if sign =="+" 
        then 
            change = change_abs
        elseif sign == "-"
        then 
            change = -change_abs
        else
            resp = "HP查询设置模块错误：请检查输入内容或联系Master！\n"
            resp = resp.."————————————\n".."SIGN = \""..sign..'"'
            return resp
        end
    elseif (Msg.str_max==3) --查询HP
    then
        resp = "{pc}的HP为："..dice.int2string(pc_hp)
        return resp
    else
        resp = "HP查询设置模块错误：请检查输入内容或联系Master！\n"
        resp = resp.."————————————\n".."str_max = "..dice.int2string(Msg.str_max).."\n"
        for i = 0,(Msg.str_max-1), 1 do
            resp = resp .."str"..dice.int2string(i)..':"'..Msg.str[i]..'"\t'
        end
        return resp
    end

    hp_changed = pc_hp + change
    dice.setPcSkill(QQ,Group,"hp",hp_changed)
    resp = "{pc}的HP变更成功：\n"
    resp = resp.."原数值："..dice.int2string(pc_hp).." （"..sign..change_abs.."） ==> 现数值："..dice.int2string(hp_changed)

    return resp
end


    command["(\\.|。|＊|\\*)(hp|HP)"] = "HP"
    command["(\\.|。|＊|\\*)(hp|HP)\\s*(\\+|\\-)([\\d]+?)"] = "HP"