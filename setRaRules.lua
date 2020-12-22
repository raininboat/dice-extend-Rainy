--[[
#      _____       _
#     |  __ \     (_)
#     | |__) |__ _ _ _ __  _   _
#     |  _  // _` | | '_ \| | | |
#     | | \ \ (_| | | | | | |_| |
#     |_|  \_\__,_|_|_| |_|\__, |
#                           __/ |
#                          |___/

    setRaRules  设置RA检定房规  by 雨鸣于舟
]]

command = {}
command["(\\.|。|＊|\\*)(tra)\\s*(\\d+)\\s*(\\d+)"] = "testing"
command["(\\.|。|＊|\\*)(setrule)\\s*?(\\d)"] = "setRuleClassic"
command["(\\.|。|＊|\\*)(setrule)\\s*(\\d+\\.?\\d*)\\s+(\\d+\\.?\\d*)\\s+(\\d+\\.?\\d*)\\s+(\\d+\\.?\\d*)\\s+(\\d+\\.?\\d*)\\s+(\\d+\\.?\\d*)\\s+(\\d+\\.?\\d*)\\s+(\\d+\\.?\\d*)\\s+(\\d+\\.?\\d*)"] = "setRuleFull"
-- local basic_path = dice.DiceDir()
-- package.path = package.path..";"..dice.DiceDir().. "\\plugin\\?\\?.lua"
--require(Rainy)
function setRuleClassic(msg)
    require("Rainy")
    return M.printstr(msg)
end
-- 设置村规
function setRuleFull(msg)
    require("Rainy")
    msg = msg or {}
    local setcoc = {}               -- 房规数组
    local isGroup = msg.msgType     -- 判断聊天类型
    local target = msg.tergetId     -- 获取窗口号
    --local userPath = basic_path
--    dice.send(M.printstr(msg),target,1)
    for i = 1, tonumber(msg.str_max-1) do
        -- statements
        -- if not tonumber(msg.str[i+2]) then return msg.str[i+2].."输入内容非法" end
        setcoc[i] = tonumber(msg.str[i+2])
    end
    if ((setcoc[1]+setcoc[2]*setcoc[9])>=(setcoc[5]+setcoc[6]*setcoc[9])) or ((setcoc[3]+setcoc[4]*setcoc[9])>=(setcoc[7]+setcoc[8]*setcoc[9]))
    then
        return "设置失败，当前大成功最大值大于大失败最小值"
    end

    local userdata = M.getUserState(target,isGroup)
    userdata.setcoc = setcoc
    M.saveUserState(userdata,target,isGroup)
    return M.tabletostring(userdata.setcoc)
    --if tonumber(msg.str_max==)
end

function testing(msg)
    require("Rainy")
    local skill = tonumber(msg.str[3])
    local val = tonumber(msg.str[4])
    local isGroup = msg.msgType     -- 判断聊天类型
    local target = msg.tergetId     -- 获取窗口号
    local userdata = M.getUserState(target,isGroup)
    local rank = M.Rasuccess(skill,val,userdata.setcoc)
    local level = ""
    if rank == 1 then level = "大成功"
    elseif rank == 2 then level = "极难成功"
    elseif rank == 3 then level = "困难成功"
    elseif rank == 4 then level = "成功"
    elseif rank == 5 then level = "失败"
    elseif rank == 6 then level = "大失败"
    else level = "【无法判定成功率】"
    end
    local resp = "test\n"..skill.." / "..val.." ["..level.."] \n"
    -- resp = resp .. M.tabletostring(userdata.setcoc)
    return resp  --..package.path.."\n"..dice.DiceDir()
end