test: build
	busted --lua=luajit

build:
	luarocks --lua-version 5.1 make rockspecs/lua-jmespath-0.1-2.rockspec > /dev/null

perf: build
	@if [ -n "$$JIT" ]; then luajit bin/perf.lua; else lua bin/perf.lua; fi

test-setup:
	luarocks --lua-version 5.1 install busted
	luarocks --lua-version 5.1 install luafilesystem

test-script: build
	luajit ./tester.lua

.PHONY: build
