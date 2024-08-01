local path = (...):match("(.-)[^%.]+$")
local ____lualib = require(path .. "lualib_bundle")
local _json = require("cjson")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__ObjectValues = ____lualib.__TS__ObjectValues
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local ____exports = {}
local ____index_2Ets = require(path .. "utils.index")
local isFalse = ____index_2Ets.isFalse
local isObject = ____index_2Ets.isObject
local make_array = ____index_2Ets.make_array
local strictDeepEqual = ____index_2Ets.strictDeepEqual
local ____Lexer_2Ets = require(path .. "Lexer")
local Token = ____Lexer_2Ets.Token
local ____Runtime_2Ets = require(path .. "Runtime")
local Runtime = ____Runtime_2Ets.Runtime
____exports.TreeInterpreter = __TS__Class()
local TreeInterpreter = ____exports.TreeInterpreter
TreeInterpreter.name = "TreeInterpreter"
function TreeInterpreter.prototype.____constructor(self)
    self._rootValue = nil
    self.runtime = __TS__New(Runtime, self)
end
function TreeInterpreter.prototype.search(self, node, value)
    self._rootValue = value
    return self:visit(node, value)
end
function TreeInterpreter.prototype.visit(self, node, value)
    local matched
    local current
    local result
    local first
    local second
    local field
    local left
    local right
    local collected
    local i
    local base
    repeat
        local ____switch5 = node.type
        local index, sliceParams, computed, start, stop, step, values, filtered, finalResults, original, merged, collectedObj, resolvedArgs, refNode
        local ____cond5 = ____switch5 == "Field"
        if ____cond5 then
            if value == nil or value == _json.null then
                return _json.null
            end
            if isObject(_G, value) then
                field = value[node.name]
                if field == nil or field == _json.null then
                    return _json.null
                end
                return field
            end
            return _json.null
        end
        ____cond5 = ____cond5 or ____switch5 == "Subexpression"
        if ____cond5 then
            result = self:visit(node.children[1], value)
            do
                i = 2
                while i <= #node.children do
                    result = self:visit(node.children[i], result)
                    if result == nil or result == _json.null then
                        return _json.null
                    end
                    i = i + 1
                end
            end
            return result
        end
        ____cond5 = ____cond5 or ____switch5 == "IndexExpression"
        if ____cond5 then
            left = self:visit(node.children[1], value)
            right = self:visit(node.children[2], left)
            return right
        end
        ____cond5 = ____cond5 or ____switch5 == "Index"
        if ____cond5 then
            if not __TS__ArrayIsArray(value) then
                return _json.null
            end
            index = node.value or 0
            if index < 0 then
                index = #value + index
            end
            result = value[index + 1]
            if result == nil or result == _json.null then
                result = _json.null
            end
            return result
        end
        ____cond5 = ____cond5 or ____switch5 == "Slice"
        if ____cond5 then
            if not __TS__ArrayIsArray(value) then
                return _json.null
            end
            sliceParams = {table.unpack(node.children)}
            computed = self:computeSliceParams(#value, sliceParams)
            start, stop, step = table.unpack(computed)
            result = make_array()
            if step > 0 then
                do
                    i = start + 1
                    while i <= stop do
                        table.insert(result, value[i])
                        i = i + step
                    end
                end
            else
                do
                    i = start + 1
                    while i >= stop do
                        table.insert(result, value[i])
                        i = i + step
                    end
                end
            end
            return result
        end
        ____cond5 = ____cond5 or ____switch5 == "Projection"
        if ____cond5 then
            base = self:visit(node.children[1], value)
            if not __TS__ArrayIsArray(base) then
                return _json.null
            end
            collected = make_array()
            do
                i = 1
                while i <= #base do
                    current = self:visit(node.children[2], base[i])
                    if current ~= nil and current ~= _json.null then
                        table.insert(collected, current)
                    end
                    i = i + 1
                end
            end
            return collected
        end
        ____cond5 = ____cond5 or ____switch5 == "ValueProjection"
        if ____cond5 then
            base = self:visit(node.children[1], value)
            if not isObject(_G, base) then
                return _json.null
            end
            collected = make_array()
            values = __TS__ObjectValues(base)
            do
                i = 1
                while i <= #values do
                    current = self:visit(node.children[2], values[i])
                    if current ~= nil and current ~= _json.null then
                        table.insert(collected, current)
                    end
                    i = i + 1
                end
            end
            return collected
        end
        ____cond5 = ____cond5 or ____switch5 == "FilterProjection"
        if ____cond5 then
            base = self:visit(node.children[1], value)
            if not __TS__ArrayIsArray(base) then
                return _json.null
            end
            filtered = make_array()
            finalResults = make_array()
            do
                i = 1
                while i <= #base do
                    matched = self:visit(node.children[3], base[i])
                    if not isFalse(_G, matched) then
                        table.insert(filtered, base[i])
                    end
                    i = i + 1
                end
            end
            do
                local j = 1
                while j <= #filtered do
                    current = self:visit(node.children[2], filtered[j])
                    if current ~= nil and current ~= _json.null then
                        table.insert(finalResults, current)
                    end
                    j = j + 1
                end
            end
            return finalResults
        end
        ____cond5 = ____cond5 or ____switch5 == "Comparator"
        if ____cond5 then
            first = self:visit(node.children[1], value)
            second = self:visit(node.children[2], value)
            repeat
                local ____switch30 = node.name
                local ____cond30 = ____switch30 == Token.TOK_EQ
                if ____cond30 then
                    result = strictDeepEqual(_G, first, second)
                    break
                end
                ____cond30 = ____cond30 or ____switch30 == Token.TOK_NE
                if ____cond30 then
                    result = not strictDeepEqual(_G, first, second)
                    break
                end
                ____cond30 = ____cond30 or ____switch30 == Token.TOK_GT
                if ____cond30 then
                    result = first > second
                    break
                end
                ____cond30 = ____cond30 or ____switch30 == Token.TOK_GTE
                if ____cond30 then
                    result = first >= second
                    break
                end
                ____cond30 = ____cond30 or ____switch30 == Token.TOK_LT
                if ____cond30 then
                    result = first < second
                    break
                end
                ____cond30 = ____cond30 or ____switch30 == Token.TOK_LTE
                if ____cond30 then
                    result = first <= second
                    break
                end
                do
                    error(
                        __TS__New(Error, "Unknown comparator: " .. node.name),
                        0
                    )
                end
            until true
            return result
        end
        ____cond5 = ____cond5 or ____switch5 == Token.TOK_FLATTEN
        if ____cond5 then
            original = self:visit(node.children[1], value)
            if not __TS__ArrayIsArray(original) then
                return _json.null
            end
            merged = make_array()
            do
                i = 1
                while i <= #original do
                    current = original[i]
                    if __TS__ArrayIsArray(current) then
                        local ____array_0 = __TS__SparseArrayNew(table.unpack(merged))
                        __TS__SparseArrayPush(
                            ____array_0,
                            table.unpack(current)
                        )
                        merged = make_array({__TS__SparseArraySpread(____array_0)})
                    else
                        merged[#merged + 1] = current
                    end
                    i = i + 1
                end
            end
            return merged
        end
        ____cond5 = ____cond5 or ____switch5 == "Identity"
        if ____cond5 then
            return value
        end
        ____cond5 = ____cond5 or ____switch5 == "MultiSelectList"
        if ____cond5 then
            if value == nil or value == _json.null then
                return _json.null
            end
            collected = make_array()
            do
                i = 1
                while i <= #node.children do
                    table.insert(collected, self:visit(node.children[i], value))
                    i = i + 1
                end
            end
            return collected
        end
        ____cond5 = ____cond5 or ____switch5 == "MultiSelectHash"
        if ____cond5 then
            if value == nil or value == _json.null then
                return _json.null
            end
            collectedObj = {}
            do
                i = 1
                while i <= #node.children do
                    local child = node.children[i]
                    if child.type == "KeyValuePair" then
                        collectedObj[child.name] = self:visit(child.value, value)
                    end
                    i = i + 1
                end
            end
            return collectedObj
        end
        ____cond5 = ____cond5 or ____switch5 == "OrExpression"
        if ____cond5 then
            matched = self:visit(node.children[1], value)
            if isFalse(_G, matched) then
                matched = self:visit(node.children[2], value)
            end
            return matched
        end
        ____cond5 = ____cond5 or ____switch5 == "AndExpression"
        if ____cond5 then
            first = self:visit(node.children[1], value)
            if isFalse(_G, first) then
                return first
            end
            return self:visit(node.children[2], value)
        end
        ____cond5 = ____cond5 or ____switch5 == "NotExpression"
        if ____cond5 then
            first = self:visit(node.children[1], value)
            return isFalse(_G, first)
        end
        ____cond5 = ____cond5 or ____switch5 == "Literal"
        if ____cond5 then
            return node.value
        end
        ____cond5 = ____cond5 or ____switch5 == Token.TOK_PIPE
        if ____cond5 then
            left = self:visit(node.children[1], value)
            return self:visit(node.children[2], left)
        end
        ____cond5 = ____cond5 or ____switch5 == Token.TOK_CURRENT
        if ____cond5 then
            return value
        end
        ____cond5 = ____cond5 or ____switch5 == Token.TOK_ROOT
        if ____cond5 then
            return self._rootValue
        end
        ____cond5 = ____cond5 or ____switch5 == "Function"
        if ____cond5 then
            resolvedArgs = make_array()
            do
                local j = 1
                while j <= #node.children do
                    resolvedArgs[#resolvedArgs + 1] = self:visit(node.children[j], value)
                    j = j + 1
                end
            end
            return self.runtime:callFunction(node.name, resolvedArgs)
        end
        ____cond5 = ____cond5 or ____switch5 == "ExpressionReference"
        if ____cond5 then
            refNode = node.children[1]
            refNode.jmespathType = Token.TOK_EXPREF
            return refNode
        end
        do
            error(
                __TS__New(Error, "Unknown node type: " .. node.type),
                0
            )
        end
    until true
end
function TreeInterpreter.prototype.computeSliceParams(self, arrayLength, sliceParams)
    local start, stop, step = table.unpack(sliceParams)
    if step == nil or step == _json.null then
        step = 1
    elseif step == 0 then
        local ____error = __TS__New(Error, "Invalid slice, step cannot be 0")
        ____error.name = "RuntimeError"
        error(____error, 0)
    end
    local ____temp_1
    if step < 0 then
        ____temp_1 = true
    else
        ____temp_1 = false
    end
    local stepValueNegative = ____temp_1
    local ____temp_3
    if start == nil or start == _json.null then
        local ____stepValueNegative_2
        if stepValueNegative then
            ____stepValueNegative_2 = arrayLength - 1
        else
            ____stepValueNegative_2 = 0
        end
        ____temp_3 = ____stepValueNegative_2
    else
        ____temp_3 = self:capSliceRange(arrayLength, start, step)
    end
    start = ____temp_3
    local ____temp_4
    if stop == nil or stop == _json.null then
        ____temp_4 = stepValueNegative and -1 or arrayLength
    else
        ____temp_4 = self:capSliceRange(arrayLength, stop, step)
    end
    stop = ____temp_4
    return {start, stop, step}
end
function TreeInterpreter.prototype.capSliceRange(self, arrayLength, actualValue, step)
    local nextActualValue = actualValue
    if nextActualValue < 0 then
        nextActualValue = nextActualValue + arrayLength
        if nextActualValue < 0 then
            nextActualValue = step < 0 and -1 or 0
        end
    elseif nextActualValue >= arrayLength then
        local ____temp_5
        if step < 0 then
            ____temp_5 = arrayLength - 1
        else
            ____temp_5 = arrayLength
        end
        nextActualValue = ____temp_5
    end
    return nextActualValue
end
____exports.TreeInterpreterInstance = __TS__New(____exports.TreeInterpreter)
____exports.default = ____exports.TreeInterpreterInstance
return ____exports
