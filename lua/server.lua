
local log = ngx.log

local sock, err = ngx.req.socket()
if not sock then
    ngx.exit(500)
end
while true do
    local data
    data, err = sock:receive('*l')
    if data then
        local sent, err1 = sock:send(data .. '\n')
        if err1 then
            return ngx.exit(200)
        end
    end
end