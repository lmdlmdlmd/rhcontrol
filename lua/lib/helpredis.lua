local _M = {}

local redis = require "lib.redis"

_M.get = function()
    -- try multi times
    local red = redis:new()
    if not red then
        red = redis:new()
    end
    return red
end

return _M
