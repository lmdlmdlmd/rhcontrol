local util = require 'lib.util'
local ds   = require 'lib.ds'
-- 0x01,0x04,0x28,
-- 0x00,0x00,
-- 0x00,0x01, SPR1
-- 0x00,0x01, SPE1
-- 0x00,0x01, SPR2
-- 0x00,0x01, SPE2
-- 0x00,0x00, HPE
-- 0x00,0x00, HWID1
-- 0x00,0x00, HIWID
-- 0xA1,0x76, ST1
-- 0x82,0x43, HT1
-- 0x5A,0x5A, HEALTH
-- 0x00,0x00,0x00,0x00,0x00,0x00,0xEA,0x04

local _M = {
  INPUT_ADDR_VER = 0,
  INPUT_ADDR_SPR1 = 1, --二次水泵1  运行状态 默认为, 未启动:1; 已启动，读出:0
  INPUT_ADDR_SPE1 = 2, --二次水泵1  故障状态 默认为，正常:1; 0 代表故障
  INPUT_ADDR_SPR2 = 3, --二次水泵2  运行状态
  INPUT_ADDR_SPE2 = 4, --二次水泵2  故障状态
  INPUT_ADDR_HPE  = 5, --热水循环  水泵故障状态
  -- HW_ID2=0，HWID1=0，“不共用主机”
  -- HW_ID2=0，HWID1=1，“共用MC1”
  -- HW_ID2=1，HWID1=0，“共用MC2”
  -- HW_ID2=1，HWID1=1，“错误码”
  INPUT_ADDR_HW_ID1 = 6,
  INPUT_ADDR_HW_ID2 = 7,
  INPUT_ADDR_ST1 = 8, -- 二次水温
  INPUT_ADDR_HT1 = 9, -- 热水循环  温度
  INPUT_ADDR_HEALTH = 10,
  INPUT_ADDR_HEARTBEAT = 11,
  input_names = {
      "VER",
      "SPR1", "SPE1", "SPR2", "HPE", "HWID1", "HWID2", "ST1", "HT1", "HEALTH",
      "HEARTBEAT"
  },

  HOLD_ADDR_TEST = 0,
  HOLD_ADDR_SPO1 = 1, -- 二次水泵1  手动/自动, debug用
  HOLD_ADDR_SPK1 = 2, -- 二次水泵1  启停控制
  HOLD_ADDR_SPO2 = 3, -- 二次水泵2  手动/自动
  HOLD_ADDR_SPK2 = 4, -- 二次水泵2  启停控制
  HOLD_ADDR_MC1K = 5, -- 空调水机组主机 1
  HOLD_ADDR_MC2K = 6, -- 空调水机组主机 2
  HOLD_ADDR_CMV  = 7, -- 毛细管制冷水阀
  HOLD_ADDR_HMV  = 8, -- 辅助制热
  HOLD_ADDR_HPK  = 9, -- 热水循环  启停控制
  HOLD_ADDR_HPO  = 10, -- 热水循环  手动/自动
  HOLD_ADDR_HBK  = 11, -- 锅炉启停
  -- 两个继电器构成组合开关。
  -- PF1=0，PF1K=0，代表“关机”
  -- PF1=0，PF1K=1，代表“低档”
  -- PF1=1，PF1K=0，代表“高档”
  HOLD_ADDR_PF1  = 12, -- 排风扇1 高低档位控制
  HOLD_ADDR_PF1K = 13, -- 排风扇1 风机开关
  -- 两个继电器构成组合开关。
  -- PF2=0，PF2K=0，代表“关机”
  -- PF2=0，PF2K=1，代表“低档”
  -- PF2=1，PF2K=0，代表“高档”
  HOLD_ADDR_PF2  = 14,
  HOLD_ADDR_PF2K = 15,
  --   两个继电器构成组合开关。
  -- PF3=0，PF3K=0，代表“关机”。
  -- PF3=0，PF3K=1，代表“低档”。
  -- PF3=1，PF3K=0，代表“高档”
  HOLD_ADDR_PF3  = 16,
  HOLD_ADDR_PF3K = 17,

  HOLD_ADDR_MC3K = 18, -- 空调水机组主机 3, 可能不存在

  HOLD_ADDR_MODE = 19,
  HOLD_ADDR_SYNC = 20,

  hold_names = {
      'TEST','SPO1','SPK1','SPO2','SPK2','MC1K','MC2K','CMV','HMV','HPK','HPO',
      'HBK', 'PF1', 'PF1K','PF2', 'PF2K', 'PF3', 'PF3K', 'MC3K', 'MODE', 'SYNC'
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
    return nil
end

return _M
