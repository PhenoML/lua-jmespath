local ____lualib = require("lualib_bundle")
local __json = require("cjson")
local __TS__Class = ____lualib.__TS__Class
local __TS__StringAccess = ____lualib.__TS__StringAccess
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__StringIncludes = ____lualib.__TS__StringIncludes
local __TS__StringSlice = ____lualib.__TS__StringSlice
local __TS__StringTrimStart = ____lualib.__TS__StringTrimStart
local __TS__StringReplace = ____lualib.__TS__StringReplace
local __TS__ParseInt = ____lualib.__TS__ParseInt
local ____exports = {}
local ____index_2Ets = require("utils.index")
local isAlpha = ____index_2Ets.isAlpha
local isNum = ____index_2Ets.isNum
local isAlphaNum = ____index_2Ets.isAlphaNum
____exports.Token = Token or ({})
____exports.Token.TOK_EOF = "EOF"
____exports.Token.TOK_UNQUOTEDIDENTIFIER = "UnquotedIdentifier"
____exports.Token.TOK_QUOTEDIDENTIFIER = "QuotedIdentifier"
____exports.Token.TOK_RBRACKET = "Rbracket"
____exports.Token.TOK_RPAREN = "Rparen"
____exports.Token.TOK_COMMA = "Comma"
____exports.Token.TOK_COLON = "Colon"
____exports.Token.TOK_RBRACE = "Rbrace"
____exports.Token.TOK_NUMBER = "Number"
____exports.Token.TOK_CURRENT = "Current"
____exports.Token.TOK_ROOT = "Root"
____exports.Token.TOK_EXPREF = "Expref"
____exports.Token.TOK_PIPE = "Pipe"
____exports.Token.TOK_OR = "Or"
____exports.Token.TOK_AND = "And"
____exports.Token.TOK_EQ = "EQ"
____exports.Token.TOK_GT = "GT"
____exports.Token.TOK_LT = "LT"
____exports.Token.TOK_GTE = "GTE"
____exports.Token.TOK_LTE = "LTE"
____exports.Token.TOK_NE = "NE"
____exports.Token.TOK_FLATTEN = "Flatten"
____exports.Token.TOK_STAR = "Star"
____exports.Token.TOK_FILTER = "Filter"
____exports.Token.TOK_DOT = "Dot"
____exports.Token.TOK_NOT = "Not"
____exports.Token.TOK_LBRACE = "Lbrace"
____exports.Token.TOK_LBRACKET = "Lbracket"
____exports.Token.TOK_LPAREN = "Lparen"
____exports.Token.TOK_LITERAL = "Literal"
____exports.basicTokens = {
    ["("] = ____exports.Token.TOK_LPAREN,
    [")"] = ____exports.Token.TOK_RPAREN,
    ["*"] = ____exports.Token.TOK_STAR,
    [","] = ____exports.Token.TOK_COMMA,
    ["."] = ____exports.Token.TOK_DOT,
    [":"] = ____exports.Token.TOK_COLON,
    ["@"] = ____exports.Token.TOK_CURRENT,
    ["$"] = ____exports.Token.TOK_ROOT,
    ["]"] = ____exports.Token.TOK_RBRACKET,
    ["{"] = ____exports.Token.TOK_LBRACE,
    ["}"] = ____exports.Token.TOK_RBRACE
}

local has_value = ____index_2Ets.has_value

local operatorStartToken = {["!"] = true, ["<"] = true, ["="] = true, [">"] = true}
local skipChars = {["\t"] = true, ["\n"] = true, ["\r"] = true, [" "] = true}
local StreamLexer = __TS__Class()
StreamLexer.name = "StreamLexer"
function StreamLexer.prototype.____constructor(self)
    self._current = 0
end
function StreamLexer.prototype.tokenize(self, stream)
    local tokens = {}
    self._current = 0
    local start
    local identifier
    local token
    while self._current < #stream do
        if isAlpha(
            _G,
            __TS__StringAccess(stream, self._current)
        ) then
            start = self._current
            identifier = self:consumeUnquotedIdentifier(stream)
            tokens[#tokens + 1] = {start = start, type = ____exports.Token.TOK_UNQUOTEDIDENTIFIER, value = identifier}
        elseif ____exports.basicTokens[__TS__StringAccess(stream, self._current)] ~= nil then
            tokens[#tokens + 1] = {
                start = self._current,
                type = ____exports.basicTokens[__TS__StringAccess(stream, self._current)],
                value = __TS__StringAccess(stream, self._current)
            }
            self._current = self._current + 1
        elseif isNum(
            _G,
            __TS__StringAccess(stream, self._current)
        ) then
            token = self:consumeNumber(stream)
            tokens[#tokens + 1] = token
        elseif __TS__StringAccess(stream, self._current) == "[" then
            token = self:consumeLBracket(stream)
            tokens[#tokens + 1] = token
        elseif __TS__StringAccess(stream, self._current) == "\"" then
            start = self._current
            identifier = self:consumeQuotedIdentifier(stream)
            tokens[#tokens + 1] = {start = start, type = ____exports.Token.TOK_QUOTEDIDENTIFIER, value = identifier}
        elseif __TS__StringAccess(stream, self._current) == "'" then
            start = self._current
            identifier = self:consumeRawStringLiteral(stream)
            tokens[#tokens + 1] = {start = start, type = ____exports.Token.TOK_LITERAL, value = identifier}
        elseif __TS__StringAccess(stream, self._current) == "`" then
            start = self._current
            local literal = self:consumeLiteral(stream)
            tokens[#tokens + 1] = {start = start, type = ____exports.Token.TOK_LITERAL, value = literal}
        elseif operatorStartToken[__TS__StringAccess(stream, self._current)] ~= nil then
            token = self:consumeOperator(stream)
            local ____token_1 = token
            if ____token_1 then
                local ____temp_0 = #tokens + 1
                tokens[____temp_0] = token
                ____token_1 = ____temp_0
            end
        elseif skipChars[__TS__StringAccess(stream, self._current)] ~= nil then
            self._current = self._current + 1
        elseif __TS__StringAccess(stream, self._current) == "&" then
            start = self._current
            self._current = self._current + 1
            if __TS__StringAccess(stream, self._current) == "&" then
                self._current = self._current + 1
                tokens[#tokens + 1] = {start = start, type = ____exports.Token.TOK_AND, value = "&&"}
            else
                tokens[#tokens + 1] = {start = start, type = ____exports.Token.TOK_EXPREF, value = "&"}
            end
        elseif __TS__StringAccess(stream, self._current) == "|" then
            start = self._current
            self._current = self._current + 1
            if __TS__StringAccess(stream, self._current) == "|" then
                self._current = self._current + 1
                tokens[#tokens + 1] = {start = start, type = ____exports.Token.TOK_OR, value = "||"}
            else
                tokens[#tokens + 1] = {start = start, type = ____exports.Token.TOK_PIPE, value = "|"}
            end
        else
            local ____error = __TS__New(
                Error,
                "Unknown character: " .. __TS__StringAccess(stream, self._current)
            )
            ____error.name = "LexerError"
            error(____error, 0)
        end
    end
    return tokens
end
function StreamLexer.prototype.consumeUnquotedIdentifier(self, stream)
    local start = self._current
    self._current = self._current + 1
    while self._current < #stream and isAlphaNum(
        _G,
        __TS__StringAccess(stream, self._current)
    ) do
        self._current = self._current + 1
    end
    return __TS__StringSlice(stream, start, self._current)
end
function StreamLexer.prototype.consumeQuotedIdentifier(self, stream)
    local start = self._current
    self._current = self._current + 1
    local maxLength = #stream
    while __TS__StringAccess(stream, self._current) ~= "\"" and self._current < maxLength do
        local current = self._current
        if __TS__StringAccess(stream, current) == "\\" and (__TS__StringAccess(stream, current + 1) == "\\" or __TS__StringAccess(stream, current + 1) == "\"") then
            current = current + 2
        else
            current = current + 1
        end
        self._current = current
    end
    self._current = self._current + 1
    return __json.decode(__TS__StringSlice(stream, start, self._current))
end
function StreamLexer.prototype.consumeRawStringLiteral(self, stream)
    local start = self._current
    self._current = self._current + 1
    local maxLength = #stream
    while __TS__StringAccess(stream, self._current) ~= "'" and self._current < maxLength do
        local current = self._current
        if __TS__StringAccess(stream, current) == "\\" and (__TS__StringAccess(stream, current + 1) == "\\" or __TS__StringAccess(stream, current + 1) == "'") then
            current = current + 2
        else
            current = current + 1
        end
        self._current = current
    end
    self._current = self._current + 1
    local literal = __TS__StringSlice(stream, start + 1, self._current - 1)
    return __TS__StringReplace(literal, "\\'", "'")
end
function StreamLexer.prototype.consumeNumber(self, stream)
    local start = self._current
    self._current = self._current + 1
    local maxLength = #stream
    while isNum(
        _G,
        __TS__StringAccess(stream, self._current)
    ) and self._current < maxLength do
        self._current = self._current + 1
    end
    local value = __TS__ParseInt(
        __TS__StringSlice(stream, start, self._current),
        10
    )
    return {start = start, value = value, type = ____exports.Token.TOK_NUMBER}
end
function StreamLexer.prototype.consumeLBracket(self, stream)
    local start = self._current
    self._current = self._current + 1
    if __TS__StringAccess(stream, self._current) == "?" then
        self._current = self._current + 1
        return {start = start, type = ____exports.Token.TOK_FILTER, value = "[?"}
    end
    if __TS__StringAccess(stream, self._current) == "]" then
        self._current = self._current + 1
        return {start = start, type = ____exports.Token.TOK_FLATTEN, value = "[]"}
    end
    return {start = start, type = ____exports.Token.TOK_LBRACKET, value = "["}
end
function StreamLexer.prototype.consumeOperator(self, stream)
    local start = self._current
    local startingChar = __TS__StringAccess(stream, start)
    self._current = self._current + 1
    if startingChar == "!" then
        if __TS__StringAccess(stream, self._current) == "=" then
            self._current = self._current + 1
            return {start = start, type = ____exports.Token.TOK_NE, value = "!="}
        end
        return {start = start, type = ____exports.Token.TOK_NOT, value = "!"}
    end
    if startingChar == "<" then
        if __TS__StringAccess(stream, self._current) == "=" then
            self._current = self._current + 1
            return {start = start, type = ____exports.Token.TOK_LTE, value = "<="}
        end
        return {start = start, type = ____exports.Token.TOK_LT, value = "<"}
    end
    if startingChar == ">" then
        if __TS__StringAccess(stream, self._current) == "=" then
            self._current = self._current + 1
            return {start = start, type = ____exports.Token.TOK_GTE, value = ">="}
        end
        return {start = start, type = ____exports.Token.TOK_GT, value = ">"}
    end
    if startingChar == "=" and __TS__StringAccess(stream, self._current) == "=" then
        self._current = self._current + 1
        return {start = start, type = ____exports.Token.TOK_EQ, value = "=="}
    end
end
function StreamLexer.prototype.consumeLiteral(self, stream)
    self._current = self._current + 1
    local start = self._current
    local maxLength = #stream
    while __TS__StringAccess(stream, self._current) ~= "`" and self._current < maxLength do
        local current = self._current
        if __TS__StringAccess(stream, current) == "\\" and (__TS__StringAccess(stream, current + 1) == "\\" or __TS__StringAccess(stream, current + 1) == "`") then
            current = current + 2
        else
            current = current + 1
        end
        self._current = current
    end
    local literalString = __TS__StringTrimStart(__TS__StringSlice(stream, start, self._current))
    literalString = __TS__StringReplace(literalString, "\\`", "`")
    local ____table_looksLikeJSON_result_2
    if self:looksLikeJSON(literalString) then
        ____table_looksLikeJSON_result_2 = __json.decode(literalString)
    else
        ____table_looksLikeJSON_result_2 = __json.decode(("\"" .. tostring(literalString)) .. "\"")
    end
    local literal = ____table_looksLikeJSON_result_2
    self._current = self._current + 1
    return literal
end
function StreamLexer.prototype.looksLikeJSON(self, literalString)
    local startingChars = "[{\""
    local jsonLiterals = {"true", "false", "null"}
    local numberLooking = "-0123456789"
    if literalString == "" then
        return false
    end
    if has_value(startingChars, __TS__StringAccess(literalString, 0)) then
        return true
    end
    if has_value(jsonLiterals, literalString) then
        return true
    end
    if has_value(numberLooking, __TS__StringAccess(literalString, 0)) then
        do
            local function ____catch(ex)
                return true, false
            end
            local ____try, ____hasReturned, ____returnValue = pcall(function()
                __json.decode(literalString)
                return true, true
            end)
            if not ____try then
                ____hasReturned, ____returnValue = ____catch(____hasReturned)
            end
            if ____hasReturned then
                return ____returnValue
            end
        end
    end
    return false
end
____exports.Lexer = __TS__New(StreamLexer)
____exports.default = ____exports.Lexer
return ____exports
