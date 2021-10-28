-- do something
local monitor = require 'hal.monitor'

ngx.status = ngx.HTTP_OK
ngx.header.content_type = "application/json; charset=utf-8"

ngx.say(monitor.devs[1].obj:get_temp())
ngx.say(monitor.devs[1].obj:get_humi())
