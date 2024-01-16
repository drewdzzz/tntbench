local function init(cfg)
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

    local s = box.schema.create_space('select_bench', cfg.space_opts)
    s:create_index('pk', cfg.index_opts)
    for i, trg in ipairs(cfg.on_replace) do
	s:on_replace(trg, nil, tostring(i))
    end
    for i, trg in ipairs(cfg.before_replace) do
	s:before_replace(trg, nil, tostring(i))
    end
end

local function free(cfg)
    box.space.select_bench:drop()
end

local function bench(cfg)
    local s = box.space.select_bench
    if cfg.in_txn then box.begin() end

    for i = 1, cfg.tuple_num do
        s:replace{i}
    end

    if cfg.in_txn then box.commit() end
end

local m = {}
m.cfg = cfg
m.init = init
m.free = free
m.bench = bench

return m