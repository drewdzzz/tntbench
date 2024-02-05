local has_trigger_names = string.sub(box.info.version, 1, 1) == '3'
local trigger = require('trigger')

local function bench_commit(_self, cfg)
    box.commit()
end

local function bench_rollback(_self, cfg)
    box.rollback()
end

local function init(self, cfg)
    if cfg.tuple_num == nil then
        error('tuple_num is required')
    end
    if cfg.trigger_type == nil then
        error('trigger_type is required')
    end
    if cfg.trigger_type ~= 'on_commit' and
       cfg.trigger_type ~= 'before_commit' and
       cfg.trigger_type ~= 'on_rollback' then
        error('undefined txn trigger type')
    end
    if not has_trigger_names then
        error('benchmark requires new triggers')
    end

    if cfg.trigger_type == 'on_rollback' then
        self.bench = bench_rollback
    else
        self.bench = bench_commit
    end

    local s = box.schema.create_space('txn_triggers_bench')
    s:create_index('pk')

    local event = 'box.' .. cfg.trigger_type
    for i, f in pairs(cfg.triggers) do
        trigger.set(event, 'txn_trigger_bench.' .. tostring(i), f)
    end

    box.begin()
    for i = 1, cfg.tuple_num do
        s:replace{i}
    end
end

local function free(_self, cfg)
    local event = 'box.' .. cfg.trigger_type
    for i, _ in pairs(cfg.triggers) do
        trigger.del(event, 'txn_trigger_bench.' .. tostring(i))
    end
    box.space.txn_triggers_bench:drop()
end

local m = {}
m.init = init
m.free = free

return m