local _M = {}
local format = string.format

_M.get_redis_key = function(name, addr, index)
    return format('cmd:%s:%d:%s', name, addr, index)
end

return _M
