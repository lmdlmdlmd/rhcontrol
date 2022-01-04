local _M = {}
local ngx_re = require "ngx.re"
local isarray    = require 'table.isarray'
local split = ngx_re.split
local format = string.format

-- local log = ngx.log
-- local DBG = ngx.DEBUG
-- local ERR = ngx.ERR
-- local ins = require "lib.inspect"

_M.format_bytes = function(bytes)
    if not bytes then return '' end
    if type(bytes) ~= 'table' then return bytes end
    local bytes_str = {}
    for _, v in ipairs(bytes) do
        bytes_str[#bytes_str + 1] = format('0x%02X', v)
    end
    return table.concat(bytes_str, ',')
end

_M.stringtotable = function(str)
    local list = split(str, '')
    local ret = {}
    for _, v in ipairs(list) do
        ret[#ret + 1] = string.byte(v)
    end
    return ret
end

-- assume data is only bytes data
_M.tabletostring = function(data)
    if not data then return '' end
    local td = type(data)
    if td == 'string' then
        return data
    elseif td == 'number' then
        return string.char(data)
    elseif td == 'table' then
        local n = {}
        for _, v in ipairs(data) do
            n[#n + 1] = string.char(v)
        end
        return table.concat(n)
    end
    return ''
end

_M.hex = function(v)
  if not v then return nil end
  return format('0x%02X', v)
end

_M.nulltonil = function(list)
    if list and isarray(list) then
        for i,v in ipairs(list) do
            if type(v) == 'userdata' then
                list[i] = nil
            end
        end
    end
    return list
end

_M.emptytable = function(list, len)
    for _ = 1, 1, len do
        list[#list + 1 ] = 0
    end
    return list
end

_M.tstoarray = function( ts )
    ts = tonumber(ts)
    if not ts then
      ts = ngx.time()
    end
    local year = tonumber(os.date('%Y', ts))
    local month = tonumber(os.date('%m', ts))
    local day = tonumber(os.date('%d', ts))
    local hour = tonumber(os.date('%H', ts))
    local min = tonumber(os.date('%M', ts))
    local seconds = tonumber(os.date('%S', ts))
    return {
      math.floor(year/100), year % 100, month, day, hour, min, seconds
    }
end

function _M.read_double(bytes)
   local sign = 1
   local mantissa = bytes[2] % 2^4
   for i = 3, 8 do
     mantissa = mantissa * 256 + bytes[i]
   end
   if bytes[1] > 127 then sign = -1 end
   local exponent = (bytes[1] % 128) * 2^4 + math.floor(bytes[2] / 2^4)

   if exponent == 0 then
     return 0
   end
   mantissa = (math.ldexp(mantissa, -52) + 1) * sign
   return math.ldexp(mantissa, exponent - 1023)
end

function _M.write_double(num)
   local bytes = {0,0,0,0, 0,0,0,0}
   if num == 0 then
     return bytes
   end
   local anum = math.abs(num)

   local mantissa, exponent = math.frexp(anum)
   exponent = exponent - 1
   mantissa = mantissa * 2 - 1
   local sign = num ~= anum and 128 or 0
   exponent = exponent + 1023

   bytes[1] = sign + math.floor(exponent / 2^4)
   mantissa = mantissa * 2^4
   local currentmantissa = math.floor(mantissa)
   mantissa = mantissa - currentmantissa
   bytes[2] = (exponent % 2^4) * 2^4 + currentmantissa
   for i = 3, 8 do
     mantissa = mantissa * 2^8
     currentmantissa = math.floor(mantissa)
     mantissa = mantissa - currentmantissa
     bytes[i] = currentmantissa
   end
   return bytes
 end

-- ngx.say(_M.format_bytes(_M.write_double(0.0)))
-- ngx.say(_M.format_bytes(_M.write_double(0.1)))
-- ngx.say(_M.format_bytes(_M.write_double(0.2)))
-- ngx.say(_M.format_bytes(_M.write_double(1024)))

return _M
