local _M = {}
local monitor = require 'hal.monitor'
local Ate = require 'dev.ate'
local Newfan = require 'dev.newfan'
local Fan = require 'lib.fan'
local Aircond = require 'dev.aircond'
local Air = require 'lib.air'
local operation = require 'hal.operation'
local hex = require 'lib.util'.hex

local HOST = '192.168.254.7'
-- local HOST = '127.0.0.1'

local log = ngx.log
local ERR = ngx.ERR
local DBG = ngx.DEBUG
-- local ins = require 'lib.inspect'

_M.init = function()
    local ate1 = Ate.new(0xf, HOST, 29)
    local fan1 = Newfan.new(1, HOST, 35)
    local air1 = Aircond.new(1, HOST, 41)

    log(ERR, monitor.register(ate1, 'ate'))
    log(ERR, monitor.register(fan1, 'newfan1'))
    log(ERR, monitor.register(air1, 'aircond1'))

    ate1:registe_service(operation)
    fan1:registe_service(operation)
    air1:registe_service(operation)
end

_M.run = function()
    -- monitor.read_input()
    -- monitor.read_hold()

    local ate = monitor.get('ate')
    local fan1 = monitor.get('newfan1')
    local air1 = monitor.get('aircond1')
    --
    -- local ate_health = ate:health()
    -- local fan1_health = fan1:health()
    -- local cond1_health = air1:health()
    if ate then
        local home_temp = ate:get_temp()
        local home_humi = ate:get_humi()
        local home_pm25 = ate:get_pm25()
        local home_19 = ate:get(19)
        log(DBG, 'temp is:', home_temp)
        log(DBG, 'humi is:', home_humi)
        log(DBG, 'pm25 is:', home_pm25)
        log(DBG, '19 is:', home_19)
    end

    -- if fan1 then
    --     log(DBG, 'XLW1:', fan1:get(Fan.INPUT_ADDR_XLW1))
    --     log(DBG, 'HEALTH:', hex(fan1:get(Fan.INPUT_ADDR_HEALTH)))
    --     log(DBG, 'VER:', hex(fan1:get(Fan.INPUT_ADDR_VER)))
    --     log(DBG, 'DHT1:', fan1:get(Fan.INPUT_ADDR_DHT1))
    --     log(DBG, 'RAT1:', fan1:get(Fan.INPUT_ADDR_RAT1))
    --     log(DBG, 'RAH1:', fan1:get(Fan.INPUT_ADDR_RAH1))
    --     log(DBG, 'FAT1:', fan1:get(Fan.INPUT_ADDR_FAT1))
    --
    --     log(DBG, 'SYNC:', hex(fan1:get_hold(Fan.HOLD_ADDR_SYNC)))
    --     log(DBG, 'JSK:', fan1:get_hold(Fan.HOLD_ADDR_JSK))
    --     log(DBG, 'DWK:', fan1:get_hold(Fan.HOLD_ADDR_DWK))
    --     log(DBG, 'H9:', fan1:get_hold(Fan.HOLD_ADDR_H9))
    -- end

    operation.write()
    -- log(ERR, ate)
    -- log(ERR, fan1)
    log(ERR, air1)
end

-- _M.init()
-- _M.run()
return _M
