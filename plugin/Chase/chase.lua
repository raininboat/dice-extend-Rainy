command = {}
-- .chase 看追逐轮相关内容
command["(\\.|。)(chase)\\s*(help)?"] = "Chase_help"

-- .chase 看追逐轮相关内容
command["(\\.|。)(chase)?\\s*?(rule[s]?)"] = "Chase_RULES"

-- .chase set (name)  pl设置加入追逐轮
command["(\\.|。)(chase)\\s*?(set)\\s*?(^\\s*)?"] = "Chase_set"

-- .chase start 开启追逐轮
command["(\\.|。)(chase)\\s*?(start|on)"] = "Chase_start"

-- .chase stop 关闭追逐轮
command["(\\.|。)(chase)\\s*?(stop|off)"] = "Chase_stop"

-- .chase clr 清空追逐轮状态
command["(\\.|。)(chase)\\s*?(clr|clear|del)"] = "Chase_clear"

-- .chase print 发送状态
-- command["(\\.|。)(chase)\\s*?(print)\\s*?(location|loc|init|map)"] = "Chase_print"

-- .chase next 结束回合，下一位pl
command["(\\.|。)(chase)\\s*?(skip|next)"] = "Chase_nextTurn"

-- .chase pos
-- command["(\\.|。)(chase)\\s*?(pos)\\s*?([+-]?)(\\d*)"] = "Chase_changePos"

-- 调整设置MOV
command["(\\.|。)(chase)?\\s*?(speed|mov|MOV)\\s*?([+-]?)(\\d*)"] = "Chase_setSpeed"


function Chase_help(msg)
    local resp = "chase_help 未完成"
    return resp
end

function Chase_RULES(msg)
    local resp = "chase_Rules 未完成"
    return resp
end

function Chase_help(msg)
    local resp = "chase_help 未完成"
    return resp
end
