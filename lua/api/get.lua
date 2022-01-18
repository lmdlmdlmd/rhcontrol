local process = require "lib.process"
local Ruihe   = require "dev.ruihe"
local Newfan  = require "dev.newfan"
local Ate = require 'dev.ate'
local Aircond = require "dev.aircond"

local ret = { code = 1 }

do
    local fan1 = Newfan.new(0x1)
    fan1:unserialization()
    local fan1_data = fan1:input_hold()
    ret.fan = fan1_data

    local air1 = Aircond.new(0x1)
    air1:unserialization()
    local air1_data = air1:input_hold()
    ret.air = air1_data

    Ruihe.unserialization()
    ret.ruihe = Ruihe.input_hold()

    local ate1 = Ate.new(0xf)
    ate1:unserialization()
    ret.ate = {
        humi = ate1:get_humi(),
        temp = ate1:get_temp(),
        pm25 = ate1:get_pm25(),
    }

    ret.code = 0

end


process.after(ret)
