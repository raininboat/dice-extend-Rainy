--[[
#      _____       _
#     |  __ \     (_)
#     | |__) |__ _ _ _ __  _   _
#     |  _  // _` | | '_ \| | | |
#     | | \ \ (_| | | | | | |_| |
#     |_|  \_\__,_|_|_| |_|\__, |
#                           __/ |
#                          |___/
    堆栈实现版本  by 雨鸣于舟 20210102（部分内容未测试）
]]
-- 堆栈实现部分
Stack = {}

-- 创建新堆栈
-- int为堆栈长度，（nil）则为不限制
function Stack:Create(MaxSize)
    local S = {}
    setmetatable(S,{ __index = self })
    S[0] = 0 -- 栈顶位置，0 为空栈
    S["Type"] = "Stack"
    if type(MaxSize) == "number" then
        assert(MaxSize >= 1 , "失败！Stack:Pop(number)中number位置必须为正整数！" )
        S["MaxSize"] = MaxSize
    end
    return S
end
-- 将栈清空
function Stack:Clear()
    if self["Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    if self.MaxSize then
        self = Stack:Create(self.MaxSize)
    else
        self = Stack:Create()
    end
end
-- 查询是否为空栈，若空则返回True，其余为False
function Stack:isEmpty()
    self = self or {}
    if self["Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    if self[0] == 0 then
        return true
    else
        return false
    end
end

-- 查询是否为栈满，若满则返回True，其余为False
function Stack:isFull()
    if self["Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    if self[0] == self["MaxSize"] then
        return true
    else
        return false
    end
end

-- 将元素弹出栈
function Stack:Get()
    if self["Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end

    local max = self[0]            -- 栈顶指针
    local output
    if max >= 1 then        -- 判断是否为空栈
        output = self[max]
    else                    -- 空栈输出nil
        output = nil
    end
    printtab(output)
    return output
end

-- 将元素压入栈内
-- S 为栈
-- e 为元素
function Stack:Push(e)
    if self["Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    --[[if self[0] == self["MaxSize"] then
        error("失败！堆栈溢出！",2)
        return nil
    end]]

    self[0] = self[0] + 1
    self[self[0]] = e
    print("* pushing element ["..e.."] \n| Stack state:")
    printtab(self)
end

-- 将元素弹出栈
-- S 为栈
-- number 可选 为弹出数量，若不为 1 则从栈顶向栈底逆序弹出
function Stack:Pop(number)
    number = number or 1
    if self["Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    assert(number > 0 , "失败！Stack:Pop(number)中number位置必须为正整数！" )
    local max = self[0]            -- 栈顶指针
    local output = {}
    for i = 1, number, 1 do
        max = self[0]
        if max >= 1 then
            table.insert(output, #output+1 , self[max])
            self[max] = nil
            self[0] = max - 1
        else
            output[i] = nil
        end
    end
    print("* poping element ... MAX = "..self[0].."\n| output:")
    printtab(output)
    print("| remain in stack:")
    printtab(self)
    return unpack(output)
end
-- 获取堆栈元素数量
function Stack:Length()
    if self["Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    local length = self[0]
    return length
end

-- 调整堆栈最大值
-- S 为堆栈
-- MaxSize 可选 为空则为无限
function Stack:changeMax(MaxSize)
    if self["Type"] ~= "Stack" then
        error("失败！输入数据不是栈！请使用Stack.Create创建栈",2)
        return nil
    end
    if type(MaxSize) == "nil" then
        self["MaxSize"] = nil
        return self
    end
    if type(MaxSize) == "number" then
        if MaxSize >= self[0] then
            self["MaxSize"] = MaxSize
            return self
        else
            error("堆栈大小重设置失败，目标大小小于栈内元素数量！",2)
            return nil
        end
    end
end
return Stack