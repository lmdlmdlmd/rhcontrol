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

_M.emptytable = function(list, len)
    for _ = 1, 1, len do
        list[#list + 1 ] = 0
    end
    return list
end

_M.index = function(list, val)
    if not list or not val then
        return nil
    end

    -- start with zero
    for i, v in ipairs(list) do
        if v == val then
            return i - 1
        end
    end

    return nil
end

_M.get_model = function(key, item, val)
    if not key or not item then
        return nil
    end
    local newitem = {
        modelName = key,
        type = 'num'
    }
    if val then
        newitem.value = val
    end
    if item['name'] then
        newitem['inputLabel'] = item['name']
    end
    if item['type'] then
        newitem['type'] = item['type']
    end
    if newitem['type'] == 'num' then
        newitem['min'] = item['min'] or 0
        newitem['max'] = item['max'] or 1000
    end
    newitem['extra'] = item['extra']

    return newitem
end

return _M
