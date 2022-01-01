local sm4_class = require "lib.sm4"

local key = 'zhgl'
local text = 'test'
local sm4 = sm4_class:new(key)

local en_text = sm4:encrypt(text)
print(en_text)

local de_text = sm4:decrypt(en_text)
print(de_text)
