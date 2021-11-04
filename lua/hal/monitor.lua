local net =  require 'lib.net'
local ds    = require "lib.ds"
local util  = require "lib.util"

local send = net.send
local spawn = ngx.thread.spawn
local wait = ngx.thread.wait
local format = string.format
local stringtotable = util.stringtotable
-- local format_bytes = util.format_bytes

local log = ngx.log
local ERR = ngx.ERR
-- local DBG = ngx.DEBUG
-- local ins = require 'lib.inspect'

local _M = {
    devs = {}
}

_M.register = function(obj, name, maxsize)
    local devs = _M.devs
    if not obj or not name then
        return nil
    end
    devs[#devs + 1] = {
      obj  = obj,
      name = name,
      maxsize = maxsize
    }
    return #devs
end

_M.get_dev = function(name)
    local devs = _M.devs
    if not name then return nil end
    for _, v in ipairs(devs) do
        if v.name == name then
            return v
        end
    end
    return nil
end

_M.get = function(name)
    local dev = _M.get_dev(name)
    if dev then return dev.obj end
    return nil
end

_M.read_input = function()
    local devs = _M.devs
    local tasks = {}
    for i, v in ipairs(devs) do
        local obj = v.obj
        local senddata = obj:get_read_cmd()
        -- log(ERR, util.format_bytes(senddata))
        if senddata then
            local host = obj:get_host()
            local port = obj:get_port()
            -- log(ERR, host,':', port)
            -- log(ERR, ins(senddata))
            local t = spawn(send, host, port, senddata, v.maxsize)
            tasks[#tasks + 1] = {
                index = i,
                t = t
            }
        end
    end

    for _, v in ipairs(tasks) do
        local t = v.t
        local index = v.index
        local obj = devs[index].obj
        local ok, res = wait(t)
        if not ok then
            log(ERR, format('host=%s port=%s fail=%s', obj:host(), obj:port(), res))
        else
            if res then
                res = stringtotable(res)
                obj:set_data(res)
                -- log(ERR, ins(res))
            else
                obj:fail(ds.DEV_HEALTH_SICK)
                log(ERR, 'received is nil')
            end
        end
    end
end

_M.read_hold = function()
    local devs = _M.devs
    local tasks = {}
    for i, v in ipairs(devs) do
        local obj = v.obj
        if not obj.get_hold_cmd then
            goto continereadhold
        end
        local senddata = obj:get_hold_cmd()
        -- log(ERR, util.format_bytes(senddata))
        if senddata then
            local host = obj:get_host()
            local port = obj:get_port()
            -- log(ERR, host,':', port)
            -- log(ERR, ins(senddata))
            local t = spawn(send, host, port, senddata, v.maxsize)
            tasks[#tasks + 1] = { index = i, t = t }
        end
        ::continereadhold::
    end

    for _, v in ipairs(tasks) do
        local t = v.t
        local index = v.index
        local obj = devs[index].obj
        local ok, res = wait(t)
        if not ok then
            log(ERR, format('host=%s port=%s fail=%s', obj:host(), obj:port(), res))
        else
            if res then
                res = stringtotable(res)
                obj:set_data(res, 0, 'hold')
                -- log(ERR, ins(res))
            else
                obj:fail(ds.DEV_HEALTH_SICK)
                log(ERR, 'received is nil')
            end
        end
    end
end

return _M
