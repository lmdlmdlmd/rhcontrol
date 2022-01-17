local util = require 'lib.util'
local ds   = require 'lib.ds'
-- 0x01,0x04,
-- 0x24, = 36 /2 = 18
-- 0x00,0x00,
-- 0x00,0x01,
-- 0x00,0x01,
-- 0x00,0x01,
-- 0x00,0x01,
-- 0x00,0x01,
-- 0x00,0x01,
-- 0x00,0x01,
-- 0x05,0x70,
-- 0x0C,0x64,
-- 0x00,0x00,
-- 0x00,0x00,
-- 0x00,0x00,
-- 0x00,0x00,
-- 0x05,0x9C,
-- 0x5A,0x5A, 0X0F --health
-- 0x39,0xE0,
-- 0x04,0x00,
-- 0x39,0x13
local _M = {
    -- input registers
    INPUT_ADDR_VER = 0,
    INPUT_ADDR_XLW1 = 1, -- 初效压差开关
    INPUT_ADDR_XLW2 = 2, -- 高效压差开关
    INPUT_ADDR_FPR = 3, -- 室内风盘联动点
    INPUT_ADDR_FAR = 4, -- 送风风机  运行状态
    INPUT_ADDR_FAE = 5,  -- 送风风机  故障状态
    INPUT_ADDR_EAR = 6,  -- 排风风机  运行状态
    INPUT_ADDR_EAE = 7,  -- 排风风机  故障状态
    INPUT_ADDR_RAT1 = 8, -- 室内回风温度
    INPUT_ADDR_RAH1 = 9, -- 室内回风湿度
    INPUT_ADDR_FAT1 = 10,  -- 新风温度（室外），**可能没有**
    INPUT_ADDR_FAH1 = 11,  -- 新风湿度
    INPUT_ADDR_SAT1 = 12,  -- 送风温度，**可能没有**
    INPUT_ADDR_SAH1 = 13,  -- 送风湿度，**可能没有**
    INPUT_ADDR_DHT1 = 14,  -- 新风机盘管温度/表冷器温度
    INPUT_ADDR_HWID = 15,  -- dwk 是否存在标志
    INPUT_ADDR_HEALTH  = 16,
    INPUT_ADDR_HEARTBEAT = 17,

    input_names = {
        "VER", "XLW1", "XLW2", "FPR", "FAR", "FAE", "EAR", "EAE", "RAT1", "RAH1", "FAT1",
        "FAH1", "SAT1", "SAH1","DHT1","HWID", "HEALTH", "HEARTBEAT"
    },

    -- hold registers
    HOLD_ADDR_TEST = 0,
    HOLD_ADDR_DWK = 1, --新风直膨主机, **可能没有**
    HOLD_ADDR_JSK = 2, --加湿水阀
    HOLD_ADDR_DHV = 3, --冷水阀
    HOLD_ADDR_FAV = 4, --新风风阀
    HOLD_ADDR_FAK = 5, -- 送风风机  启停
    HOLD_ADDR_FAO = 6, -- 送风风机  手动/自动， 意义不明确
    HOLD_ADDR_EAK = 7, -- 排风风机  启停
    HOLD_ADDR_EAO = 8, -- 排风风机  手动/自动，意义不明确

    HOLD_ADDR_FAX = 9, -- 送风风机  频率调节
    HOLD_ADDR_EAX = 10, -- 排风风机  频率调节

    -- not used
    -- HOLD_ADDR_MODE = 11,
    -- HOLD_ADDR_RAHS1 = 12,
    -- HOLD_ADDR_RAHS2 = 13,
    -- HOLD_ADDR_DHST1 = 14,
    -- HOLD_ADDR_H9 = 15,
    -- HOLD_ADDR_H8 = 16,
    -- HOLD_ADDR_LD1 = 17,
    -- HOLD_ADDR_LDS1 = 18,
    -- HOLD_ADDR_LD2 = 19,
    -- HOLD_ADDR_LDS2 = 20,
    -- HOLD_ADDR_WTS1 = 21,
    -- HOLD_ADDR_WTS2 = 22,
    -- HOLD_ADDR_WTS3 = 23,
    HOLD_ADDR_SYNC = 11,

    hold_names = {
        'TEST','DWK','JSK','DHV','FAV','FAK','FAO','EAK','EAO','FAX','EAX','SYNC'
    }
}

_M.get_input_name = function(index)
    index = index + 1
    return _M['input_names'][index] or 'nil'
end
_M.get_input_index = function(val)
    return util.index(_M['input_names'], val)
end

_M.get_hold_name = function(index)
    index = index + 1
    return _M['hold_names'][index] or 'nil'
end
_M.get_hold_index = function(val)
    return util.index(_M['hold_names'], val)
end

_M.tp_index = function(name)
    local index = _M.get_input_index(name)
    if index then
        return ds.INPUT_REG, index
    end

    index = _M.get_hold_index(name)
    if index then
        return ds.HOLD_REG, index
    end
end

return _M
