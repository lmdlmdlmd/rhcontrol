-- 瑞和的一个虚拟设备，用来表示整个的对外的设备情况
local _M = {
    data = {
        mode = 0, -- 模式
    }
}
local format = string.format

_M.get_set_redis_key = function( tp )
    return format('ruihe:set:%s', tp)
end

_M.set = function(tp, val)
    local data = _M.data
    val = tonumber(val)
    if val ~= data[tp] then
        data[tp] = val
    end
end

return _M
