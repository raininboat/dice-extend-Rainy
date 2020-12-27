command = {};
--[[
    MP快速查询和变更 V1.0 by 雨鸣于舟（1620706761）
    直接使用。MP .MP *mp ＊mp可以查询当前MP
    使用。|.|*|＊ MP +-123可以快速修改当前mp

]]--
local pc_mp,resp,QQ,Group,change,sign,mp_changed,change_abs
function MP(Msg)
    QQ = Msg.fromQQ
    Group = Msg.fromGroup
    resp=""
    sign=""
    pc_mp = dice.getPcSkill(QQ,Group,"mp")

    if (Msg.str_max==5)
    then
        sign = Msg.str[3]
        change_abs = tonumber(Msg.str[4])
        if sign =="+" 
        then 
            change = change_abs        --为了+也有符号
        elseif sign == "-"
        then 
            change = -change_abs
        else
            resp = "MP查询设置模块错误：请检查输入内容或联系Master！\n"
            resp = resp.."————————————\n".."SIGN = \""..sign..'"'
            return resp
        end
    elseif (Msg.str_max==3) --查询HP
    then
        resp = "{pc}的MP为："..dice.int2string(pc_mp)
        return resp
    else
        resp = "MP查询设置模块错误：请检查输入内容或联系Master！\n"
        resp = resp.."————————————\n".."str_max = "..dice.int2string(Msg.str_max).."\n"
        for i = 0,(Msg.str_max-1), 1 do
            resp = resp .."str"..dice.int2string(i)..':"'..Msg.str[i]..'"\t'
        end
        return resp
    end

    mp_changed = pc_mp + change
    dice.setPcSkill(QQ,Group,"mp",mp_changed)
    resp = "{pc}的MP变更成功：\n"
    resp = resp.."原数值："..dice.int2string(pc_mp).." （"..sign..tostring(change_abs).."） ==> 现数值："..dice.int2string(mp_changed)
--无法包含+号    resp = resp.."原数值："..dice.int2string(pc_mp).." （"..tostring(change).."） ==> 现数值："..dice.int2string(mp_changed)
    return resp
end

    command["(\\.|。|＊|\\*)(mp|MP)"] = "MP"
    command["(\\.|。|＊|\\*)(mp|MP)\\s*(\\+|\\-)([\\d]+?)"] = "MP"

