local _M = {}
local monitor = require 'hal.monitor'
local Ate = require 'dev.ate'
local Newfan = require 'dev.newfan'
local Aircond = require 'dev.aircond'
local operation = require 'hal.operation'

local HOST = '192.168.0.7'
-- local HOST = '127.0.0.1'

local log = ngx.log
local ERR = ngx.ERR
local DBG = ngx.DEBUG
-- local ins = require 'lib.inspect'

_M.init = function()
    local ate1 = Ate.new(0xf, HOST, 29)
    local fan1 = Newfan.new(1, HOST, 32)
    local air1 = Aircond.new(1, HOST, 35)

    log(ERR, monitor.register(ate1, 'ate'))
    log(ERR, monitor.register(fan1, 'newfan1'))
    log(ERR, monitor.register(air1, 'aircond1'))

    ate1:registe_service(operation)
    -- fan1:registe_service(operation)
    -- air1:registe_service(operation)
end

_M.run = function()
    monitor.read()

    local ate = monitor.get('ate')
    -- local fan1 = monitor.get('newfan1')
    -- local air1 = monitor.get('aircond1')
    --
    -- local ate_health = ate:health()
    -- local fan1_health = fan1:health()
    -- local cond1_health = air1:health()

    local home_temp = ate:get_temp()
    local home_humi = ate:get_humi()
    local home_pm25 = ate:get_pm25()
    local home_19 = ate:get(19)
    log(DBG, 'temp is:', home_temp)
    log(DBG, 'humi is:', home_humi)
    log(DBG, 'pm25 is:', home_pm25)
    log(DBG, '19 is:', home_19)


    operation.write()
    -- log(ERR, ate)
    -- log(ERR, newfan1)
    -- log(ERR, aircond1)
end

-- _M.init()
-- _M.run()
return _M
