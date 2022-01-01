local _M = {}
local util = require 'lib.util'
local lock  = require 'lib.lock'
-- local bit = require 'bit'

local KEEPALIVE_TIMEOUT = 1000 * 60 * 5 --5 mins
local format = string.format
local format_bytes = util.format_bytes
-- local stringtotable = util.stringtotable
local tabletostring = util.tabletostring

local log = ngx.log
local ERR = ngx.ERR
local DBG = ngx.DEBUG
local ins = require 'lib.inspect'

_M.send = function(host, port, data, maxreadsize)
    local sock = ngx.socket.tcp()
    local err, ok, readdata
    local bytes -- luacheck: ignore

    log(DBG, 'sending ok:', host, ':', port, '=', format_bytes(data), ',len=', #data)
    -- return true, nil

    local lockname = format('hp:%s:%s', host, port)
    local mylock = lock.lock(lockname)

    do
        ok, err = sock:connect(host, port)
        if not ok then
            log(ERR, 'connect failed:', err)
            goto sendexit
        end
        ngx.say('connect ok')

        bytes, err = sock:send(tabletostring(data))
        if err then
            log(ERR, 'connect send:', ins(err))
            goto sendexit
        -- else
            -- log(DBG, 'sending ok:', host, ':', port, '=', format_bytes(data), ',len=', bytes)
        end
        ngx.say('send ok')
        -- sock:settimeouts(10000,10000,10000)
        maxreadsize = maxreadsize or 1024
        readdata, err = sock:receiveany(maxreadsize) -- received most 1k data
        if not readdata then
            log(ERR, 'receiveany failed:', err)
            goto sendexit
        end
        -- print(ins(readdata))
        ok, err = sock:setkeepalive(KEEPALIVE_TIMEOUT)
        if not ok then
            log(ERR, 'keep alive failed', err)
        end
    end

    ::sendexit::
    -- sometimes, can not get lock
    if mylock then
        lock.unlock(mylock)
    -- else
        -- log(ERR, 'failed to get lock:', lockname)
    end

    return readdata, err
end

return _M
