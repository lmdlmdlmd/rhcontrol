local _M = {}
local l = require 'lib.log'
local Fan = require 'lib.fan'
local Air = require 'lib.air'
local ds = require 'lib.ds'

-- 加湿
-- 把水加入到空气， 水打开，加热加水（空调加热）
_M.add = function(mode, redis, p_ruihe, p_fan, p_air)
  l.log('enter into add:', mode)
  local rah1 = p_fan:get(Fan.INPUT_ADDR_RAH1) --室内回风湿度
  local ld2 = p_fan:get_ld2() -- 送风露点,送风温度和湿度计算出来的数值
  local lds2 = p_ruihe.get('LDS2') -- 送风露点保护设定值
  local rahs2 = p_ruihe.get('RAHS2') --冬季加湿设定湿度(室内回风湿度的临界值)

  -- 这个地方与wind新风处理的时候可能会冲突，移动到新风处理
  -- if fat1 < wts3 then
      -- FAV = 0
      -- p_fan:set(redis, Fan.HOLD_ADDR_FAV, 0)
  -- end

  local JSK -- 加湿水阀
  local MC1K -- 空调水机组主机1
  local MC2K -- 空调水机组主机2
  if ld2 < lds2 and rah1 < rahs2 then
      JSK = 1
      if p_air:has_mc2() then
          MC2K = 1
      else
          MC1K = 1
      end
  end

  -- 秋季加湿, param is different
  -- if ld2 < lds2 and rah1 < rahs2 * 0.95 then
  --     JSK = 1
  --     -- MC1K = 1，不一定打开；如果偏差很大，可能需要打开 ***
  -- end

  -- 湿度是百分数 1-100%
  if ld2 >= lds2 or rah1 > (rahs2 + 0.03) then
      JSK = 0
      -- MC1K 另外的东西来决定是否关闭，这个地方不能完全决定关闭
      -- 秋季加湿不用打开空调
  end

  if JSK then
      p_fan:set(redis, Fan.HOLD_ADDR_JSK, JSK)
  end
  if MC1K then
      p_air:set(redis, Air.HOLD_ADDR_MC1K, MC1K)
  end
  if MC2K then
      p_air:set(redis, Air.HOLD_ADDR_MC2K, MC2K)
  end
end

-- 除湿
_M.minus = function(mode, redis, p_ruihe, p_fan, p_air)
    l.log('enter into minus:', mode)
    local rah1 = p_fan:get(Fan.INPUT_ADDR_RAH1) -- 室内回风湿度
    local rahs1 = p_ruihe.get('RAHS1') -- 设定除湿湿度
    local h9 = p_ruihe.get('H9') -- 高风险湿度偏差值
    local h8 = p_ruihe.get('H8') -- 低风险湿度偏差值
    local dht1 = p_fan:get(Fan.INPUT_ADDR_DHT1)  --盘管温度
    local dhst1 = p_ruihe.get('DHST1') -- 盘管保护设定温度

    local DWK  --新风直膨主机, 可能没有
    local MC1K --空调水机组主机1
    local MC2K --空调水机组主机2，可能也没有
    local DHV  --冷水阀	新风表冷水阀， **可能没有**
    local FAV  --新风风阀
    local diff = rah1 - rahs1
    -- 回风湿度高于设定湿度RAHS1
    if diff > 0 then
        -- 顺序开，DWK -> MC2K -> MC1K
        -- 判断硬件决定开 dwk+mc1, mc1, mc1+mc2
        -- 谁提供冷源
        if p_fan:has_dwk() then
            DWK = 1
            if diff > h9 then
                -- 开启冷水阀
                DHV = 1 -- MC1搞出来的
            end
        else
            if p_air:has_mc2() then
                MC2K = 1
                -- MC2切换到制冷模式 这个操作还未实现，通过空调的master设置命令
                p_air:set_mc2(ds.COLD_MODE)
            else
                MC1K = 1
                -- MC1切换到制冷模式 这个操作还没实现，通过空调的master设置命令
                p_air:set_mc1(ds.COLD_MODE)
            end
        end
    else
        -- 回风湿度继续降低到正常水平
        -- 关闭除湿主机
        -- 其实是关闭新风外机
        MC2K = 0 -- 先关
        MC1K = 0 -- 然后关
        DWK = 0 -- 然后关
    end

    if diff > h9 then
        -- 关闭新风风阀，湿度过大
        FAV = 0
    elseif diff < h8 and diff > 0 then
        -- 打开新风风阀
        FAV = 1
    end

    if dht1 < dhst1 then
        if p_fan:has_dwk() then
            DWK = 0
            DHV = 0
        end
    end

    if DWK then
        p_fan:set(redis, Fan.HOLD_ADDR_DWK, DWK)
    end
    if MC1K then
        p_air:set(redis, Air.HOLD_ADDR_MC1K, MC1K)
    end
    if MC2K then
        p_air:set(redis, Air.HOLD_ADDR_MC2K, MC2K)
    end
    if DHV then
        p_fan:set(redis, Fan.HOLD_ADDR_DHV, DHV)
    end
    if FAV then
        p_fan:set(redis, Fan.HOLD_ADDR_FAV, FAV)
    end
end

return _M
