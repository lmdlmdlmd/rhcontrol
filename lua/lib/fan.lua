local input_index = 1
local hold_index = 1
local _M = {
    -- hold registers
    HOLD_ADDR_DWK = hold_index,
    HOLD_ADDR_JSK = hold_index + 1,
    HOLD_ADDR_DHV = hold_index + 2,
    HOLD_ADDR_FAV = hold_index + 3,
    HOLD_ADDR_FAK = hold_index + 4,
    HOLD_ADDR_FAO = hold_index + 5,
    HOLD_ADDR_EAK = hold_index + 6,
    HOLD_ADDR_EAO = hold_index + 7,

    HOLD_ADDR_FAX = hold_index + 8,
    HOLD_ADDR_EAX = hold_index + 9,

    HOLD_ADDR_MODE = hold_index + 10,
    HOLD_ADDR_RAHS1 = hold_index + 11,
    HOLD_ADDR_RAHS2 = hold_index + 12,
    HOLD_ADDR_DHST1 = hold_index + 13,
    HOLD_ADDR_H9 = hold_index + 14,
    HOLD_ADDR_H8 = hold_index + 15,
    HOLD_ADDR_LD1 = hold_index + 16,
    HOLD_ADDR_LDS1 = hold_index + 17,
    HOLD_ADDR_LD2 = hold_index + 18,
    HOLD_ADDR_LDS2 = hold_index + 19,
    HOLD_ADDR_WTS1 = hold_index + 20,
    HOLD_ADDR_WTS2 = hold_index + 21,
    HOLD_ADDR_WTS3 = hold_index + 22,
    HOLD_ADDR_SYNC = hold_index + 23,

    -- input registers
    INPUT_ADDR_XLW1 = input_index,
    INPUT_ADDR_XLW2 = input_index + 1,
    INPUT_ADDR_FPR = input_index + 2,
    INPUT_ADDR_FAR = input_index + 3,
    INPUT_ADDR_FAE = input_index + 4,
    INPUT_ADDR_EAR = input_index + 5,
    INPUT_ADDR_EAE = input_index + 6,
    INPUT_ADDR_RAT1 = input_index + 7,
    INPUT_ADDR_RAH1 = input_index + 8,
    INPUT_ADDR_FAT1 = input_index + 9,
    INPUT_ADDR_FAH1 = input_index + 10,
    INPUT_ADDR_SAT1 = input_index + 11,
    INPUT_ADDR_SAH1 = input_index + 12,
    INPUT_ADDR_DHT1 = input_index + 13,

    INPUT_ADDR_HEALTH  = input_index + 14,

    INPUT_ADDR_HEARTBEAT = input_index + 15,
    INPUT_ADDR_VER = input_index + 16,
}

return _M
