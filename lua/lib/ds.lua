local _M = {}

_M.DEV_HEALTH_ONLINE = 1
_M.DEV_HEALTH_OFFLINE = 2
_M.DEV_HEALTH_SICK = 3

_M.DEV_TYPE_ATE = 1
_M.DEV_TYPE_NEWFAN = 2
_M.DEV_TYPE_AIRCOND = 3

_M.ALARM_XLW1 = 1
_M.ALARM_XLW2 = 2
_M.ALARM_SPE1 = 3
_M.ALARM_SPE2 = 4
_M.ALARMS = {
    'XLW1 初效压差故障',
    'XLW2 高效压差故障',
    'SPE1 二次水泵1故障',
    'SPE2 二次水泵2故障'
}

_M.COLD_MODE = 1
_M.HOT_MODE = 2

_M.INPUT_REG = 1
_M.HOLD_REG  = 2

_M.MODE_SUMMER_COLD = 1
_M.MODE_WINTER_HEAT = 2
_M.MODES = {
    '夏天制冷',
    '冬天加热'
}

return _M
