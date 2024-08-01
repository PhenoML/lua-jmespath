local json = require("cjson")
local jmespath = require("lua-jmespath")

function equals(o1, o2, ignore_order)
  if o1 == json.null then o1 = nil end
  if o2 == json.null then o2 = nil end
  if o1 == o2 then return true end
  local o1Type = type(o1)
  local o2Type = type(o2)
  if o1Type ~= o2Type then return false end
  if o1Type ~= 'table' then return false end

  local keySet = {}


  for key1, value1 in pairs(o1) do
    local value2 = o2[key1]
    if value2 == nil or equals(value1, value2, ignore_order) == false then
      return false
    end
    keySet[key1] = true
  end

  for key2, _ in pairs(o2) do
    if not keySet[key2] then return false end
  end
  return true
end

function arrEquals(a, b)
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

function runTest(data, expression, expected, ignore_order)
  ignore_order = ignore_order or false
  local l_data = json.decode(data)
  local l_expected = json.encode(expected)
  local result = jmespath:search(l_data, expression)
  local result_str = json.encode(result)
  print('Epression:\n'..expression)
  print('Expected:\n'..l_expected)
  print('Result:\n'..result_str)
  if (not equals(result, expected, ignore_order)) then
    if (ignore_order == false or not arrEquals(result, expected)) then
      error('Test failed: result doesn\'t match expected value')
    end
  end
  print('PASSED\n')
end

runTest(
  '{"a": "foo", "b": "bar", "c": "baz"}',
  'a',
  'foo',
  false
)

runTest(
  '{"a": {"b": {"c": {"d": "value"}}}}',
  'a.b.c.d',
  'value',
  false
)

runTest(
  '["a", "b", "c", "d", "e", "f"]',
  '[1]',
  'b',
  false
)

runTest(
  '{"a": {"b": {"c": [{"d": [0, [1, 2]]},{"d": [3, 4]}]}}}',
  'a.b.c[0].d[1][0]',
  1,
  false
)

runTest(
  '[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]',
  '[0:5]',
  json.decode('[0,1,2,3,4]'),
  false
)

runTest(
  '[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]',
  '[5:10]',
  json.decode('[5,6,7,8,9]'),
  false
)

runTest(
  '[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]',
  '[:5]',
  json.decode('[0,1,2,3,4]'),
  false
)

runTest(
  '[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]',
  '[::2]',
  json.decode('[0,2,4,6,8]'),
  false
)

runTest(
  '[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]',
  '[::-1]',
  json.decode('[9,8,7,6,5,4,3,2,1,0]'),
  false
)

runTest(
  [[{
    "people": [
      {"first": "James", "last": "d"},
      {"first": "Jacob", "last": "e"},
      {"first": "Jayden", "last": "f"},
      {"missing": "different"}
    ],
    "foo": {"bar": "baz"}
  }]],
  'people[*].first',
  json.decode([=[[
    "James",
    "Jacob",
    "Jayden"
  ]]=]),
  false
)

runTest(
  [[{
    "people": [
      {"first": "James", "last": "d"},
      {"first": "Jacob", "last": "e"},
      {"first": "Jayden", "last": "f"},
      {"missing": "different"}
    ],
    "foo": {"bar": "baz"}
  }]],
  'people[:2].first',
  json.decode([=[[
    "James",
    "Jacob"
  ]]=]),
  false
)

runTest(
  [[{
    "ops": {
      "functionA": {"numArgs": 2},
      "functionB": {"numArgs": 3},
      "functionC": {"variadic": true}
    }
  }]],
  'ops.*.numArgs',
  json.decode('[2,3]'),
  true
)

runTest(
  [[{
    "reservations": [
      {
        "instances": [
          {"state": "running"},
          {"state": "stopped"}
        ]
      },
      {
        "instances": [
          {"state": "terminated"},
          {"state": "running"}
        ]
      }
    ]
  }]],
  'reservations[*].instances[*].state',
  json.decode([=[[
    [
      "running",
      "stopped"
    ],
    [
      "terminated",
      "running"
    ]
  ]]=]),
  true
)

runTest(
  [=[[
    [0, 1],
    2,
    [3],
    4,
    [5, [6, 7]]
  ]]=],
  '[]',
  json.decode([=[[
    0,
    1,
    2,
    3,
    4,
    5,
    [
      6,
      7
    ]
  ]]=]),
  false
)

runTest(
  [[{
    "machines": [
      {"name": "a", "state": "running"},
      {"name": "b", "state": "stopped"},
      {"name": "c", "state": "running"}
    ]
  }]],
  'machines[?state==\'running\'].name',
  json.decode('["a","c"]'),
  false
)

runTest(
  [[{
    "people": [
      {"first": "James", "last": "d"},
      {"first": "Jacob", "last": "e"},
      {"first": "Jayden", "last": "f"},
      {"missing": "different"}
    ],
    "foo": {"bar": "baz"}
  }]],
  'people[*].first | [0]',
  'James',
  false
)

runTest(
  [[{
    "people": [
      {
        "name": "a",
        "state": {"name": "up"}
      },
      {
        "name": "b",
        "state": {"name": "down"}
      },
      {
        "name": "c",
        "state": {"name": "up"}
      }
    ]
  }]],
  'people[].[name, state.name]',
  json.decode([=[[
    [
      "a",
      "up"
    ],
    [
      "b",
      "down"
    ],
    [
      "c",
      "up"
    ]
  ]]=]),
  false
)

runTest(
  [[{
    "people": [
      {
        "name": "a",
        "state": {"name": "up"}
      },
      {
        "name": "b",
        "state": {"name": "down"}
      },
      {
        "name": "c",
        "state": {"name": "up"}
      }
    ]
  }]],
  'people[].{Name: name, State: state.name}',
  json.decode([=[[
    {
      "Name": "a",
      "State": "up"
    },
    {
      "Name": "b",
      "State": "down"
    },
    {
      "Name": "c",
      "State": "up"
    }
  ]]=]),
  false
)

runTest(
  [[{
    "people": [
      {
        "name": "b",
        "age": 30,
        "state": {"name": "up"}
      },
      {
        "name": "a",
        "age": 50,
        "state": {"name": "down"}
      },
      {
        "name": "c",
        "age": 40,
        "state": {"name": "up"}
      }
    ]
  }]],
  'length(people)',
  3,
  false
)

runTest(
  [[{
    "people": [
      {
        "name": "b",
        "age": 30
      },
      {
        "name": "a",
        "age": 50
      },
      {
        "name": "c",
        "age": 40
      }
    ]
  }]],
  'max_by(people, &age).name',
  'a',
  false
)

runTest(
  [[{
    "myarray": [
      "foo",
      "foobar",
      "barfoo",
      "bar",
      "baz",
      "barbaz",
      "barfoobaz"
    ]
  }]],
  'myarray[?contains(@, \'foo\') == `true`]',
  json.decode('["foo","foobar","barfoo","barfoobaz"]'),
  false
)

runTest(
  [[{
    "myarray": [
      "foo",
      "foobar",
      "barfoo",
      "bar",
      "baz",
      "barbaz",
      "barfoobaz"
    ]
  }]],
  'myarray[?contains(@, \'foor\') == `true`]',
  json.decode('[]'),
  false
)

runTest(
  '["1", "2", "3", "notanumber", true]',
  '[].to_number(@)',
  json.decode('[1,2,3]'),
  false
)

runTest(
  '{"foo": -1, "bar": "2"}',
  'abs(foo)',
  1,
  false
)

runTest(
  '{"foo": -1, "bar": "2"}',
  'abs(to_number(bar))',
  2,
  false
)

runTest(
  '[10, 15, 20]',
  'avg(@)',
  15,
  false
)

runTest(
  '{}',
  'contains(\'foobar\', \'foo\')',
  true,
  false
)

runTest(
  '{}',
  'contains(\'foobar\', \'not\')',
  false,
  false
)

runTest(
  '{}',
  'contains(\'foobar\', \'bar\')',
  true,
  false
)

runTest(
  '["a", "b"]',
  'contains(@, \'a\')',
  true,
  false
)

runTest(
  '{}',
  'ceil(`1.001`)',
  2,
  false
)

runTest(
  '"foobarbaz"',
  'ends_with(@, \'baz\')',
  true,
  false
)

runTest(
  '"foobarbaz"',
  'ends_with(@, \'foo\')',
  false,
  false
)

runTest(
  '"foobarbaz"',
  'ends_with(@, \'z\')',
  true,
  false
)

runTest(
  '{}',
  'floor(`1.001`)',
  1,
  false
)

runTest(
  '{}',
  'floor(`1.999`)',
  1,
  false
)

runTest(
  '["a", "b"]',
  'join(\', \', @)',
  'a, b',
  false
)

runTest(
  '["a", "b"]',
  'join(\'\', @)',
  'ab',
  false
)

runTest(
  '{"foo": "baz", "bar": "bam"}',
  'keys(@)',
  json.decode('["foo", "bar"]'),
  true
)

runTest(
  '{}',
  'keys(@)',
  json.decode('[]'),
  true
)

runTest(
  '{}',
  'length(\'abc\')',
  3,
  false
)

runTest(
  '"current"',
  'length(@)',
  7,
  false
)

runTest(
  '["a", "b", "c"]',
  'length(@)',
  3,
  false
)

runTest(
  '[]',
  'length(@)',
  0,
  false
)

runTest(
  '{}',
  'length(@)',
  0,
  false
)

runTest(
  '{"foo": "bar", "baz": "bam"}',
  'length(@)',
  2,
  false
)

runTest(
  '{"array": [{"foo": "a"}, {"foo": "b"}, {}, [], {"foo": "f"}]}',
  'map(&foo, array)',
  json.decode('["a", "b", null, null, "f"]'),
  false
)

runTest(
  '[[1, 2, 3, [4]], [5, 6, 7, [8, 9]]]',
  'map(&length(@), @)',
  json.decode('[4, 4]'),
  false
)

runTest(
  '[[1, 2, 3, [4]], [5, 6, 7, [8, 9]]]',
  'map(&[], @)',
  json.decode('[[1, 2, 3, 4], [5, 6, 7, 8, 9]]'),
  false
)

runTest(
  '[10, 15]',
  'max(@)',
  15,
  false
)

runTest(
  '["a", "b", "c", "z", "d", "e"]',
  'max(@)',
  'z',
  false
)

runTest(
  [[{
    "people": [
      {"age": 50, "age_str": "50", "bool": false, "name": "d"},
      {"age": 30, "age_str": "30", "bool": true, "name": "e"},
      {"age": 40, "age_str": "40", "bool": false, "name": "f"}
    ]
  }]],
  'max_by(people, &age)',
  json.decode('{"age": 50, "age_str": "50", "bool": false, "name": "d"}'),
  false
)

runTest(
  [[{
    "people": [
      {"age": 50, "age_str": "50", "bool": false, "name": "d"},
      {"age": 30, "age_str": "30", "bool": true, "name": "e"},
      {"age": 40, "age_str": "40", "bool": false, "name": "f"}
    ]
  }]],
  'max_by(people, &age).age',
  50,
  false
)

runTest(
  [[{
    "people": [
      {"age": 50, "age_str": "50", "bool": false, "name": "d"},
      {"age": 30, "age_str": "30", "bool": true, "name": "e"},
      {"age": 40, "age_str": "40", "bool": false, "name": "f"}
    ]
  }]],
  'max_by(people, &to_number(age_str))',
  json.decode('{"age": 50, "age_str": "50", "bool": false, "name": "d"}'),
  false
)

runTest(
  '{}',
  'merge(`{"a": "b"}`, `{"c": "d"}`)',
  json.decode('{"a": "b", "c": "d"}'),
  false
)

runTest(
  '{}',
  'merge(`{"a": "b"}`, `{"a": "override"}`)',
  json.decode('{"a": "override"}'),
  false
)

runTest(
  '{}',
  'merge(`{"a": "x", "b": "y"}`, `{"b": "override", "c": "z"}`)',
  json.decode('{"a": "x", "b": "override", "c": "z"}'),
  false
)


runTest(
  '{"a": "x", "b": "y"}',
  'merge(@, `{"b": "override", "c": "z"}`)',
  json.decode('{"a": "x", "b": "override", "c": "z"}'),
  false
)

runTest(
  '[10, 15]',
  'min(@)',
  10,
  false
)

runTest(
  '["a", "b"]',
  'min(@)',
  'a',
  false
)

runTest(
  [[{
    "people": [
      {"age": 50, "age_str": "50", "bool": false, "name": "d"},
      {"age": 30, "age_str": "30", "bool": true, "name": "e"},
      {"age": 40, "age_str": "40", "bool": false, "name": "f"}
    ]
  }]],
  'min_by(people, &age)',
  json.decode('{"age": 30, "age_str": "30", "bool": true, "name": "e"}'),
  false
)

runTest(
  [[{
    "people": [
      {"age": 50, "age_str": "50", "bool": false, "name": "d"},
      {"age": 30, "age_str": "30", "bool": true, "name": "e"},
      {"age": 40, "age_str": "40", "bool": false, "name": "f"}
    ]
  }]],
  'min_by(people, &age).age',
  30,
  false
)

runTest(
  [[{
    "people": [
      {"age": 50, "age_str": "50", "bool": false, "name": "d"},
      {"age": 30, "age_str": "30", "bool": true, "name": "e"},
      {"age": 40, "age_str": "40", "bool": false, "name": "f"}
    ]
  }]],
  'min_by(people, &to_number(age_str))',
  json.decode('{"age": 30, "age_str": "30", "bool": true, "name": "e"}'),
  false
)

runTest(
  '{"a": null, "b": null, "c": [], "d": "foo"}',
  'not_null(no_exist, a, b, c, d)',
  json.decode('[]'),
  true
)

runTest(
  '{"a": null, "b": null, "c": [], "d": "foo"}',
  'not_null(a, b, `null`, d, c)',
  'foo',
  true
)

runTest(
  '{"a": null, "b": null, "c": [], "d": "foo"}',
  'not_null(a, b)',
  nil,
  true
)

runTest(
  '[0, 1, 2, 3, 4]',
  'reverse(@)',
  json.decode('[4,3,2,1,0]'),
  false
)

runTest(
  '[]',
  'reverse(@)',
  json.decode('[]'),
  false
)

runTest(
  '["a", "b", "c", 1, 2, 3]',
  'reverse(@)',
  json.decode('[3,2,1,"c","b","a"]'),
  false
)

runTest(
  '"abcd"',
  'reverse(@)',
  'dcba',
  false
)

runTest(
  '["b", "a", "c"]',
  'sort(@)',
  json.decode('["a", "b", "c"]'),
  false
)

runTest(
  '[9, 4, 6, 2, 8]',
  'sort(@)',
  json.decode('[2, 4, 6, 8, 9]'),
  false
)

runTest(
  [[{
    "people": [
      {"age": 50, "age_str": "50", "bool": false, "name": "d"},
      {"age": 30, "age_str": "30", "bool": true, "name": "e"},
      {"age": 40, "age_str": "40", "bool": false, "name": "f"}
    ]
  }]],
  'sort_by(people, &age)[].age',
  json.decode('[30, 40, 50]'),
  false
)

runTest(
  [[{
    "people": [
      {"age": 50, "age_str": "50", "bool": false, "name": "d"},
      {"age": 30, "age_str": "30", "bool": true, "name": "e"},
      {"age": 40, "age_str": "40", "bool": false, "name": "f"}
    ]
  }]],
  'sort_by(people, &age)[].name',
  json.decode('["e","f","d"]'),
  false
)

runTest(
  [[{
    "people": [
      {"age": 50, "age_str": "50", "bool": false, "name": "d"},
      {"age": 30, "age_str": "30", "bool": true, "name": "e"},
      {"age": 40, "age_str": "40", "bool": false, "name": "f"}
    ]
  }]],
  'sort_by(people, &age)[0]',
  json.decode('{"age": 30, "age_str": "30", "bool": true, "name": "e"}'),
  false
)

runTest(
  [[{
    "people": [
      {"age": 50, "age_str": "50", "bool": false, "name": "d"},
      {"age": 30, "age_str": "30", "bool": true, "name": "e"},
      {"age": 40, "age_str": "40", "bool": false, "name": "f"}
    ]
  }]],
  'sort_by(people, &to_number(age_str))[0]',
  json.decode('{"age": 30, "age_str": "30", "bool": true, "name": "e"}'),
  false
)

runTest(
  '"foobarbaz"',
  'starts_with(@, \'foo\')',
  true,
  false
)

runTest(
  '"foobarbaz"',
  'starts_with(@, \'baz\')',
  false,
  false
)

runTest(
  '"foobarbaz"',
  'starts_with(@, \'f\')',
  true,
  false
)

runTest(
  '[10, 15]',
  'sum(@)',
  25,
  false
)

runTest(
  '[10, false, 20]',
  'sum([].to_number(@))',
  30,
  false
)

runTest(
  '[]',
  'sum(@)',
  0,
  false
)

runTest(
  '{}',
  'to_array(`[1, 2]`)',
  json.decode('[1, 2]'),
  false
)

runTest(
  '{}',
  'to_array(`"string"`)',
  json.decode('["string"]'),
  false
)

runTest(
  '{}',
  'to_array(`0`)',
  json.decode('[0]'),
  false
)

runTest(
  '{}',
  'to_array(`true`)',
  json.decode('[true]'),
  false
)

runTest(
  '{}',
  'to_array(`{"foo": "bar"}`)',
  json.decode('[{"foo": "bar"}]'),
  false
)

runTest(
  '{}',
  'to_string(`2`)',
  '2',
  false
)

runTest(
  '"foo"',
  'type(@)',
  'string',
  false
)

runTest(
  'true',
  'type(@)',
  'boolean',
  false
)

runTest(
  'false',
  'type(@)',
  'boolean',
  false
)

runTest(
  'null',
  'type(@)',
  'null',
  false
)

runTest(
  '123',
  'type(@)',
  'number',
  false
)

runTest(
  '123.05',
  'type(@)',
  'number',
  false
)

runTest(
  '["abc"]',
  'type(@)',
  'array',
  false
)

runTest(
  '{"abc": "123"}',
  'type(@)',
  'object',
  false
)

runTest(
  '{}',
  'values(@)',
  json.decode('[]'),
  true
)

runTest(
  '{"foo": "baz", "bar": "bam"}',
  'values(@)',
  json.decode('["baz", "bam"]'),
  true
)

runTest(
  '{"foo": "foo-value"}',
  'foo || bar',
  'foo-value',
  false
)

runTest(
  '{"bar": "bar-value"}',
  'foo || bar',
  'bar-value',
  false
)

runTest(
  '{"foo": "foo-value", "bar": "bar-value"}',
  'foo || bar',
  'foo-value',
  false
)

runTest(
  '{"baz": "baz-value"}',
  'foo || bar',
  nil,
  false
)

runTest(
  '{"baz": "baz-value"}',
  'foo || bar || baz',
  'baz-value',
  false
)

runTest(
  '{"mylist": ["one", "two"]}',
  'override || mylist[-1]',
  'two',
  false
)

runTest(
  '{"mylist": ["one", "two"], "override": "yes"}',
  'override || mylist[-1]',
  'yes',
  false
)

runTest(
  '{"foo": [{"bar": ["first1", "second1"]}, {"bar": ["first2", "second2"]}]}',
  'foo[*].bar | [0]',
  json.decode('["first1", "second1"]'),
  false
)

runTest(
[[{
      "foo": {
          "bar": {
              "baz": "one"
          },
          "other": {
              "baz": "two"
          },
          "other2": {
              "baz": "three"
          },
          "other3": {
              "notbaz": ["a", "b", "c"]
          },
          "other4": {
              "notbaz": ["d", "e", "f"]
          },
          "other5": {
              "other": {
                  "a": 1,
                  "b": 2,
                  "c": 3
              }
          }
      }
  }]],
  'foo.*.baz',
  json.decode('["one", "two", "three"]'),
  true
)

runTest(
  [[{
      "foo": {
          "bar": {
              "baz": "one"
          },
          "other": {
              "baz": "two"
          },
          "other2": {
              "baz": "three"
          },
          "other3": {
              "notbaz": ["a", "b", "c"]
          },
          "other4": {
              "notbaz": ["d", "e", "f"]
          },
          "other5": {
              "other": {
                  "a": 1,
                  "b": 2,
                  "c": 3
              }
          }
      }
  }]],
  'foo.*.*.*',
  json.decode('[[], [], [], [], [], [[1, 2, 3]]]'),
  true
)

runTest(
  [[{
      "foo": [{"top": {"first": "foo", "last": "bar"}},
      {"top": {"first": "foo", "last": "foo"}},
      {"top": {"first": "foo", "last": "baz"}}]
  }]],
  'foo[?top == `{"first": "foo", "last": "bar"}`]',
  json.decode('[{"top": {"first": "foo", "last": "bar"}}]'),
  false
)

runTest(
  [[{
      "foo": {
        "bar": "bar",
        "baz": "baz",
        "qux": "qux"
      },
      "bar": 1,
      "baz": 2,
      "qux": 3
    }]],
  'foo.badkey.{nokey: nokey, alsonokey: alsonokey}',
  nil,
  false
)
