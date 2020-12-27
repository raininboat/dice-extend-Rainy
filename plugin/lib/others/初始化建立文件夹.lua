function mkDirs(path)
    os.execute('mkdir "' .. path .. '"')
end

basic_path = dice.DiceDir() .. "\\user\\Rainy_plugin\\groups\\" -- 这里设置一下存档的初始地址
mkDirs(basic_path) -- 初始化存档路径