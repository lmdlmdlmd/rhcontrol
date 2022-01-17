local process = require "lib.process"
local Ruihe   = require "dev.ruihe"
local Newfan  = require "dev.newfan"
local Fan     = require "lib.fan"
local Air     = require "lib.air"
local Aircond = require "dev.aircond"

local ret = { code = 1 }
local args = ngx.req.get_uri_args()
local dev = args.dev
local name = args.name
local val  = args.val

if not dev or not name or not val then
    ret.code = 100
    ret.msg = 'dev or tp or v is empty'
    goto exit
end

do

    name = string.upper(name)

    if dev == 'fan' then
        local fan1 = Newfan.new(0x1)
        local tp, index = Fan.tp_index(name)
        if tp and index then
            fan1:unserialization()
            fan1:set_data_index(index, val, tp, true)
            ret.msg = 'set fan:' .. name ..':' .. val
        else
            ret.msg = 'name no foud in list'
            goto exit
        end
    elseif dev == 'air' then
        local air1 = Aircond.new(0x1)
        local tp, index = Air.tp_index(name)
        if tp and index then
            air1:unserialization()
            air1:set_data_index(index, val, tp, true)
            ret.msg = 'set air:' .. name ..':' .. val
            ret.msg = ret.msg .. ',tp:' .. tp .. ',index:' ..index
        else
            ret.msg = 'name no found in list'
            goto exit
        end
    else
        Ruihe.unserialization()
        if not Ruihe.set(name, val, true) then
            ret.msg = 'name no found in list'
            goto exit
        end
        ret.msg = 'set ruihe:' .. name ..':' .. val
    end
    ret.code = 0
end

::exit::

process.after(ret)
