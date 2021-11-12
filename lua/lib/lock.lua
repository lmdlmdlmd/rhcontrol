local _M = {}
local resty_lock = require "resty.lock"
local log  = ngx.log
local DBG  = ngx.DEBUG

local LOCKBUFFER = 'lmdlock'
_M.lock = function( resource, exptime, timeout)
    exptime = exptime or 120
    timeout = timeout or 60
    local lock_obj, err = resty_lock:new(LOCKBUFFER, {exptime = exptime, timeout = timeout})
    if not lock_obj then
        log(DBG, "failed to create lock: ", err, ",", resource)
    end

    if lock_obj then
        local elapsed, err1 = lock_obj:lock(resource)
        if err1 then
            log(DBG, elapsed, ", ", err1)
        end
    end

    return lock_obj
end

_M.unlock = function( lock_obj )
    if lock_obj then
        local ok, err = lock_obj:unlock()
        if not ok then
            log(DBG, "failed to unlock: ", err)
        end
    end
end

return _M
