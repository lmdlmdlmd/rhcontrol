local Newfan = require 'dev.newfan'

ngx.status = ngx.HTTP_OK
ngx.header.content_type = "application/text; charset=utf-8"


local fan1 = Newfan.new(0x1)
fan1:unserialization()

ngx.say(fan1:__tostring())
