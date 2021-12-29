local helprd  = require "lib.helpredis"
local Newfan  = require "dev.newfan"
local Fan     = require "lib.fan"
local ds      = require "lib.ds"

-- 针对每个需要设置的操作, 建立一个redis的值
do
    local redis = helprd.get()
    if not redis then
        goto exit
    end

    local fan1 = Newfan.new()
    fan1:unserialization()
    ngx.say(fan1:set_data_index(Fan.INPUT_ADDR_VER, 0x5a5a, ds.INPUT_REG, false))

    ngx.say(fan1:set_data_index(Fan.INPUT_ADDR_XLW1, 0, ds.INPUT_REG, false))
    ngx.say(fan1:set_data_index(Fan.INPUT_ADDR_XLW2, 0, ds.INPUT_REG, false))

    -- ngx.say(fan1:set_data_index(Fan.INPUT_ADDR_FAR,  1, ds.INPUT_REG, false))
    -- ngx.say(fan1:set_data_index(Fan.INPUT_ADDR_FAE,  1, ds.INPUT_REG, false))
    --
    -- ngx.say(fan1:set_data_index(Fan.INPUT_ADDR_RAT1, 0xfa, ds.INPUT_REG,false))
    -- ngx.say(fan1:set_data_index(Fan.INPUT_ADDR_RAH1, 0x1ff, ds.INPUT_REG,false))
    --
    -- ngx.say(fan1:set_data_index(Fan.INPUT_ADDR_SAT1, 25, ds.INPUT_REG,false))
    -- ngx.say(fan1:set_data_index(Fan.INPUT_ADDR_SAH1, 60, ds.INPUT_REG,false))
    --
    -- ngx.say(fan1:set_data_index(Fan.INPUT_ADDR_FAH1, 0xfe, ds.INPUT_REG,true))
    fan1:serialization()
    --
    -- ngx.say(fan1:set_data_index(Fan.HOLD_ADDR_TEST, 0x1A1A, ds.HOLD_REG,false))
    -- ngx.say(fan1:set_data_index(Fan.HOLD_ADDR_JSK, 1, ds.HOLD_REG,true))
    -- ngx.say(fan1:set_data_index(Fan.HOLD_ADDR_FAK, 1, ds.HOLD_REG,true))

end

::exit::
