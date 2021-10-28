local net =  require 'lib.net'
local ds    = require "lib.ds"

local send = net.send
local spawn = ngx.thread.spawn
local wait = ngx.thread.wait
local format = string.format
local ngx_re = require "ngx.re"
local split = ngx_re.split

local log = ngx.log
local ERR = ngx.ERR
-- local DBG = ngx.DEBUG
local ins = require 'lib.inspect'

local _M = {
    devs = {}
}

_M.register = function(host, port, obj, name, maxsize)
    local devs = _M.devs
    if not obj or not host or not port then
        return nil
    end
    devs[#devs + 1] = {
      host = host,
      port = port,
      obj  = obj,
      name = name,
      maxsize = maxsize
    }
    return #devs
end

_M.get = function(name)
    local devs = _M.devs
    if not name then return nil end
    for _, v in ipairs(devs) do
        if v.name == name then
            return v.obj
        end
    end
    return
end

local stringtotable = function(str)
    local list = split(str, '')
    local ret = {}
    for _, v in ipairs(list) do
        ret[#ret + 1] = string.byte(v)
    end
    return ret
end
_M.read = function()
    local devs = _M.devs
    local tasks = {}
    for _, v in ipairs(devs) do
        local obj = v.obj
        local senddata = obj:get_read_cmd()
        -- log(DBG, format('host=%s port=%s send=%s', v.host, v.port, #senddata))
        local t = spawn(send, v.host, v.port, senddata, v.maxsize)
        tasks[#tasks + 1] = t
    end
    for i = 1, #tasks do
        local ok, res = wait(tasks[i])
        if not ok then
            log(ERR, format('host=%s port=%s fail=%s', devs[i].host, devs[i].port, res))
        else
            local obj = devs[i].obj
            if res then
                res = stringtotable(res)
                obj:set_data(res)
                log(ERR, ins(res))
            else
                obj:fail(ds.DEV_HEALTH_SICK)
                log(ERR, 'received is nil')
            end
        end
    end
end


return _M
