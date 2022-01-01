local util = require 'lib.util'
local net  = require 'lib.net'
local crc16 = require 'lib.crc16'

local sm4_class  = require 'lib.sm4'
local format_bytes = util.format_bytes
local stringtotable = util.stringtotable
local tabletostring = util.tabletostring

local log = ngx.log
local ERR = ngx.ERR
local DBG = ngx.DEBUG
local ins = require 'lib.inspect'

local header = {
  0x07, --桥梁
  0x01, --注册
  0x00,0x00,0x00,0x00,
  0x00,
  0x01,
  0x01,
  0x00, 0x01,
}
local devid = stringtotable('410108S101QLS00001')
for _,v in ipairs(devid) do
  header[#header + 1] = v
end
local time = {
  0x14,0x15,12,31,17,30,35
}
for _,v in ipairs(time) do
  header[#header + 1] = v
end

local register_msg = {
  0x07,
  0x40,0x41, 0x20,0x20,0x20,
}
for _,v in ipairs(devid) do
  register_msg[#register_msg + 1] = v
end
register_msg[#register_msg + 1] = 0x20
register_msg[#register_msg + 1] = 0x20

for _,v in ipairs(devid) do
  register_msg[#register_msg + 1] = v
end

local lng = {
  0x40,0x5c,0x63,0x33,0x9e,0xca,0x42,0x20
}
local lat = {
  0x40,0x5c,0x63,0x33,0x9e,0xca,0x42,0x20
}
for _,v in ipairs(lng) do
  register_msg[#register_msg + 1] = v
end
for _,v in ipairs(lat) do
  register_msg[#register_msg + 1] = v
end
register_msg[#register_msg + 1] = 0x1
local ip = {
  0x20,0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00,0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd
}
for _,v in ipairs(ip) do
  register_msg[#register_msg + 1] = v
end
register_msg[#register_msg + 1] = 0x00
register_msg[#register_msg + 1] = 0x50
register_msg[#register_msg + 1] = 0xbb
register_msg[#register_msg + 1] = 0xbb
register_msg[#register_msg + 1] = 0x01
local manu_time = {
  0x2,0x0,0x2,0x0,0x0,0x7,0x0,0x7
}
for _,v in ipairs(manu_time) do
  register_msg[#register_msg + 1] = v
end

-- local key = 'zhgl'

-- print('a:', ins(register_msg))
-- local sm4 = sm4_class:new(key)
-- local str = tabletostring(register_msg)
-- -- print(str)
-- local en_text = sm4:encrypt(str)
local body = register_msg -- stringtotable(en_text)
-- print(en_text)
local body_msg = {}
header[6] = #body
print(#body)
for _, v in ipairs(header) do
  body_msg[#body_msg + 1] = v
end
for _, v in ipairs(body) do
  body_msg[#body_msg + 1] = v
end

-- ngx.say(format_bytes(body_msg))

local crc = crc16(body_msg)

local msg = {0x7e}
for _, v in ipairs(body_msg) do
  if v == 0x7e then
    msg[#msg + 1] = 0x7d
    msg[#msg + 1] = 0x02
  else
    msg[#msg + 1] = v
  end
end
msg[#msg + 1] = crc[1]
msg[#msg + 1] = crc[2]
msg[#msg + 1] = 0x7e
-- local de_text = sm4:decrypt(en_text)
-- print(de_text)


ngx.say(format_bytes(msg))

ngx.say(tabletostring(msg))
local readdata, err = net.send('222.143.32.246',8001, msg)
ngx.say(readdata)
ngx.say(ins(format_bytes(stringtotable(readdata))))
ngx.say(ins(err))
