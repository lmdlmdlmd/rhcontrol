local _M = {}

local log = ngx.log
local DBG = ngx.DEBUG
local ERR = ngx.ERR

local ins = require 'lib.inspect'

_M.log = function(msg, ...)
    log(DBG, ins(msg), ...)
end

_M.err = function(msg, ...)
    log(ERR, ins(msg), ...)
end

return _M
