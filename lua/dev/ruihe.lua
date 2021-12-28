local helprd = require "lib.helpredis"
local cjson  = require "cjson.safe"

local log = ngx.log
-- local ERR = ngx.ERR
local DBG = ngx.DEBUG

-- 瑞和的一个虚拟设备，用来表示整个的对外的设备情况
local _M = {
    data = {
        MODE = 0, -- 模式
        RAHS1 = 0, --设定除湿湿度
        RAHS2 = 0, -- 冬季加湿设定湿度(室内回风湿度的临界值)
        DHST1 = 0, -- 盘管保护设定温度
        H9 = 0, -- 高风险湿度偏差值
        H8 = 0, -- 低风险湿度偏差值
        FAX = 1, -- 送风档位
        EAX = 1, -- 排风档位
        -- LD1 = 0, -- 回风露点值,RAT1和RAH1计算出来LD1, caculated value, not software setting
        LDS1 = 0, -- 回风设定露点值（调试模式下设置）
        -- LD2 = 0, -- 送风露点,送风温度和湿度计算出来的数值,caculated value, not software setting
        LDS2 = 0, -- 送风露点保护设定值
        WTS1 = 0, -- 夏季舒适温度
        WTS2 = 0, -- 冬季舒适温度
        WTS3 = 0, -- 冬季低温设定温度,
        STS1 = 0, -- 夏季毛细管设定温度
        STS2 = 0, -- 冬季毛细管供水设定温度
    }
}
-- local format = string.format

local get_key = function()
    return 'ruihe:set'
end

_M.set = function(tp, val)
    local data = _M.data
    val = tonumber(val)
    if val ~= data[tp] then
        data[tp] = val
        _M.serialization()
    end
end

_M.get = function(tp)
    if not tp then return nil end
    local data = _M.data
    return data[tp]
end

_M.set_alarm = function( i ) -- luacheck: ignore
    log(DBG, 'raise alarm:', i)
end

_M.clear_alarm = function( i) -- luacheck: ignore
    log(DBG, 'clear alarm:', i)
end

_M.serialization = function()
    local d = _M.data
    local key = get_key()
    local d_str = cjson.encode(d)
    -- log(ERR, d_str)
    local redis = helprd.get()
    redis:set(key, d_str)
    return  true
end

_M.unserialization = function()
    local key = get_key()
    -- local d_str = cjson.encode(d)
    local redis = helprd.get()
    local d_str = redis:get(key)
    -- log(ERR, d_str)
    if d_str then
        local d = cjson.decode(d_str)
        if d then
            _M.data = d
            return  true
        end
    end
    return  false
end

return _M
