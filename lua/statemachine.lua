local _M = {}
local monitor = require 'hal.monitor'
local Ate = require 'dev.ate'
local HOST = '192.168.0.7'
-- local HOST = '127.0.0.1'

local log = ngx.log
local ERR = ngx.ERR
-- local DBG = ngx.DEBUG
-- local ins = require 'lib.inspect'

_M.init = function()
    local ate1 = Ate.new()

    monitor.register(HOST, 29, ate1)
end

_M.run = function()
    monitor.read()
    log(ERR, 'temp is:', monitor.devs[1].obj:get_temp())
end

return _M
