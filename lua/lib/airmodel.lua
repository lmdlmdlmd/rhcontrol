-- local util = require 'lib.util'
-- local ds   = require 'lib.ds'

local _M = {
  VER = {
    name = '版本'
  },
  SPR1 = {
    name = '二次水泵1运行状态',
  }, --二次水泵1  运行状态 默认为, 未启动:1; 已启动，读出:0
  SPE1 = {
    name = '二次水泵1故障状态',
  }, --二次水泵1  故障状态 默认为，正常:1; 0 代表故障
  SPR2 = {
    name = '二次水泵2运行状态'
  }, --二次水泵2  运行状态
  SPE2 = {
    name = '二次水泵2故障状态'
  }, --二次水泵2  故障状态
  HPE  = {
    name = '热水循环故障状态'
  }, --热水循环  水泵故障状态
  -- HW_ID2=0，HWID1=0，“不共用主机”
  -- HW_ID2=0，HWID1=1，“共用MC1”
  -- HW_ID2=1，HWID1=0，“共用MC2”
  -- HW_ID2=1，HWID1=1，“错误码”
  HWID1 = {
    name = 'HWID1'
  },
  HWID2 = {
    name = 'HWID2'
  },
  ST1 = {
    name = '二次水温'
  }, -- 二次水温
  HT1 = {
    name = '热水循环温度'
  }, -- 热水循环  温度
  HEALTH = {
    name = '健康状态',
  },
  HEARTBEAT = {
    name = '心跳'
  },

  TEST = {
    name = '测试',
  },
  SPO1 = {
    name = '二次水泵1手动/自动'
  }, -- 二次水泵1  手动/自动, debug用
  SPK1 = {
    name = '二次水泵1启停控制',
  }, -- 二次水泵1  启停控制
  SPO2 = {
    name = '二次水泵2手动/自动'
  }, -- 二次水泵2  手动/自动
  SPK2 = {
    name = '二次水泵2启停控制'
  }, -- 二次水泵2  启停控制
  MC1K = {
    name = '空调水机组主机1',
  }, -- 空调水机组主机 1
  MC2K = {
    name = '空调水机组主机2'
  }, -- 空调水机组主机 2
  CMV  = {
    name = '毛细管制冷水阀'
  }, -- 毛细管制冷水阀
  HMV  = {
    name = '辅助制热'
  }, -- 辅助制热
  HPK  = {
    name = '热水循环启停控制'
  }, -- 热水循环  启停控制
  HPO  = {
    name = '热水循环手动/自动'
  }, -- 热水循环  手动/自动
  HBK  = {
    name = '锅炉启停'
  }, -- 锅炉启停
  -- 两个继电器构成组合开关。
  -- PF1=0，PF1K=0，代表“关机”
  -- PF1=0，PF1K=1，代表“低档”
  -- PF1=1，PF1K=0，代表“高档”
  PF1  = {
    name = '排风扇1'
  }, -- 排风扇1高低档位控制
  PF1K = {
    name = '排风扇1'
  }, -- 排风扇1 风机开关
  -- 两个继电器构成组合开关。
  -- PF2=0，PF2K=0，代表“关机”
  -- PF2=0，PF2K=1，代表“低档”
  -- PF2=1，PF2K=0，代表“高档”
  PF2  = {
    name = '排风扇2'
  },
  PF2K = {
    name = '排风扇2'
  },
  --   两个继电器构成组合开关。
  -- PF3=0，PF3K=0，代表“关机”。
  -- PF3=0，PF3K=1，代表“低档”。
  -- PF3=1，PF3K=0，代表“高档”
  PF3  = {
    name = '排风扇3'
  },
  PF3K = {
    name = '排风扇3'
  },

  MC3K = {
    name = '空调水机组主机3'
  }, -- 空调水机组主机 3, 可能不存在

  MODE = {
    name = '模式'
  },
  SYNC = {
    name = '同步'
  }
}



return _M
