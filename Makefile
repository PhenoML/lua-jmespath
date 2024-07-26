test: build
	busted

build:
	luarocks make rockspecs/lua-jmespath-0.1-0.rockspec > /dev/null

perf: build
	@if [ -n "$$JIT" ]; then luajit bin/perf.lua; else lua bin/perf.lua; fi

test-setup:
	luarocks install busted
	luarocks install luafilesystem

test-script: build
	lua ./tester.lua

.PHONY: build
