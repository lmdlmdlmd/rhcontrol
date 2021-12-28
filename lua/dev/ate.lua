local ds    = require "lib.ds"
local crc16 = require "lib.crc16"
local util  = require "lib.util"
local bit   = require "bit"
local helprd = require "lib.helpredis"
local cjson  = require "cjson.safe"
local Task  = require "lib.task"

local format = string.format
local lshift = bit.lshift
local rshift = bit.rshift
local band   = bit.band
local format_bytes = util.format_bytes
local nulltonil = util.nulltonil
local emptytable = util.emptytable

local log = ngx.log
local ERR = ngx.ERR
local DBG = ngx.DEBUG
-- local ins = require 'lib.inspect'

local Ate = {}
Ate.__index = Ate

local dev_config = {
    name = 'ate',
    start_reg = 0x00,
    max_len = 24,
    read_key_fun = 0x03,
    write_key_fun = 0x06,
    max_sick_to_offline = 4,
}

function Ate.new(addr, host, port)
    local self = setmetatable({}, Ate)
    self.addr = addr or 0xf -- default addr is 0x0f
    self.host = host
    self.port = port
    self.data = {}
    emptytable(self.data, 40)
    self.read_all_cmd = nil
    self.health = ds.DEV_HEALTH_OFFLINE
    self.sick_count = 0
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
    self.sick_count = 0
    self.health = ds.DEV_HEALTH_ONLINE
    local data = self.data
    start = start or 0
    for i, v in ipairs(newdata) do
        data[i + start] = v
        -- log(ERR, i+start, '=', v)
    end
    Ate.serialization(self)
    return true
end

Ate.set_data_index = function(self, index, val, serialize)
    local data = self.data
    local nindex = 3 + (index * 2)
    -- if nindex > #data then
    --     ngx.say('index:', index)
    --     return nil
    -- end
    self.health = ds.DEV_HEALTH_ONLINE
    local highbits = rshift(band(val, 0xff00), 8)
    local lowbits  = band(val, 0x00ff)
    data[nindex - 1] = highbits
    data[nindex] = lowbits

    if serialize then
        Ate.serialization(self)
    end
    return true
end

Ate.fail = function(self, code)
    self.sick_count = self.sick_count + 1
    local old_health = self.health
    if self.sick_count > dev_config.max_sick_to_offline then
        self.health = ds.DEV_HEALTH_OFFLINE
    else
        self.health = code
    end

    -- 如果值不一样，则序列化
    if old_health ~= self.health then
        Ate.serialization(self)
    end
end

local get = function(self, index)
  local data = self.data
  local nindex = 3 + (index * 2)
  -- if nindex > #data then
  --     return nil
  -- end
  if self.health ~= ds.DEV_HEALTH_OFFLINE then
      return lshift((data[nindex - 1] or 0), 8) + (data[nindex] or 0)
  end
  return nil
end

Ate.get_health = function(self)
    return self.health
end
Ate.get_host = function(self)
    return self.host
end
Ate.get_port = function(self)
    return self.port
end

Ate.get = function(self, addr)
    return get(self, addr)
end
Ate.get_pm25 = function(self)
    local status = get(self, 3)
    if status == 0 then
        return get(self, 10)
    end
    return nil
end

Ate.get_temp = function(self)
    local status = get(self, 6)
    if status == 0 then
        log(DBG, get(self, 13))
        return get(self, 13)
    end
    return nil
end
Ate.get_humi = function(self)
    local status = get(self, 7)
    if status == 0 then
        log(DBG, get(self, 14))
        return get(self, 14)
    end
    return nil
end

local get_key = function(name, addr)
    return format('%s:%d', name, addr)
end

Ate.serialization = function(self)
    local d = {
        data = self.data,
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

Ate.unserialization = function(self)
    local key = get_key(dev_config.name, self.addr)
    -- local d_str = cjson.encode(d)
    local redis = helprd.get()
    local d_str = redis:get(key)
    -- log(ERR, d_str)
    if d_str then
        local d = cjson.decode(d_str)
        if d then
            self.data = nulltonil(d.data)
            self.health = d.health
            self.sick_count = d.sick_count
            self.ts = d.ts
            -- log(ERR, ins(d))
            return  true
        end
    end
    return  false
end

Ate.get_cmd = function(self, index, val)
    local addr = self.addr
    local cmd = { addr, dev_config.write_key_fun,
                  0x00, index,
                  0x00, val}
    local crc_list = crc16(cmd)
    cmd[#cmd + 1] = crc_list[1]
    cmd[#cmd + 1] = crc_list[2]
    return cmd
end

Ate.set = function(self, redis, index, val)
    local key = Task.get_redis_key(dev_config.name, self.addr, index)
    log(ERR, key, ':', index, ':', val)
    redis:lpush(key, val)
end

-- 通过网operation注册往对应设备下发的命令
Ate.registe_service = function(self, operation)
    local index = 18 -- 18是地址，表示led灯的使用情况
    local ledkey = Task.get_redis_key(dev_config.name, self.addr, index)
    operation.register(ledkey, self, index, function() return self.get_cmd end)
end

Ate.__tostring = function(self)
    local str = {}
    str[#str + 1] = format('ate:%d, health=%d', self.addr, self.health)
    str[#str + 1] = format('data: %s', format_bytes(self.data))
    str[#str + 1] = format('led: %s', get(self, 19) or 'nil')
    return table.concat(str, "\r\n")
end

return Ate
