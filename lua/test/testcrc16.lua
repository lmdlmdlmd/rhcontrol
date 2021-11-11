-- local crc = require 'lib.crc16'
--
-- local a1 = crc({0x1,0x2,0x3,0x4})
-- ngx.say(string.format("pi = %x,%x", a1[1],a1[2]))
--
-- local a2 = crc({0x0F,0x06, 0x00, 0x12, 0x00, 0x00})
-- ngx.say(string.format("pi = %x,%x", a2[1],a2[2]))

local ins = require 'lib.inspect'
local function f(...)
    local a,b,c = ...
    print(ins(a))
    print(b)
    print(c)
end


f(1,2,34)
