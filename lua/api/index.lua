-- do something

ngx.status = ngx.HTTP_OK
ngx.header.content_type = "application/json; charset=utf-8"
ngx.print('hello,ruihe')
