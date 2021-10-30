local cjson = require "cjson.safe"

-- local log = ngx.log
-- local DBG = ngx.DEBUG
-- local ERR = ngx.ERR
-- local ins = require "lib.inspect"

local _M = {}


_M.before = function()
    ngx.req.read_body() -- 显示去读取body
    local body_text = ngx.req.get_body_data()
    local body_data = {}

    if body_text then
        body_data = cjson.decode(body_text) or {}
        local new_body_data = {}
        for k, v in pairs(body_data) do
            -- remove userdata cases
            if type(v) ~= 'userdata' then
                new_body_data[k] = v
            end
        end
        body_data = new_body_data
    end

    return body_data, body_text
end

_M.after = function(ret)
    ngx.status = ngx.HTTP_OK
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(cjson.encode(ret))
end

_M.log = function(data)
    return data
end

return _M
