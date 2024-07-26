--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Parser_2Ets = require("Parser")
local Parser = ____Parser_2Ets.default
local ____Lexer_2Ets = require("Lexer")
local Lexer = ____Lexer_2Ets.default
local ____TreeInterpreter_2Ets = require("TreeInterpreter")
local TreeInterpreterInst = ____TreeInterpreter_2Ets.default
local ____Runtime_2Ets = require("Runtime")
local InputArgument = ____Runtime_2Ets.InputArgument
____exports.TYPE_ANY = InputArgument.TYPE_ANY
____exports.TYPE_ARRAY = InputArgument.TYPE_ARRAY
____exports.TYPE_ARRAY_NUMBER = InputArgument.TYPE_ARRAY_NUMBER
____exports.TYPE_ARRAY_STRING = InputArgument.TYPE_ARRAY_STRING
____exports.TYPE_BOOLEAN = InputArgument.TYPE_BOOLEAN
____exports.TYPE_EXPREF = InputArgument.TYPE_EXPREF
____exports.TYPE_NULL = InputArgument.TYPE_NULL
____exports.TYPE_NUMBER = InputArgument.TYPE_NUMBER
____exports.TYPE_OBJECT = InputArgument.TYPE_OBJECT
____exports.TYPE_STRING = InputArgument.TYPE_STRING
function ____exports.compile(self, expression)
    local nodeTree = Parser:parse(expression)
    return nodeTree
end
function ____exports.tokenize(self, expression)
    return Lexer:tokenize(expression)
end
____exports.registerFunction = function(____, functionName, customFunction, signature)
    TreeInterpreterInst.runtime:registerFunction(functionName, customFunction, signature)
end
function ____exports.search(self, data, expression)
    local nodeTree = Parser:parse(expression)
    return TreeInterpreterInst:search(nodeTree, data)
end
____exports.TreeInterpreter = TreeInterpreterInst
____exports.jmespath = {
    compile = ____exports.compile,
    registerFunction = ____exports.registerFunction,
    search = ____exports.search,
    tokenize = ____exports.tokenize,
    TreeInterpreter = ____exports.TreeInterpreter,
    TYPE_ANY = ____exports.TYPE_ANY,
    TYPE_ARRAY_NUMBER = ____exports.TYPE_ARRAY_NUMBER,
    TYPE_ARRAY_STRING = ____exports.TYPE_ARRAY_STRING,
    TYPE_ARRAY = ____exports.TYPE_ARRAY,
    TYPE_BOOLEAN = ____exports.TYPE_BOOLEAN,
    TYPE_EXPREF = ____exports.TYPE_EXPREF,
    TYPE_NULL = ____exports.TYPE_NULL,
    TYPE_NUMBER = ____exports.TYPE_NUMBER,
    TYPE_OBJECT = ____exports.TYPE_OBJECT,
    TYPE_STRING = ____exports.TYPE_STRING
}
____exports.default = ____exports.jmespath
return ____exports
