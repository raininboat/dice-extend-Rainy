--[[
#      _____       _
#     |  __ \     (_)
#     | |__) |__ _ _ _ __  _   _
#     |  _  // _` | | '_ \| | | |
#     | | \ \ (_| | | | | | |_| |
#     |_|  \_\__,_|_|_| |_|\__, |
#                           __/ |
#                          |___/
    堆栈的实现  by 雨鸣于舟 20210101（单独库文件）
]]

Stack = {}

-- 创建新堆栈
-- int为堆栈长度，（nil）则为不限制
function Stack.Create(MaxSize)
    local S = {}
    S[0] = 0 -- 栈顶位置，0 为空栈
    S["__Type"] = "Stack"
    if type(MaxSize) == "number" then
        if MaxSize >= 1 then
            S["MaxSize"] = MaxSize
        else
            error("堆栈设置MaxSize最小为1！",2)
            return nil
        end
    end
    return S
end
-- 将栈清空
function Stack.Clear(S)
    if S["__Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    if S.MaxSize then
        S = Stack.Create(S.MaxSize)
        return S
    else
        S = Stack.Create()
        return S
    end
end
-- 查询是否为空栈，若空则返回True，其余为False
function Stack.isEmpty(S)
    S = S or {}
    if S["__Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    if S[0] == 0 then
        return true
    else
        return false
    end
end

-- 查询是否为栈满，若满则返回True，其余为False
function Stack.isFull(S)
    S = S or {}
    if S["__Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    if S[0] == S["MaxSize"] then
        return true
    else
        return false
    end
end

-- 将元素压入栈内
-- S 为栈
-- e 为元素
function Stack.Push(S,e)
    if S["__Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    if S[0] == S["MaxSize"] then
        error("失败！堆栈溢出！",2)
        return nil
    end
    S[0] = S[0] + 1
    S[S[0]] = e
    return true
end

-- 将元素弹出栈
-- S 为栈
-- number 可选 为弹出数量，若不为 1 则从栈顶向栈底逆序弹出一个table
function Stack.Pop(S,number)
    number = number or 1
    if S["__Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    if type(number) ~= "number"  then
        error("失败！Stack.Pop(S,number)中number位置必须为正整数！",2)
        return nil
    elseif  number <= 0 then
        error("失败！Stack.Pop(S,number)中number位置必须为正整数！",2)
        return nil
    end
    local max = S[0]            -- 栈顶指针
    if number == 1 then         -- 只弹出一个
        local output
        if max >= 1 then        -- 判断是否为空栈
            output = S[max]
            S[max] = nil
            S[0] = max - 1
        else                    -- 空栈输出nil
            output = nil
        end
        return output
    elseif number > 1 then
        local output = {}
        for i = 1, number, 1 do
            max = S[0]
            if max >= 1 then
                output[i] = S[max]
                S[max] = nil
                S[0] = max - 1
            else
                output[i] = nil
            end
        end
        return output
    else
        error("失败！Stack.Pop发生未知错误！",2)
        return nil
    end
end
-- 获取堆栈元素数量
function Stack.Length(S)
    if S["__Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    local length = S[0]
    return length
end

-- 调整堆栈最大值
-- S 为堆栈
-- MaxSize 可选 为空则为无限
function Stack.changeMax(S,MaxSize)
    if S["__Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    if type(MaxSize) == "nil" then
        S["MaxSize"] = nil
        return S
    end
    if type(MaxSize) == "number" then
        if MaxSize >= S[0] then
            S["MaxSize"] = MaxSize
            return S
        else
            error("堆栈大小重设置失败，目标大小小于栈内元素数量！",2)
            return nil
        end
    end
end


return Stack