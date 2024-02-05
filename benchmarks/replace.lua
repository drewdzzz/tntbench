local has_trigger_names = string.sub(box.info.version, 1, 1) == '3'

local function init(_self, cfg)
    if cfg.tuple_num == nil then
        error('tuple_num is required')
    end
    if cfg.space_opts == nil then
        cfg.index_opts = {}
    end
    if cfg.index_opts == nil then
        cfg.index_opts = {}
    end
    if cfg.on_replace == nil then
	cfg.on_replace = {}
    end
    if cfg.before_replace == nil then
	cfg.before_replace = {}
    end
    if cfg.in_txn == nil then
	cfg.in_txn = false
    end

    local s = box.schema.create_space('replace_bench', cfg.space_opts)
    s:create_index('pk', cfg.index_opts)
    local name = nil
    for i, trg in ipairs(cfg.on_replace) do
        if has_trigger_names then
            s:on_replace(trg, nil, tostring(i))
        else
            s:on_replace(trg, nil)
        end
    end
    for i, trg in ipairs(cfg.before_replace) do
        if has_trigger_names then
            s:before_replace(trg, nil, tostring(i))
        else
            s:before_replace(trg, nil)
        end
    end
end

local function free(_self, cfg)
    box.space.replace_bench:drop()
end

local function bench(_self, cfg)
    local s = box.space.replace_bench
    if cfg.in_txn then box.begin() end

    for i = 1, cfg.tuple_num do
        s:replace{i}
    end

    if cfg.in_txn then box.commit() end
end

local m = {}
m.init = init
m.free = free
m.bench = bench

return m