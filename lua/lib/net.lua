local _M = {}
local util = require 'lib.util'
local lock  = require 'lib.lock'
-- local bit = require 'bit'

local KEEPALIVE_TIMEOUT = 1000 * 60 * 5 --5 mins
local format = string.format
local format_bytes = util.format_bytes

local log = ngx.log
local ERR = ngx.ERR
local DBG = ngx.DEBUG
local ins = require 'lib.inspect'

-- assume data is only bytes data
local tabletostring = function(data)
    if not data then return '' end
    local td = type(data)
    if td == 'string' then
        return data
    elseif td == 'number' then
        return string.char(data)
    elseif td == 'table' then
        local n = {}
        for _, v in ipairs(data) do
            n[#n + 1] = string.char(v)
        end
        return table.concat(n)
    end
    return ''
end

_M.send = function(host, port, data, maxreadsize)
    local sock = ngx.socket.tcp()
    local err, ok, readdata
    local bytes -- luacheck: ignore

    log(DBG, 'sending ok:', host, ':', port, '=', format_bytes(data), ',len=', #data)
    return true, nil

    -- local lockname = format('hp:%s:%s', host, port)
    -- local mylock = lock.lock(lockname)
    --
    -- do
    --     ok, err = sock:connect(host, port)
    --     if not ok then
    --         log(ERR, 'connect failed:', err)
    --         goto sendexit
    --     end
    --
    --     bytes, err = sock:send(tabletostring(data))
    --     if err then
    --         log(ERR, 'connect send:', ins(err))
    --         goto sendexit
    --     -- else
    --         -- log(DBG, 'sending ok:', host, ':', port, '=', format_bytes(data), ',len=', bytes)
    --     end
    --     -- sock:settimeouts(10000,10000,10000)
    --     maxreadsize = maxreadsize or 1024
    --     readdata, err = sock:receiveany(maxreadsize) -- received most 1k data
    --     if not readdata then
    --         log(ERR, 'receiveany failed:', err)
    --         goto sendexit
    --     end
    --     -- print(ins(readdata))
    --     ok, err = sock:setkeepalive(KEEPALIVE_TIMEOUT)
    --     if not ok then
    --         log(ERR, 'keep alive failed', err)
    --     end
    -- end
    --
    -- ::sendexit::
    -- -- sometimes, can not get lock
    -- if mylock then
    --     lock.unlock(mylock)
    -- else
    --     log(ERR, 'failed to get lock:', lockname)
    -- end
    --
    -- return readdata, err
end

-- local data = {0x0F,0x03,0x0,0x0,0x0,0x16,0xC5,0x2A}
-- local data_str = table.concat(data,'')
-- print(data_str)
-- local data = '0F0300000016C52A'
-- _M.send('192.168.0.7',29, data)

return _M
