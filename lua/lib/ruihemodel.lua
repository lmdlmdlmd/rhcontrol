local _M = {
  hold_names = {
    'MODE',
    'RAHS1',
    'RAHS2',
    'DHST1',
    'H9',
    'H8',
    'FAX',
    'EAX',
    'LDS1',
    'LDS2',
    'WTS1',
    'WTS2',
    'WTS3',
    'STS1',
    'STS2',
  },

  items = {
    MODE = {
      name = '模式'
    }, -- 模式
    RAHS1 = {
      name = '设定除湿湿度'
    }, --设定除湿湿度, 夏季制冷
    RAHS2 = {
      name = '冬季加湿设定湿度'
    }, -- 冬季加湿设定湿度(室内回风湿度的临界值)，冬季加热
    DHST1 = {
      name = '盘管保护设定温度'
    }, -- 盘管保护设定温度，带直棚外机的新风机，除湿工况
    H9 = {
      name = '高风险湿度偏差值'
    }, -- 高风险湿度偏差值，
    H8 = {
      name = '低风险湿度偏差值'
    }, -- 低风险湿度偏差值
    FAX = {
      name = '送风档位'
    }, -- 送风档位
    EAX = {
      name = '排风档位'
    }, -- 排风档位
    LDS1 = {
      name = '回风设定露点值'
    }, -- 回风设定露点值（调试模式下设置）
    LDS2 = {
      name = '送风露点保护设定值'
    }, -- 送风露点保护设定值
    WTS1 = {
      name = '夏季舒适温度',
    }, -- 夏季舒适温度
    WTS2 = {
      name = '冬季舒适温度',
    }, -- 冬季舒适温度
    WTS3 = {
      name = '冬季低温设定温度',
      min = -50,
      max = 50,
    },-- -5, -- 冬季低温设定温度,
    STS1 = {
      name = '夏季毛细管设定温度'
    }, -- 夏季毛细管设定温度
    STS2 = {
      name = '冬季毛细管供水设定温度'
    }, -- 冬季毛细管供水设定温度
  }
}

return _M
