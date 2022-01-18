local Ruihe = require 'dev.ruihe'

ngx.status = ngx.HTTP_OK
ngx.header.content_type = "application/text; charset=utf-8"



Ruihe.unserialization()

ngx.say(Ruihe.tostring())
