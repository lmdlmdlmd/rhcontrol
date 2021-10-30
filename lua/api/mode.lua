local process = require "lib.process"


local ret = {}
local args = ngx.req.get_uri_args()
local mode = args.v

if not mode then
    ret.code = 100
    ret.msg = 'v is empty'
    goto exit
end

do
    
end

::exit::

process.after(ret)
