command = {}
fire = {}
function jump_return(type, msgs, save,go_to)
    if go_to[msgs] ~= nil then
        return (fire[msgs](type, msgs, save))
    else
        return "你目前还不能这么做"
    end
end
function choose_return(save, go_to)
    local rv = {}
    if save["hasbeen"] == nil then
        save["hasbeen"] = {}
    end
    for key, value in pairs(go_to) do
        if save.hasbeen[key] == nil then
            save.hasbeen[key] = 0
        end
        if go_to[key][2] == nil then
            go_to[key][2] = 1
        end
        if save.hasbeen[key] < go_to[key][2] then
            table.insert(rv, "\n")
            table.insert(rv, string.sub (key,2))
            table.insert(rv, " ：")
            table.insert(rv, go_to[key][1])
        end
    end
    return table.concat(rv)
end
--[[
列出可选项目需要:
1. 选项可用
2. 选项在次数范围内
]]
function fire.a0(type, msgs, save)
    local stroy = "一切的起始\f\f\f\f\f\f\f\f\f在很久很久以前~\n西方来了一群强盗\n将村里的月台毁了,结界也因此衰败破落\n现在,村里诞生了一名勇者\n是时候开始反击了!"
    local go_to = {["a1"] = {"前往勇者小屋awa"}, ["a2"] = {"前往演武场awa"}, ["a3"] = {"前往村长家awa"}}
    local choose = choose_return(save, go_to)
    if type == "stroy" then
        return stroy .. choose
    elseif type == "skill" then
        return "待开发"
    elseif type == "jump" then
        return jump_return("stroy", msgs, save,go_to)
    else
        return "未知问题"
    end
end
function fire.a1(type, msgs, save)
    local stroy = "小屋里什么都没有"
    local go_to = {["a2"] = {"前往演武场"}, ["a3"] = {"前往村长家"}}
    local choose = choose_return(save, go_to)
    if type == "stroy" then
        return stroy .. choose
    elseif type == "skill" then
        return "待开发"
    elseif type == "jump" then
        return jump_return("stroy", msgs, save,go_to)
    else
        return "未知问题"
    end
end
function fire.a2(type, msgs, save)
    local stroy = "你来到了演武场\n演武场早已破败不堪\n你所知道的就是在演武场的深处有一把被封印的魔剑"
    local go_to = {["a4"] = {"深入"}}
    local choose = choose_return(save, go_to)
    if type == "stroy" then
        return stroy .. choose
    elseif type == "skill" then
        return "待开发"
    elseif type == "jump" then
        return jump_return("stroy", msgs, save,go_to)
    else
        return "未知问题"
    end
end
function fire.a3(type, msgs, save)
    local stroy = "村长家离这里太远了,你还不足以支撑这么长途的跋涉"
    local go_to = {["a2"] = {"前往演武场"}}
    local choose = choose_return(save, go_to)
    if type == "stroy" then
        return stroy .. choose
    elseif type == "skill" then
        return "待开发"
    elseif type == "jump" then
        return jump_return("stroy", msgs, save,go_to)
    else
        return "未知问题"
    end
end
function fire.a4(type, msgs, save)
    local stroy = "这只是一个实验品,所以到此为止了"
    if type == "stroy" then
        return stroy
    elseif type == "skill" then
        return stroy
    elseif type == "jump" then
        return stroy
    else
        return stroy
    end
end
function main_fire(msg)
    local save = {
        ["save"] = "a0",
        ["hasbeen"] = {
            ["a0"] = 1,
        }
    } -- 模拟读取存档
    local input = msg.msg[1] -- 模拟消息输入
    input = "a" .. input
    if save == nil or save.save == nil or save.save == "" then
        save = {["save"] = "a0"} -- 初始化存档
    end
    if save.save == input then
        print(fire[save.save]("stroy", input, save))
    else
        print(fire[save.save]("jump", input, save))
    end
end
local t_msg = {["msg"] = {2}}
main_fire(t_msg) -- 模拟消息输入

command[".test\\s?(\\d)"] = "main_fire"