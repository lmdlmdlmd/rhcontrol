local delay = 30 -- 30 seconds period tasks
local new_timer = ngx.timer.at
local log = ngx.log
local ERR = ngx.ERR
local check
local statemachine = require 'init.statemachine'

check = function(premature)

    local tasks = {
        statemachine
    }
   if not premature then
       for _, f in ipairs(tasks) do
           xpcall(f.run, debug.traceback)
       end
       local ok, err = new_timer(delay, check)
       if not ok then
           log(ERR, "failed to create timer: ", err)
           return
       end
   end
end

if 0 == ngx.worker.id() then
   statemachine.init()
   local ok, err = new_timer(delay, check)
   if not ok then
       log(ERR, "failed to create timer: ", err)
       return
   else
       log(ERR, "let do it")
   end
end

-- 作为总的启动任务，这个地方分别启动另外的定时任务
-- require('./init/init_60seconds')
