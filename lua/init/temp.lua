local _M = {}
local l = require 'lib.log'
local Fan = require 'lib.fan'
local Air = require 'lib.air'
local ds  = require 'lib.ds'

local ONE_DEGREE = 1
local THREE_DEGREE  = 3 * ONE_DEGREE

local log = ngx.log
local ERR = ngx.ERR
local DBG = ngx.DEBUG

_M.heat = function(mode, redis, p_ruihe, p_fan, p_air)
    log(DBG, 'enter into heat:', mode)
    local rat1 = p_fan:get(Fan.INPUT_ADDR_RAT1) -- 室内回风温度
    -- local fat1 = p_fan:get(Fan.INPUT_ADDR_FAT1) -- 新风温度（室外）
    local st1 = p_air:get(Air.INPUT_ADDR_ST1) -- 二次水温
    local wts2 = p_ruihe.get('WTS2') --  冬季舒适温度
    local sts2 = p_ruihe.get('STS2') -- 冬季毛细管供水设定温度

    if not rat1 or not st1 or not wts2 or not sts2 then
        l.log('SOMETHING WRONG IN HEAR, NO VALID VALUE')
        return
    end

    -- if home temp is small then wts2 then heat
    -- if fat1 < wts2 then
        -- 温控器开启制热模式
        -- 每个房间都有一个温控器面板
        -- 现在房间没有?????????
    -- end

    local MC1K -- 空调水机组主机1
    local MC3K --空调水机组主机3, 可能不存在， 和mc2不一样
    local HMV  -- 辅助加热
    local SPK1 -- 二次水泵1
    local SPK2 -- 二次水泵2
    if st1 <= sts2 - THREE_DEGREE then
        MC3K = 1
        HMV = 1
    elseif st1 >= sts2 - ONE_DEGREE then
        MC3K = 0
    elseif st1 >= sts2 then
        MC3K = 0
        HMV = 0
    else -- luacheck: ignore
        --- ???????
    end

    if st1 <= sts2 then
        MC1K = 1
        -- 开启二次水泵
        SPK1 = 1
        SPK2 = 1
    else
        MC1K = 0
    end

    if rat1 > wts2 then
        -- 关闭热源主机
        MC1K = 0
        MC3K = 0
        HMV = 0
    end

    if MC1K then
        p_air:set(redis, Air.HOLD_ADDR_MC1K, MC1K)
    end
    if MC3K then
        p_air:set(redis, Air.HOLD_ADDR_MC3K, MC3K)
    end
    if HMV then
        p_air:set(redis, Air.HOLD_ADDR_HMV, HMV)
    end
    if SPK1 then
        p_air:set(redis, Air.HOLD_ADDR_SPK1, SPK1)
    end
    if SPK2 then
        p_air:set(redis, Air.HOLD_ADDR_SPK2, SPK2)
    end
end

_M.cool = function(mode, redis, p_ruihe, _, p_air)
    log(DBG, 'enter into cool:', mode)
    local sts1 = p_ruihe.get('STS1') -- 夏季毛细管设定温度
    local st1 = p_air:get(Air.INPUT_ADDR_ST1) -- 二次水温

    local MC1K
    local MC3K
    local CMV -- 毛细管制冷水阀
    if st1 > sts1 + ONE_DEGREE then
        CMV = 1
        MC1K = 1
        MC3K = 1
    elseif st1 >= sts1 then
        CMV = 1
        MC1K = 1
        MC3K = 0
    elseif st1 < sts1 - ONE_DEGREE then
        CMV = 0
    else
        MC1K = 0
        MC3K = 0
    end

    if MC1K then
        p_air:set(redis, Air.HOLD_ADDR_MC1K, MC1K)
    end
    if MC3K then
        p_air:set(redis, Air.HOLD_ADDR_MC3K, MC3K)
    end
    if CMV then
        p_air:set(redis, Air.HOLD_ADDR_HMV, CMV)
    end
end

_M.pump = function(mode, redis, p_ruihe, p_fan, p_air)
    l.log('enter into pump:', mode)
    local ld1 = p_fan:get_ld1()
    local sts1 = p_ruihe.get('STS1')
    -- 二次水泵1 运行状态 默认为, 未启动:1; 已启动，读出:0
    local spr1 = p_air:get(Air.INPUT_ADDR_SPR1)
    -- 二次水泵2 运行状态 默认为, 未启动:1; 已启动，读出:0
    local spr2 = p_air:get(Air.INPUT_ADDR_SPR2)
    -- 二次水泵1 故障状态 默认为，正常:1; 0 代表故障
    local spe1 = p_air:get(Air.INPUT_ADDR_SPE1)
    -- 二次水泵2 故障状态 默认为，正常:1; 0 代表故障
    local spe2 = p_air:get(Air.INPUT_ADDR_SPE2)

    local SPK1 -- 二次水泵1  启停控制
    local SPK2 -- 二次水泵2  启停控制
    if ld1 < sts1 then
        if spr1 == 1 then
            SPK1 = 1
        end
        if spr2 == 1 then
            SPK2 = 1
        end

        if spe1 == 0 then
            p_ruihe.set_alarm(ds.ALARM_SPE1)
        else
            p_ruihe.clear_alarm(ds.ALARM_SPE1)
        end

        if spe2 == 0 then
            p_ruihe.set_alarm(ds.ALARM_SPE2)
        else
            p_ruihe.clear_alarm(ds.ALARM_SPE2)
        end
    else
        -- 输出系统凝露风险不能开启二次泵,
        -- 只有这种情况关闭???????
        SPK1 = 0
        SPK2 = 0
    end

    if SPK1 then
        p_air:set(redis, Air.HOLD_ADDR_SPK1, SPK1)
    end
    if SPK2 then
        p_air:set(redis, Air.HOLD_ADDR_SPK2, SPK2)
    end
end

return _M
