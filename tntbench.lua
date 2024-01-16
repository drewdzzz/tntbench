local clock = require('clock')
local json = require('json')
local fiber = require('fiber')
local os = require('os')

fiber.set_max_slice(1e4)
package.path = package.path .. ';./benchmarks/?.lua;'
json.cfg({encode_invalid_as_nil = true})

local counter = 0
local function bump_counter() counter = counter + 1 end

-- Config has a format: Lua-module name and config for it
local cfg = {
    {'select', {tuple_num = 1e6}},
    {'replace', {tuple_num = 1e6}},
    {'replace', {tuple_num = 1e6, on_replace = {bump_counter}}},
    {'replace', {tuple_num = 1e6, on_replace = {bump_counter, bump_counter}}},
    {'replace', {tuple_num = 1e6, on_replace = {bump_counter, bump_counter, bump_counter}}}
}

local ITER_NUM = 5

local function bench_impl(module, cfg)
    local m = require(module)
    local results = {}
    
    for _ = 1, ITER_NUM do
        m.init(cfg)
        local t = clock.bench(m.bench, cfg)[1]
        table.insert(results, t)
        m.free(cfg)
    end

    local avg = 0
    for i = 1, #results do
        avg = avg + results[i]
    end
    avg = avg / #results

    print('>>> Setup: ' .. module .. ' - ' .. json.encode(cfg))
    print('\t' .. avg .. ' seconds')
    if cfg.tuple_num then
        print('\t' .. avg / cfg.tuple_num .. ' seconds per tuple')
        print('\t' .. cfg.tuple_num / avg .. ' RPS')
    end
end

box.cfg{wal_mode='none'}

for _, setup in pairs(cfg) do
    bench_impl(setup[1], setup[2])
end

os.exit()
