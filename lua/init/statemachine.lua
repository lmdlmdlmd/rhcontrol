local _M = {}
local monitor = require 'hal.monitor'
local Ate = require 'dev.ate'
local Newfan = require 'dev.newfan'
local Aircond = require 'dev.aircond'
local HOST = '192.168.0.7'
-- local HOST = '127.0.0.1'

local log = ngx.log
local ERR = ngx.ERR
-- local DBG = ngx.DEBUG
-- local ins = require 'lib.inspect'

_M.init = function()
    local ate1 = Ate.new(0xf)
    local newfan1 = Newfan.new(1)
    local aircond1 = Aircond.new(1)

    monitor.register(HOST, 29, ate1, 'ate')
    monitor.register(HOST, 32, newfan1, 'newfan1')
    monitor.register(HOST, 35, aircond1, 'aircond1')
end

_M.run = function()
    monitor.read()
    local ate = monitor.get('ate')
    local newfan1 = monitor.get('newfan1')
    local aircond1 = monitor.get('aircond1')
    log(ERR, 'temp is:', ate:get_temp())
    log(ERR, 'humi is:', ate:get_humi())

    log(ERR, ate)
    log(ERR, newfan1)
    log(ERR, aircond1)
end

-- _M.init()
-- _M.run()
return _M
