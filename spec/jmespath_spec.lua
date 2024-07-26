local jmespath = require "lua_jmespath"

describe('jmespath', function()
  it("returns a result", function()
    assert.are.equal("foo", jmespath:search({a={b="foo"}}, "a.b"))
  end)
end)
