command = {}
local tbl = {
    [1] = {
        [1] = {[1] = "111\\t", [2] = "112\\", [3] = "113\\n\""},
        [2] = {[1] = "121\\t", [2] = "122\\", [3] = "123\\n\""},
        [3] = {[1] = "131\\t", [2] = "132\\", [3] = "133\\n\""},
        [4] = {[1] = "141\\t", [2] = "142\\", [3] = "143\\n\""}
    },
    [2] = {
        [1] = {[1] = "211\\t", [2] = "212\\", [3] = "213\\n\""},
        [2] = {[1] = "221\\t", [2] = "222\\", [3] = "223\\n\""},
        [3] = {[1] = "231\\t", [2] = "232\\", [3] = "233\\n\""},
        [4] = {[1] = "241\\t", [2] = "242\\", [3] = "243\\n\""}
    },
    [3] = {
        [1] = {[1] = "311\\t", [2] = "312\\", [3] = "313\\n\""},
        [2] = {[1] = "321\\t", [2] = "322\\", [3] = "323\\n\""},
        [3] = {[1] = "331\\t", [2] = "332\\", [3] = "333\\n\""},
        [4] = {[1] = "341\\t", [2] = "342\\", [3] = "343\\n\""}
    },
    [4] = {
        [1] = {[1] = "411\\t", [2] = "412\\", [3] = "413\\n\""},
        [2] = {[1] = "421\\t", [2] = "422\\", [3] = '423\\n\"'},
        [3] = {[1] = "431\\t", [2] = "432\\", [3] = "433\\n\""},
        [4] = {[1] = "441\\t", [2] = "442\\", [3] = "443\\n\""}
    }
}
function eelosilypj(msg)
    function print_table(text, level)
        local total, indent, counttb = "", "", ""
        counttb = CountTB(text)
        level = level or 0
        for i = 1, level do
            indent = indent .. "    "
        end
        for key, value in pairs(text) do
            if type(value) == "table" then
                level = level + 1
                counttb = counttb - 1
                total = total .. indent .. '"' .. key .. '" : ' .. "{\n" .. print_table(value, level) .. indent
                if counttb >= 1 then
                    total = total .. "},\n"
                else
                    total = total .. "}\n"
                end
                level = level - 1
            else
                counttb = counttb - 1
                value = string.gsub(value, "\n", "\\n")
                total = total .. indent .. '"' .. key .. '" : ' .. value
                if counttb >= 1 then
                    total = total .. '",\n'
                else
                    total = total .. '"\n'
                end
            end
        end
        return total
    end
    function CountTB(tbData)
        local count = 0
        if tbData then
            for i, val in pairs(tbData) do
                count = count + 1
            end
        end
        return count
    end
    return print_table(msg, level)
end
command["print.+"] = "eelosilypj"
print (eelosilypj(tbl))