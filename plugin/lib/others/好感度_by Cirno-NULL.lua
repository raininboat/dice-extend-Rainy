command = {}
today_favor_limit = 3 ---单日次数上限
today_favor_max = 3 ---单日次数上限
favor_once = 1 -- 单次好感上升
function mkDirs(path)
    os.execute('mkdir "' .. path .. '"')
end
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
function split(str, reps)
    local resultStrList = {}
    string.gsub(
        str,
        "[^" .. reps .. "]+",
        function(w)
            table.insert(resultStrList, w)
        end
    )
    return resultStrList
end
--[[分割输入的内容成数组
    string库的gsub函数，共三个参数：
    1. str是待分割的字符串
    2. '[^'..reps..']+'是正则表达式，查找非reps字符，并且多次匹配
    3. 每次分割完的字符串都能通过回调函数获取到，w参数就是分割后的一个子字符串，把它保存到一个table中
    --这里不知道function是干啥用的
]]
function split_favor(s)
    local t = {}
    for k, v in string.gmatch(s, "(%w+)=([%d-]+)") do
        t[k] = v
    end
    return t
end
--[[分割保存的好感度成为数组]]
function isnum(text)
    return tonumber(text) ~= nil
end
--[[检查是不是数字]]
function return_user(patha, pathb)
    local total = ""
    local user_file = read_file(patha) -- 读取用户文件内容
    local user_favor = split_favor(user_file) -- 分割成数组
    if user_favor["date"] ~= os.date("%Y-%m-%d") then
        user_favor["date"] = os.date("%Y-%m-%d")
        user_favor["time"] = 0
    end
    -- 用户存档时间
    if isnum(user_favor["time"]) ~= true then
        user_favor["time"] = favor_once
    else
        user_favor["time"] = user_favor["time"] + favor_once
    end
    -- 用户本日存档次数
    if isnum(user_favor["favo"]) ~= true then --如果存档不是数字
        user_favor["favo"] = favor_once
        --好感度等于1
        if isnum(user_file) then --如果历史存档是数字
            user_favor["favo"] = user_file + favor_once
            total = return_self(pathb) .. "\n琪露诺对你的某个属性上升了!"
        else
            user_favor["favo"] = favor_once
            total = return_self(pathb) .. "\n琪露诺对你的某个属性上升了!"
        end
    else
        if user_favor["time"] <= 3 then --本日存档数小于三次
            user_favor["favo"] = user_favor["favo"] + favor_once
            total = return_self(pathb) .. "\n琪露诺对你的某个属性上升了!"
        else
            return "差不多够了吧{pc},我已经腻了"
        end
    end
    --用户好感度
    local user_text = "date=" .. os.date("%Y-%m-%d") .. ",time=" .. user_favor["time"] .. ",favo=" .. user_favor["favo"]
    write_file(patha, user_text)
    return total
end
--[[计算并返回用户存档数据]]
function return_self(pathb)
    local total = ""
    local cirno_file = read_file(pathb) -- 读取用户文件内容
    local cirno_favor = split_favor(cirno_file) -- 分割成数组
    if cirno_favor["date"] ~= os.date("%Y-%m-%d") then
        cirno_favor["date"] = os.date("%Y-%m-%d")
        cirno_favor["time"] = 0
    end
    -- 用户存档时间
    if isnum(cirno_favor["time"]) ~= true then
        cirno_favor["time"] = favor_once
    else
        cirno_favor["time"] = cirno_favor["time"] + favor_once
    end
    -- 用户本日存档次数
    if isnum(cirno_favor["favo"]) ~= true then --如果存档不是数字
        cirno_favor["favo"] = favor_once
        --好感度等于1
        if isnum(cirno_file) then --如果历史存档是数字
            cirno_favor["favo"] = cirno_file + favor_once
        else
            cirno_favor["favo"] = favor_once
        end
    else
        cirno_favor["favo"] = cirno_favor["favo"] + favor_once
    end
    --用户好感度
    cirno_text = "date=" .. os.date("%Y-%m-%d") .. ",time=" .. cirno_favor["time"] .. ",favo=" .. cirno_favor["favo"]
    write_file(pathb, cirno_text)
    total =
        total ..
        "感谢{pc}送的青蛙ovo\n{self}今天收到了" .. cirno_favor["time"] .. "只青蛙啦\n" .. "累计收到了" .. cirno_favor["favo"] .. "只啦咕嘿嘿"
    return total
end
--[[计算并返回骰娘存档数据]]
basic_path = dice.DiceDir() .. "\\user\\Cirno_plugin\\favor\\" -- 这里设置一下存档的初始地址
--mkDirs(basic_path) -- 初始化存档路径
function check_favor(msg)
    local total = ""
    local user_file, user_favor = "", ""
    local file_name = msg.fromQQ .. ".txt" -- 合成用户存储文件名
    local path = basic_path .. file_name -- 完整的用户文件路径
    user_file = read_file(path) -- 读取文件内容
    user_favor = split_favor(user_file) -- 分割成数组
    if user_favor["favo"] == nil then
        if user_file == nil then
            user_favor["favo"] = "0"
        elseif isnum(user_file) == true then
            user_favor["favo"] = user_file
        else
            user_favor["favo"] = "0"
        end
    end
    total = total .. "你已经送给琪露诺" .. user_favor["favo"] .. "只青蛙啦"
    user_favor["favo"] = user_favor["favo"] + 0
    if user_favor["favo"] < 10 then
        total = total .. "Σ( ° △ °|||)︴"
    elseif user_favor["favo"] < 30 then
        total = total .. "(>▽<)"
    elseif user_favor["favo"] < 50 then
        total = total .. "～(￣▽￣～)~"
    elseif user_favor["favo"] < 90 then
        total = total .. "╰(*°▽°*)╯"
    else
        total = total .. "(σ′▽‵)′▽‵)σ"
    end
    return total
end
--[[琪露诺好感度用]]
function rcv_gift(msg)
    local patha, pathb, total = "", "", ""
    local file_name = msg.fromQQ .. ".txt" -- 合成用户存储文件名
    patha = basic_path .. file_name -- 完整的用户文件路径
    local file_name = msg.selfId .. ".txt" -- 合成骰娘存储文件名
    pathb = basic_path .. file_name -- 完整的骰娘文件路径
    total = return_user(patha, pathb)
    return total
end
-- 喂青蛙用
command["喂青蛙"] = "rcv_gift"
command["琪露诺好感度"] = "check_favor"

--[[喂青蛙实现思路
    0.读取到喂青蛙命令                  --天然完成
    1.读取骰娘自身存档和用户好感度存档    --完成
    2.可能用到的数据:
        1.骰娘本日收到数量
        2.骰娘总收到数量
        3.用户存档时间
        4.用户今日次数
        5.累计好感度
    3.如果对应数据不存在就初始化
    4.老旧存档迁移
    5.比对用户存档时间
        1.如果不是当日日期将今日次数=1
        1.如果当日上限已满就返回不能再喂
    7.如果没满就把对应值+1
        1.骰娘总收到数量
        2.骰娘今日收到数量
        3.用户存档时间重新写入
        4.用户今日次数
        5.用户累计好感度
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
]]
