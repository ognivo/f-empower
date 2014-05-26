# F-EMPOWER
## Utility functions designed for functional programming and composition
Written with V8's optimizing copiler (Crankshaft) in mind (functional monomorphism is emphasized).

Inspired by Clojure and Underscore.

CommonJS and AMD loaders are supported.

## Install
`npm install f-empower`

## Use
### NodeJS
```coffeescript
functions = require "f-empower"
{ apply
  bind }  = functions
array1 = [ 1, 2, 3 ]
push_to_array1 = (bind array1.push, array1)

(apply push_to_array1, [ 4, 5, 6 ])
console.log(array1) # -> [ 1, 2, 3, 4, 5, 6 ]
```
### Browser (require.js)
```coffeescript
require.config
  paths:
    'f-empower': 'path/to/f-empower'

define [ 'f-empower' ], (functions) ->
  { apply
    bind }  = functions
  array1 = [ 1, 2, 3 ]
  push_to_array1 = (bind array1.push, array1)

  (apply push_to_array1, [ 4, 5, 6 ])
  console.log(array1) # -> [ 1, 2, 3, 4, 5, 6 ]
```

## Compared to Underscore / Lodash
As a new thing f-empower doesn't have the functional multitude of Lodash or Underscore.
This is not (and won't be) a template library. Although it has `jquery_wrap_to_array` 
which converts a jQuery wrap, into array of jQuery wraps.

It is not so polished in terms of speed as Lodash. Although it respects functional 
monomorphism.

It is much closer to Clojure.

### Features not in Underscore
- `map`, `each`. `map` and `each` work with any number of arrays.
- `clonedeep2`, `merge` -- operate on deep structures, staying non-recursive.

## Function index
- a_contains   : (arr, item) array first `contains`, like in underscore, tests reference equality
- a_each       : (arr, fn) array first `each`, works with only one collection
- a_filter     : (arr, fn) array first `filter`
- a_map        : (arr, fn) array first `map`, works with only one collection
- a_reduce     : (arr, fn) | (arr, fn, val) array first `reduce`
- a_reject     : (arr, fn) array first `reject`
- a_sum        : (Array<number>) sum of array
- and2         : (a, b) -> a && b
- apply        : (fn, args...) applies arguments to function
- assign       : (dest, src...) assigns all src objects to dest object
- bind         : (fn, this_arg) simplified bind function, like makeCallback in lodash or bindJS in Closure
- butlast      : (arr) slice all but last elements of array
- cat          : (arrays..) concatenate arrays
- clone
- clonedeep    : deep clone for data structures, able to clone structures with circular references
- clonedeep2   : deep clone without recursion, able to clone very deep structures with circular references
- compact      : (arr) returns new version of the array without elements that evaluate to falsee
- compose      : (fn...) composes functions
- complement   : (predicate_fn) inverts predicate function
- contains     : (item, arr) tests array if it contains the item
- count        : (array_like) reads `length` property of something
- debounce     : (debounce_timeout, fn)
- defaults     : (dest, src...)
- delay        : (delay_ms, fn) like `setTimeout`, but the delay parameter is specified before fn
- drop         : (x, arr) drops first x items from array
- each         : (fn, arr...)
- extend       -> assign
- fastbind     -> bind
- filter       : (criteria(fn/obj/string), arr)
- first        : (arr)
- flow         : natural compose
- jquery_wrap_to_array : maps jquery wrapped array into array of jquery wrapped elements
- head         : (x, string) takes first x chars from string
- index_of     : (item, arr)
- invoke       : (method_name, method_args..., arr)
- is_array     : predicate that tests if object is array
- is_defined   :
- is_empty     : (array_like) checks some array like thing for length == 0
- is_function  :
- is_number    :
- is_object    :
- is_plain_object : (item) tests item for being plain object
- is_zero      : (num)
- keys         : (obj) returns keys of object
- last         : (arr) returns last item from array
- list         : (items...) returns an array composed from items, like `Array(1, 2, 3) # -> [1, 2, 3]`
- list_compact : list and compact functions composed. Equal to (compact (list args...))
- merge        : (dest, src) deep non-recursive merge of two objects
- o_map        : (obj, keys_list) hash based mapping function `(o_map {age: 35}, ['age']) # -> [ 35 ]`
- o_match      : (criteria_object, matched_object) checks properties of matched_object to match every
property inside criteria_object.
- map          : (fn, arrs...)
- match        : (str, regexp)
- mk_regexp    : (regex_str, regex_options_str)
- multicall    : (functions...) returns a function that will call the all of the functions, when called
- no_operation : function that does nothing, and returns undefined
- noop -> no_operation
- not_array    : 
- not_defined  :
- not_empty    :
- not_function : 
- not_number   :
- not_object   : 
- not_zero     :
- partial      : (fn, args...)
- pipeline -> flow
- pluck        : (key, arr)
- pull         : (key, obj) deletes the key from object and returns it
- push         : (arr, item)
- range        : (start_val, end_val, step)
- read         : (key, obj) - will read a property with specified name
- recurse      : (fn(son, parent, son_idx, son_depth), root, depth) recurses a tree where 
- reduce       : (fn, arr) | (fn, val, arr)
- reject       : (fn, arr)
- repeat       : (times, val)
- rest         : (arr) return all but first elements
- remap        : (fn, arr) rewrites each element in array, using fn
- remove       : (item, arr) removes item from array based on reference equality
- remove_at    : (idx, arr) removes and returns one element at specified index from array
- second       : (array_like)
- set_difference : (arr1, arr2) -> items of first array which are not present in second array
- set_symmetric_difference (arr1, arr2) -> [(set_difference arr1, arr2), (set_difference arr2, arr1)]
- slice        : (arr [, start_idx, end_idx]) same as standard JS slice
- space        : (strings...) join strings with a whitespace
- splice       : (arr [, start_idx, remove_count, new_elements...])
- str          : (strings...) - join any number of strings into one
- str_breplace : (replace_map, string) - string bulk character replace.
Given english to russian characters map `{ 'a': 'ф', 'b': 'и', 'f': 'а' }`,
and string `'bafbaffab'` will output `'ифаифаафи'`.
- str_join     : (join_str, Array<string>)
- str_split    : (split_str, string_to_split)
- take         : (x, arr) takes first x items from array
- tail         : (x, string) drops first chars from string
- throttle     : (throttle_ms, fn)
- unshift      : (arr, item)
- varynum      : (numbers_arr, start_with_one)
- vals         : (obj) returns the list of object's values

## License : MIT
