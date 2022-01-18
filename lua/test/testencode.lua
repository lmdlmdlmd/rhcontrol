

local log = ngx.log
local ERR = ngx.ERR
local DBG = ngx.DEBUG
local ins = require 'lib.inspect'
local cjson  = require "cjson.safe"

local a = {1,2,3,nil,nil,nil, 100, nil, nil, 100}

local r1,r2 = cjson.encode({
  a = a
})
ngx.say(r1)
ngx.say(r2)

ngx.say(ins(a))
