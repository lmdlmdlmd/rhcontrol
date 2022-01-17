local Aircond = require 'dev.aircond'

ngx.status = ngx.HTTP_OK
ngx.header.content_type = "application/text; charset=utf-8"


local air1 = Aircond.new(0x1)
air1:unserialization()

ngx.say(air1:__tostring())
