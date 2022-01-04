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

cjson.encode_empty_table_as_object(false)
local ret = { code = 0 }

local body_data, _ = process.before()

-- log(DBG, ins(body_data))
-- log(DBG, ins(body_data_str))
local devid = body_data.dev_id
local cmd   = body_data.cmd_code
local data = body_data.body_data
do
    if not devid or not cmd or not body_data then
        ret.code = 100
        ret.msg = 'params are not valid'
        goto exit
    end

    log(DBG, 'auth:', devid)
    local header = bridge.make_header(0x2, devid)
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

    local readdata, err = net.send('222.143.32.246',8001, msg, 60 * 1000)
    -- log(DBG, readdata)
    local tabledata = stringtotable(readdata)
    log(DBG, ins(format_bytes(tabledata)))
    log(DBG, ins(err))
    if tabledata[2] ~= 0x01 then
        ret.code = 102
        ret.msg = 'auth failed'
        goto exit
    end

    log(DBG, 'data')
    header = bridge.make_header(cmd, devid)
    body = bridge.make_body_data_env(data)
    msg = bridge.pack(header, body)
    log(DBG, 'len header=', #header)
    log(DBG, 'body header=', #body)
    log(DBG, format_bytes(msg))

    readdata, err = net.send('222.143.32.246',8001, msg, nil, 1)
    log(DBG, readdata)
    log(DBG, ins(format_bytes(stringtotable(readdata))))
    log(DBG, ins(err))

end

::exit::
--clear resources


process.after(ret)
