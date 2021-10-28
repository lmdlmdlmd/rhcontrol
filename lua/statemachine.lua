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
    local ate1 = Ate.new()
    local newfan1 = Newfan.new()
    local aircond1 = Aircond.new()

    monitor.register(HOST, 29, ate1)
    monitor.register(HOST, 30, newfan1)
    monitor.register(HOST, 31, aircond1)
end

_M.run = function()
    monitor.read()
    log(ERR, 'temp is:', monitor.devs[1].obj:get_temp())
    log(ERR, 'humi is:', monitor.devs[1].obj:get_humi())
end

-- _M.init()
-- _M.run()
return _M
