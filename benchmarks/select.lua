local function init(_self, cfg)
    if cfg.tuple_num == nil then
        error('tuple_num is required')
    end
    if cfg.tuple_size == nil then
	cfg.tuple_size = 1
    end
    if cfg.space_opts == nil then
        cfg.index_opts = {}
    end
    if cfg.index_opts == nil then
        cfg.index_opts = {}
    end

    local s = box.schema.create_space('select_bench', cfg.space_opts)
    s:create_index('pk', cfg.index_opts)
    for i = 1, cfg.tuple_num do
        local t = {}
        for j = 1, cfg.tuple_size do
            table.insert(t, i)
        end
        s:replace(t)
    end
end

local function free(_self, cfg)
    box.space.select_bench:drop()
end

local function bench(_self, cfg)
    local s = box.space.select_bench
    for i = 1, cfg.tuple_num do
        s:select(i)
    end
end

local m = {}
m.init = init
m.free = free
m.bench = bench

return m