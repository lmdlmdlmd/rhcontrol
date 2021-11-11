local base_input_index = 2
local base_hold_index  = 1

-- 0x01,0x04,0x28,
-- 0x00,0x00,
-- 0x00,0x01, SPR1
-- 0x00,0x01, SPE1
-- 0x00,0x01, SPR2
-- 0x00,0x01, SPE2
-- 0x00,0x00, HPE
-- 0x00,0x00, HWID1
-- 0x00,0x00, HIWID
-- 0xFB,0x1E,
-- 0xF6,0x3C,
-- 0xFB,0x1E,
-- 0xF6,0x3C,
-- 0xFB,0x1E,
-- 0xF6,0x3C,
-- 0xA1,0x76,
-- 0x82,0x43,
-- 0x5A,0x5A,
-- 0x00,0x00,0x00,0x00,0x00,0x00,0xEA,0x04

local _M = {
  INPUT_ADDR_SPR1 = base_input_index,
  INPUT_ADDR_SPE1 = base_input_index + 1,
  INPUT_ADDR_SPR2 = base_input_index + 2,
  INPUT_ADDR_SPE2 = base_input_index + 3,
  INPUT_ADDR_HPE  = base_input_index + 4,
  INPUT_ADDR_HW_ID1 = base_input_index + 5,
  INPUT_ADDR_HW_ID2 = base_input_index + 6,

  INPUT_ADDR_HEALTH = base_input_index + 7,
  INPUT_ADDR_HEARTBEAT = base_input_index + 8,
  INPUT_ADDR_VER = base_input_index + 9,


  HOLD_ADDR_SPO1 = base_hold_index,
  HOLD_ADDR_SPK1 = base_hold_index + 1,
  HOLD_ADDR_SPO2 = base_hold_index + 1,
  HOLD_ADDR_SPE2 = base_hold_index + 1,
  HOLD_ADDR_MC1K = base_hold_index + 1,
  HOLD_ADDR_MC2K = base_hold_index + 1,
  HOLD_ADDR_CMV  = base_hold_index + 1,
  HOLD_ADDR_HMV  = base_hold_index + 1,
  HOLD_ADDR_HPK  = base_hold_index + 1,
  HOLD_ADDR_HPO  = base_hold_index + 1,
  HOLD_ADDR_HBK  = base_hold_index + 1,
  HOLD_ADDR_PF1  = base_hold_index + 1,
  HOLD_ADDR_PF1K = base_hold_index + 1,
  HOLD_ADDR_PF2  = base_hold_index + 1,
  HOLD_ADDR_PF2K = base_hold_index + 1,
  HOLD_ADDR_PF3  = base_hold_index + 1,
  HOLD_ADDR_PF3K = base_hold_index + 1,
}

return _M
