local ds    = require "lib.ds"
local crc16 = require "lib.crc16"
local util  = require "lib.util"
local bit   = require "bit"
local format = string.format
local lshift = bit.lshift

-- local log = ngx.log
-- local ERR = ngx.ERR
-- local DBG = ngx.DEBUG
-- local ins = require 'lib.inspect'

local Ate = {}
Ate.__index = Ate

local dev_config = {
    start_reg = 0x00,
    max_len = 24,
    read_key_fun = 0x03,
    write_key_fun = 0x06
}

function Ate.new(addr)
    local self = setmetatable({}, Ate)
    self.addr = addr or 0xf -- default addr is 0x0f
    self.data = {}
    self.read_all_cmd = nil
    self.health = 0
    return self
end

function Ate.get_read_cmd(self)
    local addr = self.addr
    -- buffer it, and no need to caculate everytime
    if self.read_all_cmd then
        return self.read_all_cmd
    end
    local cmd = { addr, dev_config.read_key_fun,
                        0x00, dev_config.start_reg,
                        0x00, dev_config['max_len']}
    local crc_list = crc16(cmd)
    cmd[#cmd + 1] = crc_list[1]
    cmd[#cmd + 1] = crc_list[2]
    self.read_all_cmd = cmd
    return cmd
end

--- data format
-- command: 0F,03,00,00,00,16,C5,2A
-- 0x0 0xa version
-- 0x0 0xf address
-- 0x0 0x0 pm2
-- 0x0 0x0 eco2
-- 0x0 0x0 tvoc
-- 0x0 0x0 temp
-- 0x0 0x0 humis
-- 0x0 0x0 wofo
-- 0x0 0x1 wifi
-- 0x0 0x8 pm2.5
-- 0x2 0x79 eco2
-- 0x0 0x2 tvoc
-- 0x0 0xe9 temp
-- 0x0 0x1e shidu
-- 0x0 0xa  temp regulate
-- 0x0 0xa  du reguate
-- 0x0 0x0  wifi
-- 0x0 0x1e wifi
-- 0x0 0x2   led close
-- 0x0 0x1   pm2.5 always working
-- 0x0 0x5   pm2.5 minutes
-- 0x0 0xf   LED 设置
-- 0x9a 0x1c CRC-16
Ate.set_data = function(self, newdata, start )
    if not (newdata and type(newdata) == 'table') then
        return nil
    end
    self.health = ds.DEV_HEALTH_ONLINE
    local data = self.data
    start = start or 0
    for i, v in ipairs(newdata) do
        data[i + start] = v
        -- log(ERR, i+start, '=', v)
    end
    return true
end

Ate.fail = function(self, code)
    self.health = code
end

local get = function(self, index)
  local data = self.data
  local nindex = 3 + (index * 2)
  if self.health ~= ds.DEV_HEALTH_OFFLINE then
      return lshift(data[nindex - 1], 8) + data[nindex]
  end
  return nil
end

Ate.get_pm2 = function(self)
    return get(self, 3)
end
Ate.get_temp = function(self)
    local status = get(self,6)
    if status == 0 then
        return get(self, 13)
    end
    return nil
end
Ate.get_humi = function(self)
    local status = get(self,7)
    if status == 0 then
        return get(self, 14)
    end
    return nil
end

Ate.__tostring = function(self)
    local str = {}
    str[#str + 1] = format('ate:%d, health=%d', self.addr, self.health)
    str[#str + 1] = format('data: %s', util.format_bytes(self.data))
    return table.concat(str, "\r\n")
end

return Ate
