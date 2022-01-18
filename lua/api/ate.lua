-- do something
local Ate = require 'dev.ate'
local cjson      = require "cjson.safe"

ngx.status = ngx.HTTP_OK
ngx.header.content_type = "application/json; charset=utf-8"


local ate1 = Ate.new(0xf)
ate1:unserialization()
local d = {
    humi = ate1:get_humi(),
    temp = ate1:get_temp(),
    pm25 = ate1:get_pm25(),
}
ngx.print(cjson.encode(d))
