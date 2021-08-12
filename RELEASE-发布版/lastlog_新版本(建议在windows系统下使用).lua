--[=[
#      _____       _
#     |  __ \     (_)
#     | |__) |__ _ _ _ __  _   _
#     |  _  // _` | | '_ \| | | |
#     | | \ \ (_| | | | | | |_| |
#     |_|  \_\__,_|_|_| |_|\__, |
#                           __/ |
#                          |___/
    群历史log V0.2  by 雨鸣于舟 20210809
    建议在Windows下使用
    ]=]
command = {["(\\.|。)last\\s*log"] = "lastlog"}
function lastlog(msg)
    if msg.msgType == 0 then return "请在群组中使用本功能" end
    if package.config:sub(1,1)=="/" then   -- 如果是linux系统，则使用老版本，只能读取最新一个内容
        local userPath = dice.DiceDir() .. "\\user\\session\\" .. tostring(msg.fromGroup) .. ".json"
        local data = dice.fGetJson(userPath, "0", "log", "file")
        if data == "0" then
            return "本群无log内容，请重试！"
        end
        return "本群上次log内容：\nhttps://logpainter.kokona.tech/?s3=" .. data .. "\n需.log end成功上传才可读取"
    end
    local CMD_command = 'dir /B/O:-N "{logPath}" | findstr "{groupNumber}"'   -- cmd指令，获取指定group的log文件名
    local logPath = dice.DiceDir().."\\user\\log\\*.txt"
    local web = "https://logpainter.kokona.tech/?s3="
    local groupNumber = "group_"..tostring(msg.fromGroup)
    CMD_command = string.gsub(CMD_command,"{logPath}",logPath)
    CMD_command = string.gsub(CMD_command,"{groupNumber}",groupNumber)
    local tempfile = io.popen(CMD_command,"r")
    local logname = ""
    local logtime = ""
    -- print(os.date("%Y-%m-%d %H:%M %S", os.time()))
    local resp = "以下为本群近期跑团记录：\n"
    if io.type(tempfile) ~= "file" then return "查询log失败！" end
    for i = 1, 3, 1 do
        logname = tempfile:read("*l")
        if logname == nil then
            break
        end
        logtime = os.date("%Y年%m月%d日 %H:%M", tonumber(string.sub(string.match(logname,"%d+%.txt"),1,-5)))
        resp = resp .. logtime.." : \t"..web..logname.."\n"
    end
    tempfile:close()
    return resp
end