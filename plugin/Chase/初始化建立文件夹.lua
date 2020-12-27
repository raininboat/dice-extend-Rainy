function mkDirs(path)
    os.execute('mkdir "' .. path .. '"')
end

basic_path = dice.DiceDir()
mkDirs(basic_path.."\\RainyData\\group") -- 初始化存档路径
mkDirs(basic_path.."\\RainyData\\QQ") -- 初始化存档路径
mkDirs(basic_path.."\\RainyData\\story") -- 初始化存档路径
mkDirs(basic_path.."\\RainyData\\storydata") -- 初始化存档路径