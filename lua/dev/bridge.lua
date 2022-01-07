local _M = {}
local util = require 'lib.util'
local crc16 = require 'lib.crc16'
local bit   = require "bit"
-- local lshift = bit.lshift
local rshift = bit.rshift
local band   = bit.band

-- local sm4_class  = require 'lib.sm4'
-- local format_bytes = util.format_bytes
local stringtotable = util.stringtotable
local tstoarray = util.tstoarray
local write_double = util.write_double

-- local log = ngx.log
-- local ERR = ngx.ERR
-- local DBG = ngx.DEBUG
-- local ins = require 'lib.inspect'

_M.make_header = function(tp, devidstr, ts)
    local header = {
      0x07, --桥梁
      tp, --0x1:注册 0x2:鉴权
      0x00,0x00,0x00,0x00,
      0x00,
      0x01,
      0x01,
      0x00, 0x01,
    }
    -- S101410108QLS00001
    local devid = stringtotable(devidstr)
    for _,v in ipairs(devid) do
      header[#header + 1] = v
    end
    local time = tstoarray(ts) -- {20,21,1,5,1,1,1}
    for _,v in ipairs(time) do
      header[#header + 1] = v
    end
    return header
end

_M.make_body_register = function(devidstr)
  local register_msg = {
    0x07, --桥梁
    string.byte('L'), string.byte('M'), string.byte('D'),
    0x20, 0x20
  }
  local devid = stringtotable(devidstr)
  for _,v in ipairs(devid) do
    register_msg[#register_msg + 1] = v
  end
  register_msg[#register_msg + 1] = 0x00
  register_msg[#register_msg + 1] = 0x00

  for _,v in ipairs(devid) do
    register_msg[#register_msg + 1] = v
  end

  -- 经度, 固定写死 https://play.golang.org/p/FO32EmWfjbL
  local lng = {
    -- 0x74, 0xb5, 0x15, 0xfb, 0xcb, 0x6a, 0x5c, 0x40
    0x40, 0x5c, 0x6a, 0xcb, 0xfb, 0x15, 0xb5, 0x74
  }
  -- 纬度
  local lat = {
    -- 0x27, 0x66, 0xbd, 0x18, 0xca, 0x75, 0x41, 0x40
    0x40, 0x41, 0x75, 0xca,0x18, 0xbd, 0x66, 0x27
  }
  for _,v in ipairs(lng) do
    register_msg[#register_msg + 1] = v
  end
  for _,v in ipairs(lat) do
    register_msg[#register_msg + 1] = v
  end
  register_msg[#register_msg + 1] = 0x1
  local ip = { -- 暂时用task服务器
    106, 75, 126, 11, 0x20, 0x20, 0x20, 0x20,
    0x20,0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
  }
  for _,v in ipairs(ip) do
    register_msg[#register_msg + 1] = v
  end

  register_msg[#register_msg + 1] = 0x01
  register_msg[#register_msg + 1] = 0x2c -- 5分钟上传周期
  register_msg[#register_msg + 1] = 0x00
  register_msg[#register_msg + 1] = 0x1f   --端口8002
  register_msg[#register_msg + 1] = 0x42
  local manu_time = stringtotable('20211111')
  for _,v in ipairs(manu_time) do
    register_msg[#register_msg + 1] = v
  end

  return register_msg
end

-- 命 令 码：0x02
-- 数据含义：终端鉴权，应答见平台通用应答。
_M.make_body_auth = function(auth)
    return stringtotable(auth)
end

-- 命 令 码：0x03
-- 数据含义：终端向平台发送心跳数据数据包为空，心跳周期为60秒，平台无需应签。
_M.make_body_heartbeat = function()
    return {}
end

-- 命 令 码：0x08
-- 0x01:运行正常
-- 0x02:运行异常
_M.make_body_status = function( status )
    local msg = {
      status,
    }
    for _ = 1, 100, 1 do
        msg[#msg + 1] = 0x20
    end
    return msg
end

-- 命 令 码：0x13
-- 数据含义：梁桥终端向平台上报当前监测点的风速、风向、风压、温度、湿度、雨量等环境数据。
-- 1	桥面风向	8	单位°
-- 2	桥面风速	8	单位m/s
-- 3	环境温度	8	单位℃
-- 4	混凝土温度	2	单位0.1℃，整数输出
-- 5	钢结构温度	2
-- 6	桥面铺装层温度	2
-- 7	箱梁内湿度	1	单位%，整数输出
-- 8	环境湿度	8	单位%
_M.make_body_data_env = function(data)
    local msg = {}
    for _, v in ipairs(data) do
        local value = v.value
        local len = v.length
        local vt  = v.vt
        local newd
        if vt == 'F' or vt == 'I' then
            if len == 8 then
                newd = write_double(value)
            elseif len == 2 then
                newd = {
                    rshift(band(value, 0xff00), 8),
                    band(value, 0x00ff)
                }
            elseif len == 1 then
                newd = { band(value, 0x00ff) }
            else
                -- log(DBG, ins(v))
                return nil, string.format('int/float length =4 is not considered')
            end
        elseif vt == 'S' then
            local temp = stringtotable(value)
            if len ~= #temp then
                return nil, string.format('%s length is not %d', value, len)
            end
            newd = {}
            for i = 1, len, 1 do
                newd[i] = temp[i] or 0x20
            end
        end

        if newd then
            for _, m in ipairs(newd) do
                msg[#msg + 1] = m
            end
        end
    end
    return msg
end

_M.pack = function(header, body)
    local body_msg = {}
    local len = #body
    header[6] = band(len, 0x00ff)
    header[5] = rshift(band(len, 0xff00), 8)
    header[4] = rshift(band(len, 0xff0000), 16)
    header[3] = rshift(band(len, 0xff0000), 16)
    for _, v in ipairs(header) do
      body_msg[#body_msg + 1] = v
    end
    for _, v in ipairs(body) do
      body_msg[#body_msg + 1] = v
    end

    local crc = crc16(body_msg)

    local msg = { 0x7e }
    for _, v in ipairs(body_msg) do
      if v == 0x7e then
        msg[#msg + 1] = 0x7d
        msg[#msg + 1] = 0x02
      else
        msg[#msg + 1] = v
      end
    end
    msg[#msg + 1] = crc[2]
    msg[#msg + 1] = crc[1]
    msg[#msg + 1] = 0x7e

    return msg
end

return _M
