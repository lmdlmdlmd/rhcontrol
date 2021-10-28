local ds    = require "lib.ds"
local crc16 = require "lib.crc16"
local util  = require "lib.util"
-- local bit   = require "bit"
local format = string.format
-- local lshift = bit.lshift

-- local log = ngx.log
-- local ERR = ngx.ERR
-- local DBG = ngx.DEBUG
-- local ins = require 'lib.inspect'

local Aircond = {}
Aircond.__index = Aircond

local dev_config = {
    start_reg = 0x00,
    max_len = 24,
    read_key_fun = 0x03,
    write_key_fun = 0x06
}

function Aircond.new(addr)
    local self = setmetatable({}, Aircond)
    self.addr = addr or 0xf -- default addr is 0x0f
    self.data = {}
    self.read_all_cmd = nil
    self.health = 0
    return self
end

function Aircond.get_read_cmd(self)
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


Aircond.set_data = function(self, newdata, start )
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

Aircond.fail = function(self, code)
    self.health = code
end

-- local get = function(self, index)
--   local data = self.data
--   local nindex = 3 + (index * 2)
--   if self.health ~= ds.DEV_HEALTH_OFFLINE then
--       return lshift(data[nindex - 1], 8) + data[nindex]
--   end
--   return nil
-- end

Aircond.__tostring = function(self)
    local str = {}
    str[#str + 1] = format('ate:%d, health=%d', self.addr, self.health)
    str[#str + 1] = format('data: %s', util.format_bytes(self.data))
    return table.concat(str, "\r\n")
end

return Aircond
