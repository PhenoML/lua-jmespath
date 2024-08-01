local path = (...):match("(.-)[^%.]+$")
local ____lualib = require(path .. "lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____Lexer_2Ets = require(path .. "Lexer")
local Lexer = ____Lexer_2Ets.default
local Token = ____Lexer_2Ets.Token
local bindingPower = {
    [Token.TOK_EOF] = 0,
    [Token.TOK_UNQUOTEDIDENTIFIER] = 0,
    [Token.TOK_QUOTEDIDENTIFIER] = 0,
    [Token.TOK_RBRACKET] = 0,
    [Token.TOK_RPAREN] = 0,
    [Token.TOK_COMMA] = 0,
    [Token.TOK_RBRACE] = 0,
    [Token.TOK_NUMBER] = 0,
    [Token.TOK_CURRENT] = 0,
    [Token.TOK_EXPREF] = 0,
    [Token.TOK_ROOT] = 0,
    [Token.TOK_PIPE] = 1,
    [Token.TOK_OR] = 2,
    [Token.TOK_AND] = 3,
    [Token.TOK_EQ] = 5,
    [Token.TOK_GT] = 5,
    [Token.TOK_LT] = 5,
    [Token.TOK_GTE] = 5,
    [Token.TOK_LTE] = 5,
    [Token.TOK_NE] = 5,
    [Token.TOK_FLATTEN] = 9,
    [Token.TOK_STAR] = 20,
    [Token.TOK_FILTER] = 21,
    [Token.TOK_DOT] = 40,
    [Token.TOK_NOT] = 45,
    [Token.TOK_LBRACE] = 50,
    [Token.TOK_LBRACKET] = 55,
    [Token.TOK_LPAREN] = 60
}
local ____index_2Ets = require(path .. "utils.index")
local has_value = ____index_2Ets.has_value
local make_array = ____index_2Ets.make_array
local TokenParser = __TS__Class()
TokenParser.name = "TokenParser"
function TokenParser.prototype.____constructor(self)
    self.index = 0
    self.tokens = {}
end
function TokenParser.prototype.parse(self, expression)
    self:loadTokens(expression)
    self.index = 0
    local ast = self:expression(0)
    if self:lookahead(0) ~= Token.TOK_EOF then
        local token = self:lookaheadToken(0)
        self:errorToken(
            token,
            (("Unexpected token type: " .. token.type) .. ", value: ") .. tostring(token.value)
        )
    end
    return ast
end
function TokenParser.prototype.loadTokens(self, expression)
    local ____array_0 = __TS__SparseArrayNew(table.unpack(Lexer:tokenize(expression)))
    __TS__SparseArrayPush(____array_0, {type = Token.TOK_EOF, value = "", start = #expression})
    self.tokens = {__TS__SparseArraySpread(____array_0)}
end
function TokenParser.prototype.expression(self, rbp)
    local leftToken = self:lookaheadToken(0)
    self:advance()
    local left = self:nud(leftToken)
    local currentTokenType = self:lookahead(0)
    while rbp < bindingPower[currentTokenType] do
        self:advance()
        left = self:led(currentTokenType, left)
        currentTokenType = self:lookahead(0)
    end
    return left
end
function TokenParser.prototype.lookahead(self, offset)
    return self.tokens[self.index + offset + 1].type
end
function TokenParser.prototype.lookaheadToken(self, offset)
    return self.tokens[self.index + offset + 1]
end
function TokenParser.prototype.advance(self)
    self.index = self.index + 1
end
function TokenParser.prototype.nud(self, token)
    local left
    local right
    local expression
    repeat
        local ____switch12 = token.type
        local node, args
        local ____cond12 = ____switch12 == Token.TOK_LITERAL
        if ____cond12 then
            return {type = "Literal", value = token.value}
        end
        ____cond12 = ____cond12 or ____switch12 == Token.TOK_UNQUOTEDIDENTIFIER
        if ____cond12 then
            return {type = "Field", name = token.value}
        end
        ____cond12 = ____cond12 or ____switch12 == Token.TOK_QUOTEDIDENTIFIER
        if ____cond12 then
            node = {type = "Field", name = token.value}
            if self:lookahead(0) == Token.TOK_LPAREN then
                error(
                    __TS__New(Error, "Quoted identifier not allowed for function names."),
                    0
                )
            else
                return node
            end
        end
        ____cond12 = ____cond12 or ____switch12 == Token.TOK_NOT
        if ____cond12 then
            right = self:expression(bindingPower.Not)
            return {type = "NotExpression", children = {right}}
        end
        ____cond12 = ____cond12 or ____switch12 == Token.TOK_STAR
        if ____cond12 then
            left = {type = "Identity"}
            right = self:lookahead(0) == Token.TOK_RBRACKET and ({type = "Identity"}) or self:parseProjectionRHS(bindingPower.Star)
            return {type = "ValueProjection", children = {left, right}}
        end
        ____cond12 = ____cond12 or ____switch12 == Token.TOK_FILTER
        if ____cond12 then
            return self:led(token.type, {type = "Identity"})
        end
        ____cond12 = ____cond12 or ____switch12 == Token.TOK_LBRACE
        if ____cond12 then
            return self:parseMultiselectHash()
        end
        ____cond12 = ____cond12 or ____switch12 == Token.TOK_FLATTEN
        if ____cond12 then
            left = {type = Token.TOK_FLATTEN, children = {{type = "Identity"}}}
            right = self:parseProjectionRHS(bindingPower.Flatten)
            return {type = "Projection", children = {left, right}}
        end
        ____cond12 = ____cond12 or ____switch12 == Token.TOK_LBRACKET
        if ____cond12 then
            if self:lookahead(0) == Token.TOK_NUMBER or self:lookahead(0) == Token.TOK_COLON then
                right = self:parseIndexExpression()
                return self:projectIfSlice({type = "Identity"}, right)
            end
            if self:lookahead(0) == Token.TOK_STAR and self:lookahead(1) == Token.TOK_RBRACKET then
                self:advance()
                self:advance()
                right = self:parseProjectionRHS(bindingPower.Star)
                return {children = {{type = "Identity"}, right}, type = "Projection"}
            end
            return self:parseMultiselectList()
        end
        ____cond12 = ____cond12 or ____switch12 == Token.TOK_CURRENT
        if ____cond12 then
            return {type = Token.TOK_CURRENT}
        end
        ____cond12 = ____cond12 or ____switch12 == Token.TOK_ROOT
        if ____cond12 then
            return {type = Token.TOK_ROOT}
        end
        ____cond12 = ____cond12 or ____switch12 == Token.TOK_EXPREF
        if ____cond12 then
            expression = self:expression(bindingPower.Expref)
            return {type = "ExpressionReference", children = {expression}}
        end
        ____cond12 = ____cond12 or ____switch12 == Token.TOK_LPAREN
        if ____cond12 then
            args = {}
            while self:lookahead(0) ~= Token.TOK_RPAREN do
                if self:lookahead(0) == Token.TOK_CURRENT then
                    expression = {type = Token.TOK_CURRENT}
                    self:advance()
                else
                    expression = self:expression(0)
                end
                args[#args + 1] = expression
            end
            self:match(Token.TOK_RPAREN)
            return args[1]
        end
        do
            self:errorToken(token)
        end
    until true
end
function TokenParser.prototype.led(self, tokenName, left)
    local right
    repeat
        local ____switch21 = tokenName
        local rbp, name, args, expression, condition, leftNode, rightNode, token
        local ____cond21 = ____switch21 == Token.TOK_DOT
        if ____cond21 then
            rbp = bindingPower.Dot
            if self:lookahead(0) ~= Token.TOK_STAR then
                right = self:parseDotRHS(rbp)
                return {type = "Subexpression", children = {left, right}}
            end
            self:advance()
            right = self:parseProjectionRHS(rbp)
            return {type = "ValueProjection", children = {left, right}}
        end
        ____cond21 = ____cond21 or ____switch21 == Token.TOK_PIPE
        if ____cond21 then
            right = self:expression(bindingPower.Pipe)
            return {type = Token.TOK_PIPE, children = {left, right}}
        end
        ____cond21 = ____cond21 or ____switch21 == Token.TOK_OR
        if ____cond21 then
            right = self:expression(bindingPower.Or)
            return {type = "OrExpression", children = {left, right}}
        end
        ____cond21 = ____cond21 or ____switch21 == Token.TOK_AND
        if ____cond21 then
            right = self:expression(bindingPower.And)
            return {type = "AndExpression", children = {left, right}}
        end
        ____cond21 = ____cond21 or ____switch21 == Token.TOK_LPAREN
        if ____cond21 then
            name = left.name
            args = {}
            while self:lookahead(0) ~= Token.TOK_RPAREN do
                if self:lookahead(0) == Token.TOK_CURRENT then
                    expression = {type = Token.TOK_CURRENT}
                    self:advance()
                else
                    expression = self:expression(0)
                end
                if self:lookahead(0) == Token.TOK_COMMA then
                    self:match(Token.TOK_COMMA)
                end
                args[#args + 1] = expression
            end
            self:match(Token.TOK_RPAREN)
            return {name = name, type = "Function", children = args}
        end
        ____cond21 = ____cond21 or ____switch21 == Token.TOK_FILTER
        if ____cond21 then
            condition = self:expression(0)
            self:match(Token.TOK_RBRACKET)
            right = self:lookahead(0) == Token.TOK_FLATTEN and ({type = "Identity"}) or self:parseProjectionRHS(bindingPower.Filter)
            return {type = "FilterProjection", children = {left, right, condition}}
        end
        ____cond21 = ____cond21 or ____switch21 == Token.TOK_FLATTEN
        if ____cond21 then
            leftNode = {type = Token.TOK_FLATTEN, children = {left}}
            rightNode = self:parseProjectionRHS(bindingPower.Flatten)
            return {type = "Projection", children = {leftNode, rightNode}}
        end
        ____cond21 = ____cond21 or (____switch21 == Token.TOK_EQ or ____switch21 == Token.TOK_NE or ____switch21 == Token.TOK_GT or ____switch21 == Token.TOK_GTE or ____switch21 == Token.TOK_LT or ____switch21 == Token.TOK_LTE)
        if ____cond21 then
            return self:parseComparator(left, tokenName)
        end
        ____cond21 = ____cond21 or ____switch21 == Token.TOK_LBRACKET
        if ____cond21 then
            token = self:lookaheadToken(0)
            if token.type == Token.TOK_NUMBER or token.type == Token.TOK_COLON then
                right = self:parseIndexExpression()
                return self:projectIfSlice(left, right)
            end
            self:match(Token.TOK_STAR)
            self:match(Token.TOK_RBRACKET)
            right = self:parseProjectionRHS(bindingPower.Star)
            return {type = "Projection", children = {left, right}}
        end
        do
            return self:errorToken(self:lookaheadToken(0))
        end
    until true
end
function TokenParser.prototype.match(self, tokenType)
    if self:lookahead(0) == tokenType then
        self:advance()
        return
    else
        local token = self:lookaheadToken(0)
        self:errorToken(
            token,
            (("Expected " .. tostring(tokenType)) .. ", got: ") .. token.type
        )
    end
end
function TokenParser.prototype.errorToken(self, token, message)
    if message == nil then
        message = ""
    end
    local ____error = __TS__New(
        Error,
        message or ((("Invalid token (" .. token.type) .. "): \"") .. tostring(token.value)) .. "\""
    )
    ____error.name = "ParserError"
    error(____error, 0)
end
function TokenParser.prototype.parseIndexExpression(self)
    if self:lookahead(0) == Token.TOK_COLON or self:lookahead(1) == Token.TOK_COLON then
        return self:parseSliceExpression()
    end
    local node = {
        type = "Index",
        value = self:lookaheadToken(0).value
    }
    self:advance()
    self:match(Token.TOK_RBRACKET)
    return node
end
function TokenParser.prototype.projectIfSlice(self, left, right)
    local indexExpr = {type = "IndexExpression", children = {left, right}}
    if right.type == "Slice" then
        return {
            children = {
                indexExpr,
                self:parseProjectionRHS(bindingPower.Star)
            },
            type = "Projection"
        }
    end
    return indexExpr
end
function TokenParser.prototype.parseSliceExpression(self)
    local parts = {nil, nil, nil}
    local index = 0
    local currentTokenType = self:lookahead(0)
    while currentTokenType ~= Token.TOK_RBRACKET and index < 3 do
        if currentTokenType == Token.TOK_COLON then
            index = index + 1
            self:advance()
        elseif currentTokenType == Token.TOK_NUMBER then
            parts[index + 1] = self:lookaheadToken(0).value
            self:advance()
        else
            local token = self:lookaheadToken(0)
            self:errorToken(
                token,
                ((("Syntax error, unexpected token: " .. tostring(token.value)) .. "(") .. token.type) .. ")"
            )
        end
        currentTokenType = self:lookahead(0)
    end
    self:match(Token.TOK_RBRACKET)
    return {children = parts, type = "Slice"}
end
function TokenParser.prototype.parseComparator(self, left, comparator)
    local right = self:expression(bindingPower[comparator])
    return {type = "Comparator", name = comparator, children = {left, right}}
end

function TokenParser.prototype.parseDotRHS(self, rbp)
    local lookahead = self:lookahead(0)
    local exprTokens = {Token.TOK_UNQUOTEDIDENTIFIER, Token.TOK_QUOTEDIDENTIFIER, Token.TOK_STAR}
    if has_value(exprTokens, lookahead) then
        return self:expression(rbp)
    end
    if lookahead == Token.TOK_LBRACKET then
        self:match(Token.TOK_LBRACKET)
        return self:parseMultiselectList()
    end
    if lookahead == Token.TOK_LBRACE then
        self:match(Token.TOK_LBRACE)
        return self:parseMultiselectHash()
    end
    local token = self:lookaheadToken(0)
    self:errorToken(
        token,
        ((("Syntax error, unexpected token: " .. tostring(token.value)) .. "(") .. token.type) .. ")"
    )
end
function TokenParser.prototype.parseProjectionRHS(self, rbp)
    if bindingPower[self:lookahead(0)] < 10 then
        return {type = "Identity"}
    end
    if self:lookahead(0) == Token.TOK_LBRACKET then
        return self:expression(rbp)
    end
    if self:lookahead(0) == Token.TOK_FILTER then
        return self:expression(rbp)
    end
    if self:lookahead(0) == Token.TOK_DOT then
        self:match(Token.TOK_DOT)
        return self:parseDotRHS(rbp)
    end
    local token = self:lookaheadToken(0)
    self:errorToken(
        token,
        ((("Syntax error, unexpected token: " .. tostring(token.value)) .. "(") .. token.type) .. ")"
    )
end
function TokenParser.prototype.parseMultiselectList(self)
    local expressions = {}
    while self:lookahead(0) ~= Token.TOK_RBRACKET do
        local expression = self:expression(0)
        expressions[#expressions + 1] = expression
        if self:lookahead(0) == Token.TOK_COMMA then
            self:match(Token.TOK_COMMA)
            if self:lookahead(0) == Token.TOK_RBRACKET then
                error(
                    __TS__New(Error, "Unexpected token Rbracket"),
                    0
                )
            end
        end
    end
    self:match(Token.TOK_RBRACKET)
    return {type = "MultiSelectList", children = expressions}
end
function TokenParser.prototype.parseMultiselectHash(self)
    local ____pairs = {}
    local identifierTypes = {Token.TOK_UNQUOTEDIDENTIFIER, Token.TOK_QUOTEDIDENTIFIER}
    local keyToken
    local keyName
    local value
    do
        while true do
            keyToken = self:lookaheadToken(0)
            if not has_value(identifierTypes, keyToken.type) then
                error(
                    __TS__New(
                        Error,
                        "Expecting an identifier token, got: " .. tostring(keyToken.type)
                    ),
                    0
                )
            end
            keyName = keyToken.value
            self:advance()
            self:match(Token.TOK_COLON)
            value = self:expression(0)
            ____pairs[#____pairs + 1] = {value = value, type = "KeyValuePair", name = keyName}
            if self:lookahead(0) == Token.TOK_COMMA then
                self:match(Token.TOK_COMMA)
            elseif self:lookahead(0) == Token.TOK_RBRACE then
                self:match(Token.TOK_RBRACE)
                break
            end
        end
    end
    return {type = "MultiSelectHash", children = ____pairs}
end
____exports.Parser = __TS__New(TokenParser)
____exports.default = ____exports.Parser
return ____exports
