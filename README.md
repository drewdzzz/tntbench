# tntbench

## How to launch

Launch from this directory:
```sh
/path/to/tarantool tntbench.lua
```

## How to extend

All benchmark suites are Lua modules stored in `benchmark` directory. Each module is expected to have 3 methods: `init`, `bench` and `free`. Method `init` is called before every `bench` call, and `free` is called after.

Table `cfg`, defined in `tntbench.lua` is an array of benchmark suites. After each suit a report is printed. Each report header contains suite name and its config serialized in json (all unsupported types, such as function, are serialized as `null`).
