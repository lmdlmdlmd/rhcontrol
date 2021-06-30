
local log = ngx.log
local ERR = ngx.ERR
local ate = require "dev.ate"

local sock, err = ngx.req.socket()
if not sock then
    ngx.exit(500)
end
sock:settimeouts(10000, 40000, 10000)  -- 10s timeout for connect/read/write
local count = 10
while count > 0 do
    local send_data = ate.read_all(sock)
    local bytes_send_data = {}
    for i = 1, #send_data do
       table.insert(bytes_send_data, string.format("0x%x ", send_data[i]))
    end
    log(ERR, 'send data:' .. table.concat(bytes_send_data, ','))

    local data
    data, err = sock:receiveany(10 * 1024)
    if data then
        local bytes_data = {}
        for i = 1, #data do
           table.insert(bytes_data, string.format("0x%x ", string.byte(data, i)))
        end
        log(ERR, 'receive data:' .. table.concat(bytes_data, ','))
    else
        -- log(ERR,err)
    end
    count = count - 1
end

ngx.exit(200)