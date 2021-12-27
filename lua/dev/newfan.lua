local ds    = require "lib.ds"
local crc16 = require "lib.crc16"
local util  = require "lib.util"
local bit   = require "bit"
local Fan   = require "lib.fan"
local Task  = require "lib.task"
local Ld    = require "lib.ld"
local cjson  = require "cjson.safe"
local helprd = require "lib.helpredis"
local format = string.format
local lshift = bit.lshift
local format_bytes = util.format_bytes

-- local log = ngx.log
-- local ERR = ngx.ERR
-- local DBG = ngx.DEBUG
-- local ins = require 'lib.inspect'

local Newfan = {}
Newfan.__index = Newfan


-- 1— 位操作指令：读线圈状态01H、读离散输入状态02H、写单个线圈05H、写多个线圈0FH.
-- 2— 字节操作指令：读保存寄存器03H、读输入寄存器04H、写单个保存寄存器06H、写多个保存寄存器10H.
local dev_config = {
    input_registetr = {
        key = 0x04,
        start_reg = 0x0,
        max_len = 18
    },
    hold_register = {
        key = 0x03,
        start_reg = 0x0,
        max_len = 24
    },
    write_key_fun = 0x06,
    max_sick_to_offline = 4,
    name = 'fan'
}

function Newfan.new(addr, host, port)
    local self = setmetatable({}, Newfan)
    self.addr = addr or 0x1 -- default addr is 0x0f
    self.host = host
    self.port = port
    self.input_data = {}
    self.hold_data = {}
    self.read_input_cmd = nil
    self.read_hold_cmd = nil
    self.health = ds.DEV_HEALTH_OFFLINE
    self.sick_count = 0
    return self
end

-- default read hold register, 默认读取input寄存器， 如果有多的话
function Newfan.get_read_cmd(self, tp)
    local addr = self.addr

    local config = dev_config.input_registetr
    if tp == 'hold' then
        config = dev_config.hold_register
        if self.read_hold_cmd then
            return self.read_hold_cmd
        end
    else
        -- buffer it, and no need to caculate everytime
        if self.read_input_cmd then
            return self.read_input_cmd
        end
    end
    local cmd = { addr, config.key,
                        0x00, config.start_reg,
                        0x00, config.max_len}
    local crc_list = crc16(cmd)
    cmd[#cmd + 1] = crc_list[1]
    cmd[#cmd + 1] = crc_list[2]
    if tp == 'hold' then
        self.read_hold_cmd = cmd
    else
        self.read_input_cmd = cmd
    end
    return cmd
end

Newfan.get_hold_cmd = function(self)
    return self:get_read_cmd("hold")
end

Newfan.set_data = function(self, newdata, start, tp)
    if not (newdata and type(newdata) == 'table') then
        return nil
    end
    self.health = ds.DEV_HEALTH_ONLINE
    self.sick_count = 0
    local data = self.input_data
    if tp == 'hold' then
        data = self.hold_data
    end
    start = start or 0
    for i, v in ipairs(newdata) do
        data[i + start] = v
        -- log(ERR, i+start, '=', v)
    end
    Newfan.serialization(self)
    return true
end

Newfan.fail = function(self, code)
    self.sick_count = self.sick_count + 1
    local old_health = self.health
    if self.sick_count > dev_config.max_sick_to_offline then
        self.health = ds.DEV_HEALTH_OFFLINE
    else
        self.health = code
    end

    -- 如果值不一样，则序列化
    if old_health ~= self.health then
        Newfan.serialization(self)
    end
end

Newfan.get_health = function(self)
    return self.health
end
Newfan.get_host = function(self)
    return self.host
end
Newfan.get_port = function(self)
    return self.port
end

local get = function(self, data, index)
  index = index + 1
  local nindex = 3 + (index * 2)
  if nindex > #data then
      return nil
  end
  if self.health ~= ds.DEV_HEALTH_OFFLINE then
      return lshift(data[nindex - 1], 8) + data[nindex]
  end
  return nil
end

Newfan.get = function(self, index)
    local data = self.input_data
    return get(self, data, index)
end

Newfan.has_dwk = function(self)
    --  “1”代表有直膨式主机，“0”代表无直膨主机，需要共用空调主机
    local v = self:get(Fan.INPUT_ADDR_HWID)
    return v > 0
end

Newfan.get_hold = function(self, index)
    local data = self.hold_data
    return get(self, data, index)
end

Newfan.get_cmd = function(self, index, val)
    -- tp is address
    index = tonumber(index)
    local addr = self.addr
    local cmd = { addr, dev_config.write_key_fun,
                  0x00, index,
                  0x00, val}
    local crc_list = crc16(cmd)
    cmd[#cmd + 1] = crc_list[1]
    cmd[#cmd + 1] = crc_list[2]
    return cmd
end

Newfan.set = function(self, redis, index, val)
    local key = Task.get_redis_key(dev_config.name, self.addr, index)
    -- log(ERR, key, ':', index, ':', val)
    redis:lpush(key, val)
end
-- 通过网operation注册往对应设备下发的命令
Newfan.registe_service = function(self, operation)
    local pfun = function() return self.get_cmd end
    for i = Fan.HOLD_ADDR_TEST, Fan.HOLD_ADDR_SYNC, 1 do
        local taskkey = Task.get_redis_key(dev_config.name, self.addr, i)
        operation.register(taskkey, self, i, pfun)
    end
end

local get_key = function(name, addr)
    return format('%s:%d', name, addr)
end

Newfan.serialization = function(self)
    local d = {
        input_data = self.input_data,
        hold_data  = self.hold_data,
        health = self.health,
        sick_count = self.sick_count,
        ts = ngx.time()
    }
    local key = get_key(dev_config.name, self.addr)
    local d_str = cjson.encode(d)
    -- log(ERR, d_str)
    local redis = helprd.get()
    redis:set(key, d_str)
    return  true
end

Newfan.unserialization = function(self)
    local key = get_key(dev_config.name, self.addr)
    -- local d_str = cjson.encode(d)
    local redis = helprd.get()
    local d_str = redis:get(key)
    -- log(ERR, d_str)
    if d_str then
        local d = cjson.decode(d_str)
        if d then
            self.input_data = d.input_data
            self.hold_data = d.hold_data
            self.health = d.health
            self.sick_count = d.sick_count
            self.ts = d.ts
            return  true
        end
    end
    return  false
end

-- 回风露点值,RAT1和RAH1计算出来LD1
Newfan.get_ld1 = function(self)
    local rat1 = Newfan.get(self, Fan.INPUT_ADDR_RAT1)
    local rah1 = Newfan.get(self, Fan.INPUT_ADDR_RAH1)

    return Ld.get_ld(rat1, rah1)
end

-- 送风露点,送风温度和湿度计算出来的数值
Newfan.get_ld2 = function(self)
    local sat1 = Newfan.get(self, Fan.INPUT_ADDR_SAT1)
    local sah1 = Newfan.get(self, Fan.INPUT_ADDR_SAH1)

    return Ld.get_ld(sat1, sah1)
end

Newfan.__tostring = function(self)
    local str = {}
    str[#str + 1] = format('newfan:%d, health=%d', self.addr, self.health)
    str[#str + 1] = format('input_data: %s', format_bytes(self.input_data))
    str[#str + 1] = format('hold_data: %s', format_bytes(self.hold_data))
    return table.concat(str, "\r\n")
end

return Newfan
