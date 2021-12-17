local _M = {}
local monitor = require 'hal.monitor'
local l = require 'lib.log'
local Ate = require 'dev.ate'
local Newfan = require 'dev.newfan'
-- local Fan = require 'lib.fan'
local Aircond = require 'dev.aircond'
-- local Air = require 'lib.air'
local operation = require 'hal.operation'
-- local hex = require 'lib.util'.hex
local helprd  = require "lib.helpredis"
local ruihe = require 'dev.ruihe'
local humi = require 'init.humi'
local wind = require 'init.wind'
local temp = require 'init.temp'

local HOST = '192.168.254.7'
-- local HOST = '192.168.0.7'

local log = ngx.log
local ERR = ngx.ERR
-- local DBG = ngx.DEBUG
-- local ins = require 'lib.inspect'
local format = string.format

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
    -- get all provision data from redis
    ruihe.serialization()

    monitor.read_input()
    ngx.sleep(1)
    monitor.read_hold()
    ngx.sleep(1)

    local ate = monitor.get('ate')
    local fan1 = monitor.get('newfan1')
    local air1 = monitor.get('aircond1')
    local mode = ruihe.get('mode')

    local redis = helprd.get()

    if ate then
        local home_temp = ate:get_temp()
        local home_humi = ate:get_humi()
        local home_pm25 = ate:get_pm25()
        local home_19 = ate:get(19)
        l.log(format(
              'temp = %d, humi = %d, pm25 = %d, 19 = %d',
              home_temp or 0, home_humi or 0, home_pm25 or 0, home_19 or 0)
        )
    end


    humi.add(mode, redis, ruihe, fan1, air1)
    temp.heat(mode, redis, ruihe, fan1, air1)
    wind.letin(mode, redis, ruihe, fan1)

    operation.write()

    -- log(ERR, ate)
    -- log(ERR, fan1)
    log(ERR, air1)
end

-- _M.init()
-- _M.run()
return _M
