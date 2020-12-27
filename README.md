# Rainy Plugin for DICE

** 该仓库为雨鸣于舟为青果DICE编写的部分lua脚本插件 **

其中 "***kp带团.lua***" 为一个独立的lua插件，扩展了xra, xst等功能，可用于代替他人检定/查看/修改技能
不过由于该脚本创作时间较早，目前没有维护重构的准备，所以一方面存档不通用，另一方面其中的检定等内容偏村规

其中 “***Rainy.lua***” 为lua库，其中引用 dkjson.lua 的第三方开源库用于解析保存存档，所以使用时**需把该文件和 dkjson.lua 一同放入plugin/lib文件夹**

其余为各种小型脚本插件，用于单独的功能
