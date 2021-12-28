local net =  require 'lib.net'
local util    = require "lib.util"
local helprd  = require "lib.helpredis"

local send = net.send
local spawn = ngx.thread.spawn
local wait = ngx.thread.wait
local format = string.format
local stringtotable = util.stringtotable
local format_bytes = util.format_bytes

local log = ngx.log
local ERR = ngx.ERR
-- local DBG = ngx.DEBUG
-- local ins = require 'lib.inspect'

local _M = {
    queue = {}
}

_M.register = function(task, dev, index, func)
    if task and func
      and type(task) == 'string'
      and type(func) == 'function' then
        local queue = _M.queue
        queue[#queue + 1] = {
            name = task,
            obj = dev,
            func = func,
            index = index
        }
        return #queue
    end

    return nil
end


_M.write = function()
    local redis = helprd.get()
    if not redis then
        return nil
    end
    local tasks = {}
    local queue = _M.queue
    for i, v in ipairs(queue) do
        local val = redis:rpop(v.name)
        local obj = v.obj
        if val == nil then
            -- log(ERR, v.name, ' val is null')
            goto continuewrite
        end
        -- log(ERR, '**************')
        -- log(ERR, v.name, ':', val)
        -- log(ERR, ins(v.func))
        local senddata = v.func()(obj, v.index, val)
        -- log(ERR, format_bytes(senddata))
        if senddata then
            local host = obj:get_host()
            local port = obj:get_port()
            local t = spawn(send, host, port, senddata)
            tasks[#tasks + 1 ] = {
                index = i,
                val = val,
                t = t,
            }
        end

        ::continuewrite::
    end

    for _, v in ipairs(tasks) do
        local t = v.t
        local index = v.index
        local obj = queue[index].obj
        local name = queue[index].name
        local ok, res = wait(t)
        if not ok then
            -- 可以把操作重新插入对象
            log(ERR, format('host=%s port=%s send fail=%s', obj:host(), obj:port(), res))
        else
            local d = stringtotable(res)
            -- log(ERR, 'name=', name, '==', format_bytes(d))
        end
    end
end

return _M
