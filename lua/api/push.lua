local cjson     = require "cjson.safe"
local process   = require "lib.process"
local bridge = require 'dev.bridge'
local util = require 'lib.util'
local net  = require 'lib.net'
local devids = require 'dev.devids'

local log  = ngx.log
-- local ERR  = ngx.ERR
local DBG = ngx.DEBUG
local ins = require 'lib.inspect'
local format_bytes = util.format_bytes
local stringtotable = util.stringtotable
local tabletostring = util.tabletostring

cjson.encode_empty_table_as_object(false)
local ret = { code = 0 }

local body_data, body_text = process.before()
local host = '222.143.32.246'
local port = '8001'

-- log(DBG, ins(body_data))
-- log(DBG, ins(body_data_str))

do
    if not body_data then
        ret.code = 200
        ret.msg = 'not a json param'
        ret.txt = body_text
        goto exit
    end
    local devid = body_data.dev_id
    local cmd   = body_data.cmd_code
    local data = body_data.body_data
    local ts   = body_data.ts

    if not devid or not cmd or not body_data then
        ret.code = 100
        ret.msg = 'params are not valid'
        if not body_data then
            ret.msg = ret.msg .. ' not body_data'
        end
        if not devid then
            ret.msg = ret.msg .. ' not devid'
        end
        if not cmd then
            ret.msg = ret.msg .. ' not cmd'
        end
        goto exit
    end

    log(DBG, 'auth:', devid)
    local header = bridge.make_header(0x2, devid, ts)
    local authcode = devids[devid]
    if not authcode then
        ret.code = 101
        ret.msg = 'devid is not register'
        goto exit
    end
    local body = bridge.make_body_auth(authcode)

    local msg = bridge.pack(header, body)
    log(DBG, 'len header=', #header)
    log(DBG, 'body header=', #body)
    log(DBG, 'body authcode=', authcode)
    log(DBG, format_bytes(msg))

    local timeout = 60 * 1000
    local sock = ngx.socket.tcp()
    sock:settimeouts(timeout,timeout, timeout)
    local maxreadsize = 1024000
    local ok, err = sock:connect(host, port)
    if not ok then
        ret.code = 201
        ret.msg = 'connect failed:' .. err
        goto exit
    end
    -- ngx.say('connect ok')

    local _, err = sock:send(tabletostring(msg))
    if err then
        ret.code = 202
        ret.msg = 'send failed:' .. ins(err)
        goto exit
    end
    -- ngx.say('send ok')

    local readdata, err = sock:receiveany(maxreadsize) -- received most 1k data
    if not readdata then
        ret.code = 203
        ret.msg = 'auth receiveany failed:' .. err
        goto exit
    end

    local tabledata = stringtotable(readdata)
    log(DBG, ins(format_bytes(tabledata)))
    log(DBG, ins(err))
    if not err then
        if tabledata[2] ~= 0x01 then
            ret.code = 102
            ret.msg = 'auth failed: ' .. tabledata[2] or ''
            goto exit
        end
    end

    log(DBG, 'data')
    header = bridge.make_header(cmd, devid, ts)
    body, err = bridge.make_body_data_env(data)
    if not body then
        ret.code = 104
        ret.msg = err
        goto exit
    end
    msg = bridge.pack(header, body)
    log(DBG, 'len header=', #header)
    log(DBG, 'body header=', #body)
    log(DBG, format_bytes(msg))

    local _, err = sock:send(tabletostring(msg))
    if err then
        ret.code = 302
        ret.msg = 'send failed:' .. ins(err)
        goto exit
    end
    sock:settimeouts(timeout,timeout, 50)
    local readdata, err = sock:receiveany(maxreadsize) -- received most 1k data
    -- if not readdata then
    --     ret.code = 203
    --     ret.msg = 'receiveany failed:' .. ins(err)
    --     goto exit
    -- end
    if not err then
      log(DBG, readdata)
      tabledata = stringtotable(readdata)
      log(DBG, ins(format_bytes(tabledata)))
      if tabledata[2] ~= 0x01 then
          ret.code = 108
          ret.msg = 'rece data failed: ' .. tabledata[2] or ''
          goto exit
      end
    else
        log(DBG, ins(err))
    end

    local ok, err = sock:close()
    if not ok then
        log(DBG, 'close sock failed', err)
    end
end

::exit::
--clear resources


process.after(ret)
