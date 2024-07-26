local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__StringAccess = ____lualib.__TS__StringAccess
local __TS__StringIncludes = ____lualib.__TS__StringIncludes
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local __TS__ArrayReverse = ____lualib.__TS__ArrayReverse
local __TS__ArraySort = ____lualib.__TS__ArraySort
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local __TS__ArrayReduce = ____lualib.__TS__ArrayReduce
local __TS__Number = ____lualib.__TS__Number
local __TS__NumberIsNaN = ____lualib.__TS__NumberIsNaN
local __TS__ObjectValues = ____lualib.__TS__ObjectValues
local __TS__FunctionBind = ____lualib.__TS__FunctionBind
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____Lexer_2Ets = require("Lexer")
local Token = ____Lexer_2Ets.Token
local ____index_2Ets = require("utils.index")
local isObject = ____index_2Ets.isObject

local __json = require('cjson')
__json.decode_array_with_array_mt(true)

____exports.InputArgument = InputArgument or ({})
____exports.InputArgument.TYPE_NUMBER = 0
____exports.InputArgument[____exports.InputArgument.TYPE_NUMBER] = "TYPE_NUMBER"
____exports.InputArgument.TYPE_ANY = 1
____exports.InputArgument[____exports.InputArgument.TYPE_ANY] = "TYPE_ANY"
____exports.InputArgument.TYPE_STRING = 2
____exports.InputArgument[____exports.InputArgument.TYPE_STRING] = "TYPE_STRING"
____exports.InputArgument.TYPE_ARRAY = 3
____exports.InputArgument[____exports.InputArgument.TYPE_ARRAY] = "TYPE_ARRAY"
____exports.InputArgument.TYPE_OBJECT = 4
____exports.InputArgument[____exports.InputArgument.TYPE_OBJECT] = "TYPE_OBJECT"
____exports.InputArgument.TYPE_BOOLEAN = 5
____exports.InputArgument[____exports.InputArgument.TYPE_BOOLEAN] = "TYPE_BOOLEAN"
____exports.InputArgument.TYPE_EXPREF = 6
____exports.InputArgument[____exports.InputArgument.TYPE_EXPREF] = "TYPE_EXPREF"
____exports.InputArgument.TYPE_NULL = 7
____exports.InputArgument[____exports.InputArgument.TYPE_NULL] = "TYPE_NULL"
____exports.InputArgument.TYPE_ARRAY_NUMBER = 8
____exports.InputArgument[____exports.InputArgument.TYPE_ARRAY_NUMBER] = "TYPE_ARRAY_NUMBER"
____exports.InputArgument.TYPE_ARRAY_STRING = 9
____exports.InputArgument[____exports.InputArgument.TYPE_ARRAY_STRING] = "TYPE_ARRAY_STRING"
____exports.Runtime = __TS__Class()

local has_value = ____index_2Ets.has_value
local make_array = ____index_2Ets.make_array

local Runtime = ____exports.Runtime
Runtime.name = "Runtime"
function Runtime.prototype.____constructor(self, interpreter)
    self.TYPE_NAME_TABLE = {
        [____exports.InputArgument.TYPE_NUMBER] = "number",
        [____exports.InputArgument.TYPE_ANY] = "any",
        [____exports.InputArgument.TYPE_STRING] = "string",
        [____exports.InputArgument.TYPE_ARRAY] = "array",
        [____exports.InputArgument.TYPE_OBJECT] = "object",
        [____exports.InputArgument.TYPE_BOOLEAN] = "boolean",
        [____exports.InputArgument.TYPE_EXPREF] = "expression",
        [____exports.InputArgument.TYPE_NULL] = "null",
        [____exports.InputArgument.TYPE_ARRAY_NUMBER] = "Array<number>",
        [____exports.InputArgument.TYPE_ARRAY_STRING] = "Array<string>"
    }
    self.functionAbs = function(____, ____bindingPattern0)
        local inputValue
        inputValue = ____bindingPattern0[1]
        return math.abs(inputValue)
    end
    self.functionAvg = function(____, ____bindingPattern0)
        local inputArray
        inputArray = ____bindingPattern0[1]
        local sum = 0
        do
            local i = 0
            while i < #inputArray do
                sum = sum + inputArray[i + 1]
                i = i + 1
            end
        end
        return sum / #inputArray
    end
    self.functionCeil = function(____, ____bindingPattern0)
        local inputValue
        inputValue = ____bindingPattern0[1]
        return math.ceil(inputValue)
    end
    self.functionContains = function(____, resolvedArgs)
        local searchable, searchValue = table.unpack(resolvedArgs)
        return has_value(searchable, searchValue)
    end
    self.functionEndsWith = function(____, resolvedArgs)
        local searchStr, suffix = table.unpack(resolvedArgs)
        return has_value(searchStr, suffix, #searchStr - #suffix)
    end
    self.functionFloor = function(____, ____bindingPattern0)
        local inputValue
        inputValue = ____bindingPattern0[1]
        return math.floor(inputValue)
    end
    self.functionJoin = function(____, resolvedArgs)
        local joinChar, listJoin = table.unpack(resolvedArgs)
        return table.concat(listJoin, joinChar or ",")
    end
    self.functionKeys = function(____, ____bindingPattern0)
        local inputObject
        inputObject = ____bindingPattern0[1]
        return make_array(__TS__ObjectKeys(inputObject))
    end
    self.functionLength = function(____, ____bindingPattern0)
        local inputValue
        inputValue = ____bindingPattern0[1]
        if not isObject(_G, inputValue) then
            return #inputValue
        end
        return #__TS__ObjectKeys(inputValue)
    end
    self.functionMap = function(____, resolvedArgs)
        if not self._interpreter then
            return {}
        end
        local mapped = make_array()
        local interpreter = self._interpreter
        local exprefNode = resolvedArgs[1]
        local elements = resolvedArgs[2]
        do
            local i = 1
          while i <= #elements do
            local r = interpreter:visit(exprefNode, elements[i])
            if r == nil then r = __json.null end
            table.insert(mapped, r)
            i = i + 1
          end
        end
        return mapped
    end
    self.functionMax = function(____, ____bindingPattern0)
        local inputValue
        inputValue = ____bindingPattern0[1]
        if not #inputValue then
            return nil
        end
        local typeName = self:getTypeName(inputValue[1])
        if typeName == ____exports.InputArgument.TYPE_NUMBER then
            return math.max(table.unpack(inputValue))
        end
        local elements = inputValue
        local maxElement = elements[1]
        do
            local i = 1
            while i < #elements do
                if maxElement:upper() < elements[i + 1]:upper() then
                    maxElement = elements[i + 1]
                end
                i = i + 1
            end
        end
        return maxElement
    end
    self.functionMaxBy = function(____, resolvedArgs)
        local exprefNode = resolvedArgs[2]
        local resolvedArray = resolvedArgs[1]
        local keyFunction = self:createKeyFunction(exprefNode, {____exports.InputArgument.TYPE_NUMBER, ____exports.InputArgument.TYPE_STRING})
        local maxNumber = -math.huge
        local maxRecord
        local current
        do
            local i = 0
            while i < #resolvedArray do
                current = keyFunction and keyFunction(_G, resolvedArray[i + 1])
                if current ~= nil and current > maxNumber then
                    maxNumber = current
                    maxRecord = resolvedArray[i + 1]
                end
                i = i + 1
            end
        end
        return maxRecord
    end
    self.functionMerge = function(____, resolvedArgs)
        local merged = {}
        do
            local i = 0
            while i < #resolvedArgs do
                local current = resolvedArgs[i + 1]
                merged = __TS__ObjectAssign(merged, current)
                i = i + 1
            end
        end
        return merged
    end
    self.functionMin = function(____, ____bindingPattern0)
        local inputValue
        inputValue = ____bindingPattern0[1]
        if not #inputValue then
            return nil
        end
        local typeName = self:getTypeName(inputValue[1])
        if typeName == ____exports.InputArgument.TYPE_NUMBER then
            return math.min(table.unpack(inputValue))
        end
        local elements = inputValue
        local minElement = elements[1]
        do
            local i = 1
            while i < #elements do
                if elements[i + 1]:upper() < minElement:upper() then
                    minElement = elements[i + 1]
                end
                i = i + 1
            end
        end
        return minElement
    end
    self.functionMinBy = function(____, resolvedArgs)
        local exprefNode = resolvedArgs[2]
        local resolvedArray = resolvedArgs[1]
        local keyFunction = self:createKeyFunction(exprefNode, {____exports.InputArgument.TYPE_NUMBER, ____exports.InputArgument.TYPE_STRING})
        local minNumber = math.huge
        local minRecord
        local current
        do
            local i = 0
            while i < #resolvedArray do
                current = keyFunction and keyFunction(_G, resolvedArray[i + 1])
                if current ~= nil and current < minNumber then
                    minNumber = current
                    minRecord = resolvedArray[i + 1]
                end
                i = i + 1
            end
        end
        return minRecord
    end
    self.functionNotNull = function(____, resolvedArgs)
        for _, arg in ipairs(resolvedArgs) do
            if self:getTypeName(arg) ~= ____exports.InputArgument.TYPE_NULL then
                return arg
            end
        end
        return nil
    end
    self.functionReverse = function(____, ____bindingPattern0)
        local inputValue
        inputValue = ____bindingPattern0[1]
        local typeName = self:getTypeName(inputValue)
        if typeName == ____exports.InputArgument.TYPE_STRING then
            local originalStr = inputValue
            local reversedStr = ""
            do
                local i = #originalStr - 1
                while i >= 0 do
                    reversedStr = reversedStr .. __TS__StringAccess(originalStr, i)
                    i = i - 1
                end
            end
            return reversedStr
        end
        local reversedArray = __TS__ArraySlice(inputValue, 0)
        __TS__ArrayReverse(reversedArray)
        return make_array(reversedArray)
    end
    self.functionSort = function(____, ____bindingPattern0)
        local inputValue
        inputValue = ____bindingPattern0[1]
        local unpacked = {table.unpack(inputValue)}
        return make_array(__TS__ArraySort(unpacked))
    end
    self.functionSortBy = function(____, resolvedArgs)
        if not self._interpreter then
            return make_array()
        end
        local sortedArray = make_array(__TS__ArraySlice(resolvedArgs[1], 0))
        if #sortedArray == 0 then
            return sortedArray
        end
        local interpreter = self._interpreter
        local exprefNode = resolvedArgs[2]
        local requiredType = self:getTypeName(interpreter:visit(exprefNode, sortedArray[1]))
        if requiredType ~= nil and not has_value(({____exports.InputArgument.TYPE_NUMBER, ____exports.InputArgument.TYPE_STRING}), requiredType) then
            error(
                __TS__New(Error, ("TypeError: unexpected type (" .. self.TYPE_NAME_TABLE[requiredType]) .. ")"),
                0
            )
        end
        local decorated = make_array()
        for i, v in ipairs(sortedArray) do
          decorated[i] = {i, v}
        end
        __TS__ArraySort(
            decorated,
            function(____, a, b)
                local exprA = interpreter:visit(exprefNode, a[2])
                local exprB = interpreter:visit(exprefNode, b[2])
                if self:getTypeName(exprA) ~= requiredType then
                    error(
                        __TS__New(
                            Error,
                            (("TypeError: expected (" .. self.TYPE_NAME_TABLE[requiredType]) .. "), received ") .. self.TYPE_NAME_TABLE[self:getTypeName(exprA)]
                        ),
                        0
                    )
                elseif self:getTypeName(exprB) ~= requiredType then
                    error(
                        __TS__New(
                            Error,
                            (("TypeError: expected (" .. self.TYPE_NAME_TABLE[requiredType]) .. "), received ") .. self.TYPE_NAME_TABLE[self:getTypeName(exprB)]
                        ),
                        0
                    )
                end
                if exprA > exprB then
                    return 1
                end
                return exprA < exprB and -1 or a[1] - b[1]
            end
        )
        for i, v in ipairs(decorated) do
          sortedArray[i] = v[2]
        end
        return sortedArray
    end
    self.functionStartsWith = function(____, ____bindingPattern0)
        local searchStr
        local searchable
        searchable = ____bindingPattern0[1]
        searchStr = ____bindingPattern0[2]
      print(string.find(searchable, searchStr, 1, true) == 1)
        return string.find(searchable, searchStr, 1, true) == 1
    end
    self.functionSum = function(____, ____bindingPattern0)
        local inputValue
        inputValue = ____bindingPattern0[1]
        return __TS__ArrayReduce(
            inputValue,
            function(____, x, y) return x + y end,
            0
        )
    end
    self.functionToArray = function(____, ____bindingPattern0)
        local inputValue
        inputValue = ____bindingPattern0[1]
        if self:getTypeName(inputValue) == ____exports.InputArgument.TYPE_ARRAY then
            return inputValue
        end
        return make_array({inputValue})
    end
    self.functionToNumber = function(____, ____bindingPattern0)
        local inputValue
        inputValue = ____bindingPattern0[1]
        local typeName = self:getTypeName(inputValue)
        local convertedValue
        if typeName == ____exports.InputArgument.TYPE_NUMBER then
            return inputValue
        end
        if typeName == ____exports.InputArgument.TYPE_STRING then
            convertedValue = __TS__Number(inputValue)
            if not __TS__NumberIsNaN(convertedValue) then
                return convertedValue
            end
        end
        return nil
    end
    self.functionToString = function(____, ____bindingPattern0)
        local inputValue
        inputValue = ____bindingPattern0[1]
        if self:getTypeName(inputValue) == ____exports.InputArgument.TYPE_STRING then
            return inputValue
        end
        return __json.encode(inputValue)
    end
    self.functionType = function(____, ____bindingPattern0)
        local inputValue
        inputValue = ____bindingPattern0[1]
        repeat
            local ____switch64 = self:getTypeName(inputValue)
            local ____cond64 = ____switch64 == ____exports.InputArgument.TYPE_NUMBER
            if ____cond64 then
                return "number"
            end
            ____cond64 = ____cond64 or ____switch64 == ____exports.InputArgument.TYPE_STRING
            if ____cond64 then
                return "string"
            end
            ____cond64 = ____cond64 or ____switch64 == ____exports.InputArgument.TYPE_ARRAY
            if ____cond64 then
                return "array"
            end
            ____cond64 = ____cond64 or ____switch64 == ____exports.InputArgument.TYPE_OBJECT
            if ____cond64 then
                return "object"
            end
            ____cond64 = ____cond64 or ____switch64 == ____exports.InputArgument.TYPE_BOOLEAN
            if ____cond64 then
                return "boolean"
            end
            ____cond64 = ____cond64 or ____switch64 == ____exports.InputArgument.TYPE_EXPREF
            if ____cond64 then
                return "expref"
            end
            ____cond64 = ____cond64 or ____switch64 == ____exports.InputArgument.TYPE_NULL
            if ____cond64 then
                return "null"
            end
            do
                return
            end
        until true
    end
    self.functionValues = function(____, ____bindingPattern0)
        local inputObject
        inputObject = ____bindingPattern0[1]
        return make_array(__TS__ObjectValues(inputObject))
    end
    self.functionTable = {
        abs = {_func = self.functionAbs, _signature = {{types = {____exports.InputArgument.TYPE_NUMBER}}}},
        avg = {_func = self.functionAvg, _signature = {{types = {____exports.InputArgument.TYPE_ARRAY_NUMBER}}}},
        ceil = {_func = self.functionCeil, _signature = {{types = {____exports.InputArgument.TYPE_NUMBER}}}},
        contains = {_func = self.functionContains, _signature = {{types = {____exports.InputArgument.TYPE_STRING, ____exports.InputArgument.TYPE_ARRAY}}, {types = {____exports.InputArgument.TYPE_ANY}}}},
        ends_with = {_func = self.functionEndsWith, _signature = {{types = {____exports.InputArgument.TYPE_STRING}}, {types = {____exports.InputArgument.TYPE_STRING}}}},
        floor = {_func = self.functionFloor, _signature = {{types = {____exports.InputArgument.TYPE_NUMBER}}}},
        join = {_func = self.functionJoin, _signature = {{types = {____exports.InputArgument.TYPE_STRING}}, {types = {____exports.InputArgument.TYPE_ARRAY_STRING}}}},
        keys = {_func = self.functionKeys, _signature = {{types = {____exports.InputArgument.TYPE_OBJECT}}}},
        length = {_func = self.functionLength, _signature = {{types = {____exports.InputArgument.TYPE_STRING, ____exports.InputArgument.TYPE_ARRAY, ____exports.InputArgument.TYPE_OBJECT}}}},
        map = {_func = self.functionMap, _signature = {{types = {____exports.InputArgument.TYPE_EXPREF}}, {types = {____exports.InputArgument.TYPE_ARRAY}}}},
        max = {_func = self.functionMax, _signature = {{types = {____exports.InputArgument.TYPE_ARRAY_NUMBER, ____exports.InputArgument.TYPE_ARRAY_STRING}}}},
        max_by = {_func = self.functionMaxBy, _signature = {{types = {____exports.InputArgument.TYPE_ARRAY}}, {types = {____exports.InputArgument.TYPE_EXPREF}}}},
        merge = {_func = self.functionMerge, _signature = {{types = {____exports.InputArgument.TYPE_OBJECT}, variadic = true}}},
        min = {_func = self.functionMin, _signature = {{types = {____exports.InputArgument.TYPE_ARRAY_NUMBER, ____exports.InputArgument.TYPE_ARRAY_STRING}}}},
        min_by = {_func = self.functionMinBy, _signature = {{types = {____exports.InputArgument.TYPE_ARRAY}}, {types = {____exports.InputArgument.TYPE_EXPREF}}}},
        not_null = {_func = self.functionNotNull, _signature = {{types = {____exports.InputArgument.TYPE_ANY}, variadic = true}}},
        reverse = {_func = self.functionReverse, _signature = {{types = {____exports.InputArgument.TYPE_STRING, ____exports.InputArgument.TYPE_ARRAY}}}},
        sort = {_func = self.functionSort, _signature = {{types = {____exports.InputArgument.TYPE_ARRAY_STRING, ____exports.InputArgument.TYPE_ARRAY_NUMBER}}}},
        sort_by = {_func = self.functionSortBy, _signature = {{types = {____exports.InputArgument.TYPE_ARRAY}}, {types = {____exports.InputArgument.TYPE_EXPREF}}}},
        starts_with = {_func = self.functionStartsWith, _signature = {{types = {____exports.InputArgument.TYPE_STRING}}, {types = {____exports.InputArgument.TYPE_STRING}}}},
        sum = {_func = self.functionSum, _signature = {{types = {____exports.InputArgument.TYPE_ARRAY_NUMBER}}}},
        to_array = {_func = self.functionToArray, _signature = {{types = {____exports.InputArgument.TYPE_ANY}}}},
        to_number = {_func = self.functionToNumber, _signature = {{types = {____exports.InputArgument.TYPE_ANY}}}},
        to_string = {_func = self.functionToString, _signature = {{types = {____exports.InputArgument.TYPE_ANY}}}},
        type = {_func = self.functionType, _signature = {{types = {____exports.InputArgument.TYPE_ANY}}}},
        values = {_func = self.functionValues, _signature = {{types = {____exports.InputArgument.TYPE_OBJECT}}}}
    }
    self._interpreter = interpreter
end
function Runtime.prototype.registerFunction(self, name, customFunction, signature)
    if self.functionTable[name] ~= nil then
        error(
            __TS__New(Error, ("Function already defined: " .. name) .. "()"),
            0
        )
    end
    self.functionTable[name] = {
        _func = __TS__FunctionBind(customFunction, self),
        _signature = signature
    }
end
function Runtime.prototype.callFunction(self, name, resolvedArgs)
    local functionEntry = self.functionTable[name]
    if functionEntry == nil then
        error(
            __TS__New(Error, ("Unknown function: " .. name) .. "()"),
            0
        )
    end
    self:validateArgs(name, resolvedArgs, functionEntry._signature)
    return functionEntry._func(self, resolvedArgs)
end
function Runtime.prototype.validateInputSignatures(self, name, signature)
    do
        local i = 0
        while i < #signature do
            if signature[i + 1].variadic ~= nil and i ~= #signature - 1 then
                error(
                    __TS__New(
                        Error,
                        ((("ArgumentError: " .. name) .. "() 'variadic' argument ") .. tostring(i + 1)) .. " must occur last"
                    ),
                    0
                )
            end
            i = i + 1
        end
    end
end
function Runtime.prototype.validateArgs(self, name, args, signature)
    local pluralized
    self:validateInputSignatures(name, signature)
    local numberOfRequiredArgs = #__TS__ArrayFilter(
        signature,
        function(____, argSignature)
            local ____temp_0 = not argSignature.optional
            if ____temp_0 == nil then
                ____temp_0 = false
            end
            return ____temp_0
        end
    )
    local ____opt_1 = signature[#signature]
    local ____temp_3 = ____opt_1 and ____opt_1.variadic
    if ____temp_3 == nil then
        ____temp_3 = false
    end
    local lastArgIsVariadic = ____temp_3
    local tooFewArgs = #args < numberOfRequiredArgs
    local tooManyArgs = #args > #signature
    local tooFewModifier = tooFewArgs and (not lastArgIsVariadic and numberOfRequiredArgs > 1 or lastArgIsVariadic) and "at least " or ""
    if lastArgIsVariadic and tooFewArgs or not lastArgIsVariadic and (tooFewArgs or tooManyArgs) then
        pluralized = #signature > 1
        error(
            __TS__New(
                Error,
                ((((((("ArgumentError: " .. name) .. "() takes ") .. tooFewModifier) .. tostring(numberOfRequiredArgs)) .. " argument") .. (pluralized and "s" or "")) .. " but received ") .. tostring(#args)
            ),
            0
        )
    end
    local currentSpec
    local actualType
    local typeMatched
    do
        local i = 0
        while i < #signature do
            typeMatched = false
            currentSpec = signature[i + 1].types
            actualType = self:getTypeName(args[i + 1])
            local j
            do
                j = 0
                while j < #currentSpec do
                    if actualType ~= nil and self:typeMatches(actualType, currentSpec[j + 1], args[i + 1]) then
                        typeMatched = true
                        break
                    end
                    j = j + 1
                end
            end
            if not typeMatched and actualType ~= nil then
                local expected = table.concat(
                    __TS__ArrayMap(
                        currentSpec,
                        function(____, typeIdentifier)
                            return self.TYPE_NAME_TABLE[typeIdentifier]
                        end
                    ),
                    " | "
                )
                error(
                    __TS__New(
                        Error,
                        ((((((("TypeError: " .. name) .. "() expected argument ") .. tostring(i + 1)) .. " to be type (") .. expected) .. ") but received type ") .. self.TYPE_NAME_TABLE[actualType]) .. " instead."
                    ),
                    0
                )
            end
            i = i + 1
        end
    end
end
function Runtime.prototype.typeMatches(self, actual, expected, argValue)
    if expected == ____exports.InputArgument.TYPE_ANY then
        return true
    end
    if expected == ____exports.InputArgument.TYPE_ARRAY_STRING or expected == ____exports.InputArgument.TYPE_ARRAY_NUMBER or expected == ____exports.InputArgument.TYPE_ARRAY then
        if expected == ____exports.InputArgument.TYPE_ARRAY then
            return actual == ____exports.InputArgument.TYPE_ARRAY
        end
        if actual == ____exports.InputArgument.TYPE_ARRAY then
            local subtype
            if expected == ____exports.InputArgument.TYPE_ARRAY_NUMBER then
                subtype = ____exports.InputArgument.TYPE_NUMBER
            elseif expected == ____exports.InputArgument.TYPE_ARRAY_STRING then
                subtype = ____exports.InputArgument.TYPE_STRING
            end
            do
                local i = 0
                while i < #argValue do
                    local typeName = self:getTypeName(argValue[i + 1])
                    if typeName ~= nil and subtype ~= nil and not self:typeMatches(typeName, subtype, argValue[i + 1]) then
                        return false
                    end
                    i = i + 1
                end
            end
            return true
        end
    else
        return actual == expected
    end
    return false
end
function Runtime.prototype.getTypeName(self, obj)
    repeat
        local objType = type(obj)
        if objType == 'string' then
            return ____exports.InputArgument.TYPE_STRING
        end

        if objType == 'number' then
            return ____exports.InputArgument.TYPE_NUMBER
        end

        if objType == 'boolean' then
            return ____exports.InputArgument.TYPE_BOOLEAN
        end

        if objType == 'nil' or obj == __json.null then
            return ____exports.InputArgument.TYPE_NULL
        end

        if objType == 'table' then
            if getmetatable(obj) == __json.array_mt or getmetatable(obj) == __json.empty_array_mt then
              return ____exports.InputArgument.TYPE_ARRAY
            end

            if obj.jmespathType == Token.TOK_EXPREF then
                return ____exports.InputArgument.TYPE_EXPREF
            end

            return ____exports.InputArgument.TYPE_OBJECT
        end
        do
            return
        end
    until true
end
function Runtime.prototype.createKeyFunction(self, exprefNode, allowedTypes)
    if not self._interpreter then
        return
    end
    local interpreter = self._interpreter
    local function keyFunc(____, x)
        local current = interpreter:visit(exprefNode, x)
        if not has_value(allowedTypes, self:getTypeName(current)) then
            local msg = (("TypeError: expected one of (" .. table.concat(
                __TS__ArrayMap(
                    allowedTypes,
                    function(____, t) return self.TYPE_NAME_TABLE[t] end
                ),
                " | "
            )) .. "), received ") .. self.TYPE_NAME_TABLE[self:getTypeName(current)]
            error(
                __TS__New(Error, msg),
                0
            )
        end
        return current
    end
    return keyFunc
end
return ____exports
