local helprd  = require "lib.helpredis"
local Ate     = require "dev.ate"

-- 针对每个需要设置的操作, 建立一个redis的值
do
    local redis = helprd.get()
    if not redis then
        goto exit
    end

    local ate1 = Ate.new(0xf)
    -- ate1:unserialization()
    ngx.say(ate1:set_data_index(3, 0, false))
    ngx.say(ate1:set_data_index(6, 0, false))
    ngx.say(ate1:set_data_index(7, 0, false))
    ngx.say(ate1:set_data_index(10, 250, false))
    ngx.say(ate1:set_data_index(13, 156, false))
    ngx.say(ate1:set_data_index(14, 678, true))

end

::exit::
