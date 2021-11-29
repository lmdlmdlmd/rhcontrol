local _M = {}

local log = ngx.log
local DBG = ngx.DEBUG
local ins = require 'lib.inspect'

_M.log = function(msg, ...)
    log(DBG, ins(msg), ...)
end

return _M
