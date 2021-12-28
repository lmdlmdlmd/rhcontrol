local _M = {}
local ngx_re = require "ngx.re"
local isarray    = require 'table.isarray'
local split = ngx_re.split
local format = string.format

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
return _M
