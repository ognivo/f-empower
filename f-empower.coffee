###
  F-EMPOWER
  A set of functions to harness the power and benefits of functional
  programming in JS.
  Author: Ivan Fedorov <sharp.maestro@gmail.com>
  License: MIT
###
wrapper = ->

  Errors =
    NO_KEY_VALUE_PAIR_IN_HASH : new Error('No key value pair in a criterion hash')
    NOT_FUNCTION              : new TypeError('Something is not function')
    UNEXPECTED_TYPE           : new TypeError('Unexpected type')
  
  native_slice = Array::slice

  slice = (array_or_arguments, start_idx, end_idx) ->
    native_slice.call(array_or_arguments, start_idx, end_idx)

  bind = (fn, this_arg) -> # TODO make dumb
    other_args = (slice arguments, 2)
    arguments.length <= 2 &&
      (-> fn.apply(this_arg, arguments)) ||
      (-> fn.apply(this_arg, other_args.concat((slice arguments))))

  partial = ->
    fn = arguments[0]
    args = (slice arguments, 1)
    ->
      fn.apply(null, args.concat((slice arguments)))

  
  # ============================================================
  # CATEGORY: FUNCTIONAL
  # ============================================================

  # Calls a function with specified args list
  apply = (fn, args_list) ->
    fn.apply(null, args_list)

  # Composes a list of functions into one
  compose = ->
    functions = arguments
    # PRAGMA DEV
    for item in functions
      if (not_function item)
        throw Errors.NOT_FUNCTION
    # /PRAGMA DEV
    ->
      memo = arguments
      i = functions.length
      while --i >= 0
        memo = [ functions[i].apply(null, memo) ]
      (first memo)
  
  complement = (predicate) ->
    ->
      !(apply predicate, arguments)

  flow = ->
    functions = arguments
    # PRAGMA DEV
    for item in functions
      if (not_function item)
        throw Errors.NOT_FUNCTION
    # /PRAGMA DEV
    ->
      memo = arguments
      len = functions.length
      i = -1
      while ++i < len
        memo = [ functions[i].apply(null, memo) ]
      (first memo)

  no_operation = ->

  # ============================================================
  # CATEGORY: PREDICATES
  # ============================================================

  is_array = Array.isArray

  is_empty = (seq) ->
    seq.length == 0

  is_function = (candidate) ->
    'function' == typeof candidate

  is_object = (candidate) ->
    'object' == typeof candidate

  is_zero = (candidate) ->
    candidate == 0

  not_array = (complement is_array)

  not_empty = (complement is_empty)

  not_function = (complement is_function)

  not_object = (complement is_object)

  not_zero = (complement is_zero)

  # ============================================================
  # CATEGORY: ARRAYS
  # ============================================================

  # TODO objective filter, reject, find
  # TODO property filter, reject, find

  butlast = (array) ->
    (slice array, 0, array.length - 1)
  
  # TODO check arguments
  cat = (array) ->
    array.concat.apply(array, (slice arguments, 1))

  contains = (searched_item, array) ->
    for item in array
      if searched_item == item
        return true
    false

  a_contains = (array, searched_item) ->
    for item in array
      if searched_item == item
        return true
    false

  a_each = (array, fn) ->
    (each fn, array)

  a_filter = (array, fn) ->
    (filter fn, array)

  a_index_of = (array, item) ->
    array.indexOf(item)

  a_map = (array, fn) ->
    (map fn, array)

  a_reduce = (array, fn, val) ->
    (reduce fn, val, array)

  a_reject = (array, fn) ->
    (reject fn, array)

  compact = (coll) ->
    item for item in coll when item
    
  count = (array) ->
    array.length

  each = (fn, array) ->
    for item in array
      (fn item)
    return

  first = (array) ->
    array[0]


  # ARRAY FILTERING FUNCTIONS
  filter_fn = (fn, array) ->
    item for item in array when (fn item)

  filter_prop = (prop_name, array) ->
    item for item in array when !!item[prop_name]

  filter_obj_1kv = (obj, array) ->
    [key, val] = (read_1kv obj)
    item for item in array when item[key] == val

  filter_obj_2kv = (obj, array) ->
    [key1, key2] = (keys obj)
    [val1, val2] = [obj[key1], obj[key2]]
    item for item in array when item[key1] == val1 && item[key2] == val2

  filter_obj = (obj, array) ->
    item for item in array when (o_match obj, item)

  filter = (some_criteria, array) ->
    switch (typeof some_criteria)
      when "string"
        (filter_prop some_criteria, array)
      when "function"
        (filter_fn some, array)
      when "object"
        switch (count (keys some_criteria))
          when 0
            throw Errors.NO_KEY_VALUE_PAIR_IN_HASH
          when 1
            (filter_obj_1kv some_criteria, array)
          when 2
            (filter_obj_2kv some_criteria, array)
          else
            (filter_obj some_criteria, array)
      else
        throw Errors.UNEXPECTED_TYPE
  
  find_index_fn = (fn, array) ->
    for item, idx in array
      if (fn item)
        return idx
    -1

  find_index_prop = (prop_name, array) ->
    for item, idx in array
      if item[prop_name]
        return idx
    -1

  find_index_obj_1kv = (obj_with_1kv_pair, array) ->
    [key, val] = (read_1kv obj_with_1kv_pair)
    for item, idx in array
      if item[key] == val
        return idx
    -1

  find_index_obj_2kv = (obj_with_2kv_pair, array) ->
    [key1, key2] = (keys obj_with_2kv_pair)
    [val1, val2] = [obj_with_2kv_pair[key1], obj_with_2kv_pair[key2]]
    for item, idx in array
      if item[key1] == val1 && item[key2] == val2
        return idx
    -1

  find_index_obj = (obj, array) ->
    for item, idx in array
      if (o_match obj, item)
        return idx
    -1

  find_index = (some_criteria, array) ->
    switch (typeof some_criteria)
      when "string"
        (find_index_prop some_criteria, array)
      when "function"
        (find_index_fn some_criteria, array)
      when "object"
        switch (count (keys some_criteria))
          when 0
            throw Errors.NO_KEY_VALUE_PAIR_IN_HASH
          when 1
            (find_index_obj_1kv some_criteria, array)
          when 2
            (find_index_obj_2kv some_criteria, array)
          else
            (find_index_obj some_criteria, array)
      else
        throw Errors.UNEXPECTED_TYPE

  find = (some_criteria, array) ->
    item_idx = (find_index some_criteria, array)
    return  if item_idx == -1
    (read item_idx, array)

  index_of = (item, array) ->
    array.indexOf(item)

  last = (list) ->
    list[list.length - 1]

  list = (args...) ->
    args

  # Produces list from arguments and then applies compact
  # function (which removes all falsies)
  list_compact = ->
    result = []
    for arg in arguments
      if !!arg
        result.push(arg)
    result

  map = (fn, array) ->
    for item in array
      (fn item)

  not_contains = (complement contains)

  reduce = (fn, val, array) ->
    idx = -1
    if !array && (is_array val)
      array = val
      val = (fn array[0], array[1])
      idx = 1

    while ++idx < array.length
      val = (fn val, array[idx])

    val

  reject_fn = (fn, array) ->
    item for item in array when !(fn item)

  reject_prop = (prop_name, array) ->
    item for item in array when !item[prop_name]

  reject_obj_1kv = (one_kv_pair_object, array) ->
    [key, val] = (read_1kv one_kv_pair_object)
    item for item in array when item[key] != val

  reject_obj_2kv = (two_kv_pairs_object, array) ->
    [key1, key2] = (keys two_kv_pairs_object)
    [val1, val2] = [two_kv_pairs_object[key1], two_kv_pairs_object[key2]]
    item for item in array when !(item[key1] == val1 && item[key2] == val2)

  reject_obj = (object, array) ->
    item for item in array when !(o_match object, item)

  reject = (some_criteria, array) ->
    switch (typeof some_criteria)
      when "string"
        (reject_prop some_criteria, array)
      when "function"
        (reject_fn some_criteria, array)
      when "object"
        switch (count (keys some_criteria))
          when 0
            throw Errors.NO_KEY_VALUE_PAIR_IN_HASH
          when 1
            (reject_obj_1kv some_criteria, array)
          when 2
            (reject_obj_2kv some_criteria, array)
          else
            (reject_obj some_criteria, array)
      else
        throw Errors.UNEXPECTED_TYPE

  remap = (fn, array) ->
    for item, item_idx in array
      array[item_idx] = (fn item)
    array

  reverse = (bind Function::call, Array::reverse)

  second = (array) ->
    array[1]

  set_difference = (set_a, set_b) ->
    item for item in set_a when (not_contains item, set_b)

  set_symmetric_difference = (set_a, set_b) ->
    [(set_difference set_a, set_b), (set_difference set_b, set_a)]

  # ============================================================
  # CATEGORY: COLLECTIONS
  # ============================================================


  invoke = (method_name, coll) ->
    for item in coll
      item[method_name]()

  pluck = (prop_name, coll) ->
    (map (partial read, prop_name), coll)

  varynum = (numbers, start_with_one) ->
    variator = start_with_one && -1 || 1
    for number in numbers
      variator *= -1
      number * variator


  # ============================================================
  # CATEGORY: OBJECTS
  # ============================================================
  
  clone_obj = (obj) ->
    res = {}
    for key, val of obj
      res[key] = val
    res

  clone = (data) ->
    if (is_object data)
      if (is_array data)
        (slice data)
      else
        (clone_obj data)
    else
      throw Errors.UNEXPECTED_TYPE

  clonedeep = (src) ->
    (_clonedeep src
              , dst = (is_array src) && [] || {}
              , stack_dst = [dst]
              , stack_src = [src])

  _clonedeep = (src, dst, stack_dst, stack_src) ->
    for key, val of src
      if (not_object val)
        dst[key] = val
      else
        val_idx = (index_of val, stack_src)
        if (val_idx == -1)
          dst[key] = child_dst = (is_array val) && [] || {}
          stack_src.push(val)
          stack_dst.push(child_dst)
          (_clonedeep val, child_dst, stack_dst, stack_src)
        else
          dst[key] = stack_dst[val_idx]
    dst

  # _clonedeep2 # TODO how about non-recursive deep clone based on stacks?
  _clonedeep2 = (src) ->
    dst = (is_array src) && [] || {}
    cur_src = src
    cur_dst = dst

    stack_src = [src]
    stack_dst = [dst]
    stack_act = []

    cur_keys = (is_array cur_src) && (range (count cur_src)) || (reverse (keys cur_src))
    cur_key_idx = (count cur_keys)

    while --cur_key_idx >= 0
      key = cur_keys[cur_key_idx]
      val = cur_src[key]

      if (not_object val)
        cur_dst[key] = val
      else
        val_idx = (index_of val, stack_src)
        if (val_idx == -1)
          child_dst = (is_array val) && [] || {}
          cur_dst[key] = child_dst

          stack_act.push([cur_src, cur_dst, cur_keys, cur_key_idx])

          cur_src = val
          cur_dst = child_dst
          cur_keys = (is_array cur_src) && (range (count cur_src)) || (reverse (keys cur_src))
          cur_key_idx = (count cur_keys)

          stack_src.push(cur_src)
          stack_dst.push(cur_dst)
        else
          cur_dst[key] = stack_dst[val_idx]

      while (is_zero cur_key_idx) && (not_zero (count stack_act))
        [cur_src, cur_dst, cur_keys, cur_key_idx] = stack_act.pop()

    dst
    
  
  defaults = (defaults_hash, extended) ->
    for key, val of defaults_hash
      if !(extended[key])
        extended[key] = val
    extended

  extend = (extender, extended) ->
    for key, val of extender
      extended[key] = val
    extended
  
  keys = (hash) ->
    Object.keys(hash)

  # @param {object} hash source
  # @param {array<string>} keys_list
  # @return {array<*>}
  # @example:
  #  food_related_hash =
  #    cook_haggis : (ingredients...) -> ... some code ...
  #    cook_pasta  : (ingredients...) ->
  #    cook_soup   : (ingredients...) ->
  #    drink_beer  : (beer) ->
  #
  #  cooking_for_today = (o_map hash, [ 'cook_haggis', 'drink_beer' ]) # -> [ function, function ]
  #  (first cooking_for_today) == food_related_hash['cook_haggis'] # -> true
  o_map = (hash, keys_list) ->
    for key in keys_list
      hash[key]

  o_match = (criteria_obj, matched) ->
    for key, val of criteria_obj
      if matched[key] != val
        return false
    true

  pull = (prop_name, hash) ->
    val = hash[prop_name]
    delete hash[prop_name]
    val

  vals = (hash) ->
    (o_map hash, (keys hash))

  # ============================================================
  # CATEGORY: STRINGS
  # ============================================================
  
  match = (source_str, regexp) ->
    source_str.match(regexp)

  # Joins incoming strings with a whitespace
  str = ->
    Array::join.call(arguments, ' ')

  str_breplace = (map, str) ->
    regex = (mk_regexp (str_join '|', (keys map)), 'ig')

    str.replace regex, (seq) ->
      map[seq] || seq

  str_join = (join_string, array_to_join) ->
    array_to_join.join(join_string)

  str_split = (split_str, string_to_split) ->
    string_to_split.split(split_str)

  # ============================================================
  # CATEGORY: MISCELLANEOUS
  # ============================================================

  # decrement
  dec = (num) ->
    num - 1

  inc = (num) ->
    num + 1

  jquery_wrap_to_array = (jquery_wrap) ->
    wrap_len = jquery_wrap.length
    i = -1
    while ++i < wrap_len
      jquery_wrap.eq(i)
  
  mk_regexp = (rx_str, rx_settings) ->
    rx_settings = rx_settings || ""
    new RegExp(rx_str, rx_settings)

  range = (length) ->
    array = new Array(length)
    while --length >= 0
      array[length] = length
    array

  read = (prop_name, hash) ->
    hash[prop_name]

  read_1kv = (obj_with_1kv_pair) ->
    key = (first (keys obj_with_1kv_pair))
    [key, (read key, obj_with_1kv_pair)]

  ###
  This is a function that iterates with another function 
  over the nodes of a tree structure.
  @param func {function} function that operates on the node.
    signature: son, parent, son_idx, depth
  @param root {hash} a tree whose children lie in the sons
    list (i.e. ordered collection).
  @param depth: indicates depth of recursion
  ###
  recurse = (func, root, depth = 0) ->
    { sons } = root
    for son, idx in sons
      (func son, root, idx, depth + 1)
    for son in sons
      (recurse func, son, depth + 1)
    root

  set = (prop_name, hash, val) ->
    hash[prop_name] = val

  time = (fn) ->
    time_start = Date.now()
    fn()
    time_end   = Date.now()
    time_end - time_start

  # EXPORTS
  { a_contains
  , a_each
  , a_filter
  , a_index_of
  , a_map
  , a_reduce
  , a_reject
  , apply
  , bind
  , butlast
  , cat
  , clone
  , clonedeep
  , clonedeep2: _clonedeep2
  , compact
  , compose
  , complement
  , contains
  , count
  , defaults
  , detect: find
  , each
  , extend
  , fastbind: bind
  , flow
  , first
  , filter
  , filter_fn
  , filter_obj
  , filter_obj_1kv
  , filter_obj_2kv
  , filter_prop
  , find
  , find_index
  , find_index_fn
  , find_index_prop
  , find_index_obj_1kv
  , find_index_obj_2kv
  , find_index_obj
  , get: read
  , index_of
  , invoke
  , is_array
  , is_empty
  , is_function
  , is_object
  , jquery_wrap_to_array
  , keys
  , last
  , list
  , list_compact
  , map
  , match
  , mk_regexp
  , no_operation
  , noop: no_operation
  , not_array
  , not_empty
  , not_function
  , not_object
  , o_map
  , o_match
  , partial
  , pluck
  , pull
  , read
  , recurse
  , reduce
  , reject
  , reject_fn
  , reject_obj
  , reject_obj_1kv
  , reject_obj_2kv
  , reject_prop
  , remap
  , reverse
  , second
  , set
  , set_difference
  , set_symmetric_difference
  , slice
  , str
  , str_breplace
  , str_join
  , str_split
  , time
  , vals
  , varynum }

# AMD loader support
if (('undefined' != typeof define) && define.amd)
  (define wrapper)
# CommonJS support
else if (('undefined' != typeof module) && module.exports)
  module.exports = wrapper()
