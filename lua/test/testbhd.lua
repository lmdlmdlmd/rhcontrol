local bridge = require 'dev.bridge'
local util = require 'lib.util'
local net  = require 'lib.net'

local log = ngx.log
local ERR = ngx.ERR
local DBG = ngx.DEBUG
local ins = require 'lib.inspect'

local format_bytes = util.format_bytes
local stringtotable = util.stringtotable

-- auth first
ngx.say('auth')
local header = bridge.make_header(0x2, '410108S101QLS00001')
local body = bridge.make_body_auth('a1beba48cdaa429191e8fcb6bdc8517e')

local msg = bridge.pack(header, body)
ngx.say('len header=', #header)
ngx.say('body header=', #body)
ngx.say(format_bytes(msg))

local readdata, err = net.send('222.143.32.246',8001, msg)
ngx.say(readdata)
ngx.say(ins(format_bytes(stringtotable(readdata))))
ngx.say(ins(err))

-- -- HEARTBEAT
-- ngx.say('heartbeat')
-- header = bridge.make_header(0x3, '410108S101QLS00001')
-- body = bridge.make_body_heartbeat()
--
-- msg = bridge.pack(header, body)
-- readdata, err = net.send('222.143.32.246',8001, msg)
-- ngx.say(readdata)
-- ngx.say(ins(format_bytes(stringtotable(readdata))))
-- ngx.say(ins(err))

-- -- status
-- ngx.say('status')
-- header = bridge.make_header(0x8, '410108S101QLS00001')
-- body = bridge.make_body_status(1)
-- msg = bridge.pack(header, body)
-- ngx.say('len header=', #header)
-- ngx.say('body header=', #body)
-- ngx.say(format_bytes(msg))
--
-- readdata, err = net.send('222.143.32.246',8001, msg)
-- ngx.say(readdata)
-- ngx.say(ins(format_bytes(stringtotable(readdata))))
-- ngx.say(ins(err))

ngx.say('data')
header = bridge.make_header(0x13, '410108S101QLS00001')
local data = {
  {value = 0.1, length = 8},
  {value = 0.2, length = 8},
  {value = 0.3, length = 8},
  {value = 220, length = 2},
  {value = 230, length = 2},
  {value = 240, length = 2},
  {value = 24, length = 1},
  {value = 11.1, length = 8},
}
body = bridge.make_body_data_env(data)
msg = bridge.pack(header, body)
ngx.say('len header=', #header)
ngx.say('body header=', #body)
ngx.say(format_bytes(msg))

readdata, err = net.send('222.143.32.246',8001, msg)
ngx.say(readdata)
ngx.say(ins(format_bytes(stringtotable(readdata))))
ngx.say(ins(err))
