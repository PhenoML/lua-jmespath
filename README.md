# lua-jmespath

A Lua implementation of JMESPath, a query language for JSON.
This is a port from the [deno implementation](https://deno.land/x/jmespath) of JMESPath.

This port solves some of the issues with the [original implementation](https://github.com/jmespath/jmespath.lua),
such as incomplete support for empty arrays, in all cases the original implementation
would return an empty table instead of an empty array. While in Lua an empty table is also
the representation of an empty array, it should be possible to differentiate between the two
when encoding back to JSON.

A tradeoff of this port is that it inherits Lua's table key management, where keys are not
guaranteed to maintain the same order as they were inserted. This means that the order of
keys in the output JSON may not be the same as the input JSON. It also means that given the
following input:
```json
{
  "a": 1,
  "b": 2,
  "c": 3
}
```
the following expression:
```
*[0]
```
is not guaranteed to return the value `1`, as the order of keys in the table is not guaranteed.


## Testing

lua-jmespath is tested using [busted](http://olivinelabs.com/busted>). You'll
need to install busted and luafilesystem to run the tests:
```
make test-setup
```
After installing jmespath.lua, you can run the tests with the following
command:
```
make test
```

# deno.land/x/jmespath README below

A jmespath-ts fork, repackaged and ported to Deno.
The `src/` directory is published to deno.land.
The `test/` directory contains the upstream unit tests.

This library should be useful for JSON-heavy APIs such as AWS.

In the process of porting,
I changed the AST types to leverage descriminated unions,
in order to reduce usage of casts and any.
The original library used a tsconfig to disable some implicit-any checks
which isn't acceptable in deno libraries.

Since then, upstream has also improved their typing,
so the difference between this fork and upstream is somewhat smaller now.


# Original README below

@metrichor/jmespath is a **typescript** implementation of the [JMESPath](https://jmespath.org) spec.

JMESPath is a query language for JSON. It will take a JSON document
as input and transform it into another JSON document
given a JMESPath expression.

## INSTALLATION

```
npm install @metrichor/jmespath
```

## USAGE

### `search(data: JSONValue, expression: string): JSONValue`

```javascript
/* using ES modules */
import { search } from '@metrichor/jmespath';


/* using CommonJS modules */
const search = require('@metrichor/jmespath').search;


search({foo: {bar: {baz: [0, 1, 2, 3, 4]}}}, "foo.bar.baz[2]")

// OUTPUTS: 2

```

In the example we gave the `search` function input data of
`{foo: {bar: {baz: [0, 1, 2, 3, 4]}}}` as well as the JMESPath
expression `foo.bar.baz[2]`, and the `search` function evaluated
the expression against the input data to produce the result `2`.

The JMESPath language can do *a lot* more than select an element
from a list.  Here are a few more examples:

```javascript
import { search } from '@metrichor/jmespath';

/* --- EXAMPLE 1 --- */

let JSON_DOCUMENT = {
  foo: {
    bar: {
      baz: [0, 1, 2, 3, 4]
    }
  }
};

search(JSON_DOCUMENT, "foo.bar");
// OUTPUTS: { baz: [ 0, 1, 2, 3, 4 ] }


/* --- EXAMPLE 2 --- */

JSON_DOCUMENT = {
  "foo": [
    {"first": "a", "last": "b"},
    {"first": "c", "last": "d"}
  ]
};

search(JSON_DOCUMENT, "foo[*].first")
// OUTPUTS: [ 'a', 'c' ]


/* --- EXAMPLE 3 --- */

JSON_DOCUMENT = {
  "foo": [
    {"age": 20},
    {"age": 25},
    {"age": 30},
    {"age": 35},
    {"age": 40}
  ]
}

search(JSON_DOCUMENT, "foo[?age > `30`]");
// OUTPUTS: [ { age: 35 }, { age: 40 } ]
```

### `compile(expression: string): ASTNode`

You can precompile all your expressions ready for use later on. the `compile`
function takes a JMESPath expression and returns an abstract syntax tree that
can be used by the TreeInterpreter function

```javascript
import { compile, TreeInterpreter } from '@metrichor/jmespath';

const ast = compile('foo.bar');

TreeInterpreter.search(ast, {foo: {bar: 'BAZ'}})
// RETURNS: "BAZ"

```

---
## EXTENSIONS TO ORIGINAL SPEC

1. ### Register you own custom functions

    #### `registerFunction(functionName: string, customFunction: RuntimeFunction, signature: InputSignature[]): void`

    Extend the list of built in JMESpath expressions with your own functions.

    ```javascript
      import {search, registerFunction, TYPE_NUMBER} from '@metrichor/jmespath'


      search({ foo: 60, bar: 10 }, 'divide(foo, bar)')
      // THROWS ERROR: Error: Unknown function: divide()

      registerFunction(
        'divide', // FUNCTION NAME
        (resolvedArgs) => {   // CUSTOM FUNCTION
          const [dividend, divisor] = resolvedArgs;
          return dividend / divisor;
        },
        [{ types: [TYPE_NUMBER] }, { types: [TYPE_NUMBER] }] //SIGNATURE
      );

      search({ foo: 60,bar: 10 }, 'divide(foo, bar)');
      // OUTPUTS: 6

    ```

    Optional arguments are supported by setting `{..., optional: true}` in argument signatures


    ```javascript

      registerFunction(
        'divide',
        (resolvedArgs) => {
          const [dividend, divisor] = resolvedArgs;
          return dividend / divisor ?? 1; //OPTIONAL DIVISOR THAT DEFAULTS TO 1
        },
        [{ types: [TYPE_NUMBER] }, { types: [TYPE_NUMBER], optional: true }] //SIGNATURE
      );

      search({ foo: 60, bar: 10 }, 'divide(foo)');
      // OUTPUTS: 60

    ```

2. ### Root value access with `$` symbol

```javascript

search({foo: {bar: 999}, baz: [1, 2, 3]}, '$.baz[*].[@, $.foo.bar]')

// OUTPUTS:
// [ [ 1, 999 ], [ 2, 999 ], [ 3, 999 ] ]
```


## More Resources

The example above only show a small amount of what
a JMESPath expression can do. If you want to take a
tour of the language, the *best* place to go is the
[JMESPath Tutorial](http://jmespath.org/tutorial.html).

One of the best things about JMESPath is that it is
implemented in many different programming languages including
python, ruby, php, lua, etc.  To see a complete list of libraries,
check out the [JMESPath libraries page](http://jmespath.org/libraries.html).

And finally, the full JMESPath specification can be found
on the [JMESPath site](http://jmespath.org/specification.html).
