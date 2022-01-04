local bridge = require 'dev.bridge'
local util = require 'lib.util'
local net  = require 'lib.net'

local log = ngx.log
local ERR = ngx.ERR
local DBG = ngx.DEBUG
local ins = require 'lib.inspect'

local format_bytes = util.format_bytes
local stringtotable = util.stringtotable
local tabletostring = util.tabletostring

local dtq = {}
local devidprex = '410108S101QLS00'
for index = 2, 2, 1 do
    local devid
    if index < 10 then
        devid = devidprex .. '00' .. index
    elseif index < 100 then
        devid = devidprex .. '0' .. index
    elseif index < 1000 then
        devid = devidprex .. index
    end
    ngx.say(devid)
    local header = bridge.make_header(0x1, devid)
    local body = bridge.make_body_register(devid)

    local msg = bridge.pack(header, body)
    ngx.say('len header=', #header)
    ngx.say('body header=', #body)
    ngx.say(format_bytes(msg))


    local readdata, err = net.send('222.143.32.246',8001, msg)
    ngx.say(readdata)
    local a = stringtotable(readdata)
    ngx.say(ins(format_bytes(a)))

    local b = {}
    if a and a[2] == 0x01 then
        for i,v in ipairs(a) do
            if i > 2 and i < (32 + 3) then
                b[#b + 1] = v
            end
        end
    end

    if err then
        ngx.say(ins(err))
    end

    dtq[devid] = tabletostring(b)
end

ngx.say(ins(dtq))
-- local readdata, err = net.send('222.143.32.246',8001, msg)
-- ngx.say(readdata)
-- ngx.say(ins(format_bytes(stringtotable(readdata))))
-- ngx.say(ins(err))
