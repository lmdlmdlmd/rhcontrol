local process = require "lib.process"
local Ruihe   = require "dev.ruihe"
local helprd  = require "lib.helpredis"
local Ate     = require "dev.ate"
local Newfan  = require "dev.newfan"
local Aircond = require "dev.aircond"

local ret = { code = 1 }
local args = ngx.req.get_uri_args()
local tp = args.tp
local val  = args.v

if not tp or not val then
    ret.code = 100
    ret.msg = 'tp or v is empty'
    goto exit
end

-- 针对每个需要设置的操作, 建立一个redis的值
do
    local redis = helprd.get()
    if not redis then
        ret.msg = 'redis is down'
        goto exit
    end

    local allow_set = {
        led = 1,
        mode = 1,
        fax = 1,
        fak = 1,
        spo1 = 1,
    }
    if not allow_set[tp] then
        ret.msg = 'not support tp'
        goto exit
    end

    if tp == 'led' then
        local ate1 = Ate.new(0xf)
        ate1:set(redis, tp, val)
    elseif tp == 'fax' or tp == 'fak' then
        local fan1 = Newfan.new(0x1)
        fan1:set(redis, tp, val)
    elseif tp == 'spo1' then
        local air1 = Aircond.new(0x1)
        air1:set(redis, tp, val)
    else
        local key = Ruihe.get_set_redis_key(tp)
        redis:set(key, val)
    end
    ret.code = 0
end

::exit::

process.after(ret)
