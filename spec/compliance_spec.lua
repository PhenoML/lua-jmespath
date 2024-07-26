local jmespath = require 'lua_jmespath'
local lfs = require 'lfs'
local _json = require 'cjson'
local say = require("say")
--_json.decode_array_with_array_mt(true)

-- Excluded tests that Lua cannot pass due to language limitations.
local excluded = {
  ['syntax-2-13'] = '@',        -- not a syntax error?
  ['syntax-2-14'] = '@.foo',    -- not a syntax error?
}

function equals(o1, o2)
  if o1 == o2 then return true end
  local o1Type = type(o1)
  local o2Type = type(o2)
  if o1Type ~= o2Type then return false end
  if o1Type ~= 'table' then return false end

  if #o1 ~= #o2 then return false end

  if getmetatable(o1) == _json.array_mt or getmetatable(o1) == _json.empty_array_mt then
    return arr_equals(nil, {o1, o2})
  end

  local keySet = {}

  for key1, value1 in pairs(o1) do
    local value2 = o2[key1]
    if value2 == nil or equals(value1, value2) == false then
      return false
    end
    keySet[key1] = true
  end

  for key2, _ in pairs(o2) do
    if not keySet[key2] then return false end
  end
  return true
end

function arr_equals(_, arguments)
  local a, b = arguments[1], arguments[2]
  if #a ~= #b then return false end
  local bFound = {}
  for i = 1, #a do
    local found = false
    for j = 1, #b do
      if equals(a[i], b[j]) and not bFound[j] then
        found = true
        bFound[j] = true
        break
      end
    end
    if not found then return false end
  end
  return true
end

say:set("assertion.arr_equals.positive", "PUTA!\nPassed in:\n%s\n\nExpected:\n%s")
say:set("assertion.arr_equals.negative", "PETA!\nPassed in:\n%s\n\nExpected:\n%s")
assert:register('assertion', 'arr_equals', arr_equals, 'assertion.arr_equals.positive', 'assertion.arr_equals.negative')

describe('compliance', function()

  -- Load the test suite JSON data from a file
  local function load_test(file)
    local f = assert(io.open(file, "r"))
    local t = assert(f:read("*a"), "Error loading file: " .. file)
    local data = assert(_json.decode(t), "Error decoding JSON: " .. file)
    f:close()
    return data
  end

  -- Run a test suite
  local function runsuite(file)
    data = assert(load_test(file))

    for i, suite in ipairs(data) do
      for i2, case in ipairs(suite.cases) do
        local name = string.format("%s from %s (Suite %s, case %s)",
          case.expression, file, i, i2)

        local id = string.gsub(file, "(.*/)(.*)", "%2")
        id = string.gsub(id, '.json', '') .. '-' .. i .. '-' .. i2

        if excluded[id] then
          if excluded[id] == case.expression then
            goto continue
          end
          error('Excluded expression not same as test case ' .. id .. ': ' .. case.expression)
        end

        it(name, function()
          if case.error then
            assert.is_false(pcall(jmespath.search, jmespath, suite.given, case.expression))
          else
            local result = jmespath:search(suite.given, case.expression)
            local found = false
            local a, b
            if case.oneof ~= nil then
              for _, v in ipairs(case.oneof) do
                if equals(result, v) then
                  found = true
                  break
                end
              end
              assert.is_true(found)
            else
              a = case.result ~= _json.null and case.result or nil
              b = result ~= _json.null and result or nil
            end

            if found or (case.ignore_order == true and arr_equals(nil, {a, b})) then
              return
            end

            assert.are.same(_json.encode(a), _json.encode(b))
          end
        end)

        ::continue::
      end
    end
  end

  local prefix = lfs.currentdir() .. "/spec/compliance/"
  local iter, obj = lfs.dir(prefix)
  local cur = obj:next()

  while cur do
    local attr = lfs.attributes(prefix .. cur)
    if attr.mode == "file" then
      runsuite(prefix .. cur)
    end
    cur = obj:next()
  end

  obj:close()

end)
