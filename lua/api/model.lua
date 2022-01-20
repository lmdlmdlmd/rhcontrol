local process = require "lib.process"
local Air = require "lib.air"
local Fan = require "lib.fan"
local util = require "lib.util"
local AirModel = require "lib.airmodel"
local FanModel = require "lib.fanmodel"
local RuiheModel = require "lib.ruihemodel"

local get_model = util.get_model

local ret = { code = 1 }

do

    local status = {}
    local settings = {}
    for _, v in ipairs(Air.input_names) do
        status[#status + 1] = get_model(v, AirModel[v], nil)
    end
    for _, v in ipairs(Air.hold_names) do
        settings[#settings + 1] = get_model(v, AirModel[v], nil)
    end

    ret.air = {
        status = status,
        settings = settings
    }

    local fstatus = {}
    local fsettings = {}
    for _, v in ipairs(Fan.input_names) do
        fstatus[#fstatus + 1] = get_model(v, FanModel[v], nil)
    end
    for _, v in ipairs(Fan.hold_names) do
        fsettings[#fsettings + 1] = get_model(v, FanModel[v], nil)
    end
    ret.fan = {
        status = fstatus,
        settings = fsettings
    }

    local rhsettings = {}
    for _, v in ipairs(RuiheModel.hold_names) do
        rhsettings[#rhsettings + 1] = get_model(v, RuiheModel['items'][v], nil)
    end
    ret.ruihe = {
        settings = rhsettings
    }

    ret.code = 0

end


process.after(ret)
