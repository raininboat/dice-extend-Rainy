
--[[
    rd 的实现
    （计算器）
    主要为练习栈和逆波兰表达式的使用
]]
function printtab(tab)
    if type(tab) == "table" then
        
        for key, value in pairs(tab) do
            print("| => ",key,value)
        end
    elseif type(tab) == "function" then
    print("function")
    elseif type(tab) == "nil" then
        print("NIL")
    else
        print(tab)
    end
end

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

-- ################################################################
-- 逆波兰表达式部分

function RPNchange(Input)
    -- 符号优先级
    local calsign = {
        ["$"] = 0 , ["("] = 0 ,
        ["+"] = 1 , ["-"] = 1 ,
        ["*"] = 2 , ["/"] = 2 ,
        ["d"] = 3 , ["D"] = 3 ,
    }
    -- 数字
    local calnum = {
        ["1"] = 1 , ["2"] = 2 ,
        ["3"] = 3 , ["4"] = 4 ,
        ["5"] = 5 , ["6"] = 6 ,
        ["7"] = 7 , ["8"] = 8 ,
        ["9"] = 9 , ["0"] = 0
    }
    local Calculate = {}
    local Sign = Stack:Create()
    Sign:Push("$")
    local tmp 
    local number = nil
    local strleng = string.len(Input)
    for i = 1, strleng, 1 do
        tmp = string.sub(Input,i,i)
        print("["..i.."]tmp is ".. tmp)
        if calnum[tmp] then
            number = number or 0
            number = number * 10 +calnum[tmp]
            print("["..i.."] number = "..number)
        elseif tmp == "(" then
            if type(number) == "number" then
                table.insert(Calculate,#Calculate+1,number)
                print("["..i.."] number inserted is : "..number.."\ncalculate is :")
                printtab(Calculate)
                number = nil
            end
            print("["..i.."] pushing ' ( ' into sign")
            Sign:Push("(")
        elseif tmp == " " then
            -- skip
        elseif calsign[tmp] then
            if type(number) == "number" then
                table.insert(Calculate,#Calculate+1,number)
                print("["..i.."] number inserted is : "..number.."\ncalculate is :")
                printtab(Calculate)
                number = nil
            end
            local lastSign = Sign:Get()
            if lastSign ~= "(" then
                -- 当前运算符和栈顶运算符比较优先级
                while calsign[tmp] <= calsign[lastSign] do
                    table.insert(Calculate,#Calculate+1,Sign:Pop())
                    lastSign = Sign:Get()
				    if lastSign == "$" then
					    break
				    end
                end
            end
            Sign:Push(tmp)
        elseif tmp == ")" then
            if type(number) == "number" then
                table.insert(Calculate,#Calculate+1,number)
                print("["..i.."] number inserted is : "..number.."\ncalculate is :")
                printtab(Calculate)
                number = nil
            end
            local lastSign = Sign:Get()
            while lastSign ~= "(" do
                if lastSign == "$" then
                    error("括号不匹配！",2)
                    return nil
                end
                table.insert(Calculate,#Calculate+1,Sign:Pop())
                lastSign = Sign:Get()
            end
            Sign:Pop()
        else
            if type(number) == "number" then
                table.insert(Calculate,#Calculate+1,number)
                print("["..i.."] number inserted is : "..number.."\ncalculate is :")
                printtab(Calculate)
                number = nil
            end

            while Sign:Get() ~= "$" do
                if Sign:Get() == "(" then
                    error("四则运算表达式错误！",2)
                    return nil
                end
                table.insert(Calculate,#Calculate+1,Sign:Pop())
            end
            break
        end
    end
    if type(number) == "number" then
        table.insert(Calculate,#Calculate+1,number)
        print("[END] number inserted is : "..number.."\ncalculate is :")
        printtab(Calculate)
        number = nil
    end
    while Sign:Get() ~= "$" do
        if Sign:Get() == "(" then
            error("四则运算表达式错误！",2)
            return nil
        end
        table.insert(Calculate,#Calculate+1,Sign:Pop())
    end
    return Calculate
end

function RPNcal(cal)
    local function Rand(x,y)
        x = x or 1
        y = y or 1
        local result = 0
        for i = 1, x, 1 do
            result = result + math.random(y)
        end
        return result
    end
    local a = Stack:Create()
    local x = 0
    local y = 0
    local tmp
    local res = 0
    local calsign = {
        ["+"] = 1 , ["-"] = 1 ,
        ["*"] = 2 , ["/"] = 2 ,
        ["d"] = 3 , ["D"] = 3 ,
    }
    for i = 1,#cal,1 do
        tmp = cal[i]
        print( "["..i.."] TMP IS \" "..tmp..' "')
        if type(tmp) == "number" then
            print("# ["..i.."] PUSHING NUM ["..tmp.."] INTO A")
            a:Push(tmp)
            tmp = nil
        elseif calsign[tmp] then
            y , x = a:Pop(2)
            print("# ["..i.."] COUNTING  ["..x.."] ["..tmp.."] ["..y.."] ")
            -- x = a:Pop()
            if x == nil then 
                error("后缀表达式计算发生错误！",2)
                return y
            end
            -- 计算
            if tmp == "+" then
                res = x + y
                a:Push(res)
            elseif tmp == "-" then
                res = x - y
                a:Push(res)
            elseif tmp == "*" then
                res = x * y
                a:Push(res)
            elseif tmp == "/" then
                res = x / y
                a:Push(res)
            elseif tmp == "D" or tmp == "d" then
                res = Rand(x,y)
                a:Push(res)
            end
            tmp = nil
        else
            break
        end
    end
--[[
    if type(tmp) == "number" then
        a:Push(tmp)
        tmp = nil
     elseif type(tmp) == "string" then
         y,x = a:Pop(2)
         if x == nil then 
             error("后缀表达式计算发生错误！",2)
             return y
         end
         -- 计算
         if tmp == "+" then
             res = x + y
             a:Push(res)
         elseif tmp == "-" then
             res = x - y
             a:Push(res)
         elseif tmp == "*" then
             res = x * y
             a:Push(res)
         elseif tmp == "/" then
             res = x / y
             a:Push(res)
         elseif tmp == "D" or tmp == "d" then
             res = Rand(x,y)
             a:Push(res)
         end
         tmp = nil
     end
     ]]
    return a:Pop()
end

function RPN(text)
    local cal = RPNchange(text)
    print("RPN is :")
    printtab(cal)
    local result = RPNcal(cal)
    return result
end



text = "11*5+(8+6)/2-7*4"

print("ANS = "..RPN(text))