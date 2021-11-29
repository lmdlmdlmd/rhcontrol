local _M = {}
local l = require 'lib.log'
local Fan = require 'lib.fan'
local ds  = require 'lib.ds'

-- ??????? when to stop xin wind
-- 什么情况下停止新风? 现在依据的时候配置层面做的事情
_M.letin = function(mode, redis, p_ruihe, p_fan)
    l.log('enter into heat:', mode)
    local far = p_fan:get(Fan.INPUT_ADDR_FAR)
    local fae = p_fan:get(Fan.INPUT_ADDR_FAE)
    local fax = p_ruihe.get('FAX') -- 送风档位
    local eax = p_ruihe.get('EAX') -- 排风档位

    local fat1 = p_fan:get(Fan.INPUT_ADDR_FAT1) --新风温度（室外)
    local wts3 = p_ruihe.get('WTS3') -- 冬季低温设定温度

    if far == 0 then
        if fae == 1 then
            p_ruihe.set_alarm(ds.ALARM_FAN)
        else
            p_ruihe.clear_alarm(ds.ALARM_FAN)
        end
    end

    -- FAK = 1 if fak > 0 else 0
    p_fan:set(redis, Fan.HOLD_ADDR_FAK, (fax > 0 and 1) or 0)
    --set fax to fax
    p_fan:set(redis, Fan.HOLD_ADDR_FAX, fax)

    -- EAK = 1 if eax > 0 else 0
    p_fan:set(redis, Fan.HOLD_ADDR_EAK, (eax > 0 and 1) or 0)
    -- set eax to eax, maybe zero or others
    p_fan:set(redis, Fan.HOLD_ADDR_EAX, eax)

    local FAV -- 新风风阀
    if fat1 < wts3 then
        FAV = 0
    else
        if fax > 0 or eax > 0 then
            FAV = 1
        else
            FAV = 0
        end
    end
    p_fan:set(redis, Fan.HOLD_ADDR_FAV, FAV)

    --??????
    -- EA0 & EAK 排风的逻辑是什么？手动，自动？
    -- FAK & FAO 送风的逻辑是什么？手动，自动？
end



-- 过滤网堵塞报警
-- If  XLW1=1（初效过滤网压差开关开启）  then
--     报警提示XLW1堵塞
-- If  XLW2=1（高效过滤网压差开关开启）  then
--     报警提示XLW2堵塞
_M.is_xlw = function( p_ruihe, p_fan)
    local xlw1 = p_fan:get(Fan.INPUT_ADDR_XLW1)
    local xlw2 = p_fan:get(Fan.INPUT_ADDR_XLW1)

    if xlw1 then
        p_ruihe.set_alarm(ds.ALARM_XLW1)
    else
        p_ruihe.clear_alarm(ds.ALARM_XLW1)
    end
    if xlw2 then
        p_ruihe.set_alarm(ds.ALARM_XLW2)
    else
        p_ruihe.clear_alarm(ds.ALARM_XLW2)
    end
end



return _M
