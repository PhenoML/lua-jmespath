local ____lualib = require("lualib_bundle")
local _json = require('cjson')
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__StringIncludes = ____lualib.__TS__StringIncludes
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys
local __TS__New = ____lualib.__TS__New
local __TS__Iterator = ____lualib.__TS__Iterator
local ____exports = {}
____exports.isArray = function(____, obj)
  return obj ~= nil and (getmetatable(obj) == _json.array_mt or getmetatable(obj) == _json.empty_array_mt)
end
____exports.isObject = function(____, obj)
  return obj ~= nil and type(obj) == "table" and not ____exports:isArray(obj)
end
____exports.strictDeepEqual = function(____, first, second)
  if first == second then return true end
  local firstType = type(first)
  local secondType = type(second)
  if firstType ~= secondType then return false end
  if firstType ~= 'table' then return false end

  local keySet = {}


  for key1, value1 in pairs(first) do
    local value2 = second[key1]
    if value2 == nil or ____exports:strictDeepEqual(value1, value2) == false then
      return false
    end
    keySet[key1] = true
  end

  for key2, _ in pairs(second) do
    if not keySet[key2] then return false end
  end
  return true
end
____exports.isFalse = function(____, obj)
    if obj == "" or obj == false or obj == nil or obj == _json.null then
        return true
    end
    if __TS__ArrayIsArray(obj) and #obj == 0 then
        return true
    end
    if ____exports.isObject(_G, obj) then
        for key in pairs(obj) do
            if rawget(obj, key) ~= nil then
                return false
            end
        end
        return true
    end
    return false
end
____exports.isAlpha = function(____, ch)
    return ch >= "a" and ch <= "z" or ch >= "A" and ch <= "Z" or ch == "_"
end
____exports.isNum = function(____, ch)
    return ch >= "0" and ch <= "9" or ch == "-"
end
____exports.isAlphaNum = function(____, ch)
    return ch >= "a" and ch <= "z" or ch >= "A" and ch <= "Z" or ch >= "0" and ch <= "9" or ch == "_"
end

-- the following methods were coded manually and not transpiled from TS
____exports.make_array = function(tbl)
  tbl = tbl or {}
  return setmetatable(tbl, _json.array_mt)
end

____exports.has_value = function(searchable, val, init)
  if type(searchable) == 'table' then
    return __TS__ArrayIncludes(searchable, val, init)
  end
  return __TS__StringIncludes(searchable, val, init)
end

____exports.dump_table = function(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. ____exports.dump_table(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

return ____exports
