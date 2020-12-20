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
command["(\\.|。|＊|\\*)(setrule)"] = "testing"
command["(\\.|。|＊|\\*)(setrule)\\s*?(\\d)"] = "setRuleClassic"
command["(\\.|。|＊|\\*)(setrule)\\s*(\\d+\\.?\\d*)\\s(\\d+\\.?\\d*)\\s*(\\d+\\.?\\d*)\\s*(\\d+\\.?\\d*)\\s*(\\d+\\.?\\d*)\\s*(\\d+\\.?\\d*)\\s*(\\d+\\.?\\d*)\\s*(\\d+\\.?\\d*)\\s*(\\d+\\.?\\d*)"] = "setRuleFull"
local basic_path = dice.DiceDir()
package.path = package.path..";"..dice.DiceDir().. "\\plugin\\?\\?.lua"
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
    for i = 1, 9 do
        -- statements
        setcoc[i] = msg.str[i+2]
    end
    local userdata = M.getUserState(target,isGroup)
    userdata.setcoc = setcoc
    M.saveUserState(userdata,target,isGroup)
    return
    --if tonumber(msg.str_max==)
end
function testing(msg)
    return "testing123\n"--..package.path.."\n"..dice.DiceDir()
end