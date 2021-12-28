local helprd  = require "lib.helpredis"
local Aircond  = require "dev.aircond"
local Air     = require "lib.air"
local ds      = require "lib.ds"

-- 针对每个需要设置的操作, 建立一个redis的值
do
    local redis = helprd.get()
    if not redis then
        goto exit
    end

    local fan1 = Aircond.new()
    -- fan1:unserialization()
    ngx.say(fan1:set_data_index(Air.INPUT_ADDR_VER, 0x5a5a, ds.INPUT_REG, false))
    ngx.say(fan1:set_data_index(Air.INPUT_ADDR_SPR1, 1, ds.INPUT_REG, false))
    ngx.say(fan1:set_data_index(Air.INPUT_ADDR_SPE1, 1, ds.INPUT_REG, false))
    ngx.say(fan1:set_data_index(Air.INPUT_ADDR_HW_ID1,  1, ds.INPUT_REG, false))
    ngx.say(fan1:set_data_index(Air.INPUT_ADDR_HW_ID2, 0xfa, ds.INPUT_REG,false))
    ngx.say(fan1:set_data_index(Air.INPUT_ADDR_ST1, 0x1ff, ds.INPUT_REG,false))
    ngx.say(fan1:set_data_index(Air.INPUT_ADDR_HT1, 0xfe, ds.INPUT_REG,true))

    ngx.say(fan1:set_data_index(Air.HOLD_ADDR_TEST, 0x1A1A, ds.HOLD_REG,false))
    ngx.say(fan1:set_data_index(Air.HOLD_ADDR_SPO1, 1, ds.HOLD_REG,true))
    ngx.say(fan1:set_data_index(Air.HOLD_ADDR_SPO2, 1, ds.HOLD_REG,true))

end

::exit::
