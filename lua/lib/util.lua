local _M = {}

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

return _M
