## f-empower
Набор функций предназначенных для функциональной композиции,
именованых через подчеркивание, похожий на clojure.core касательно сигнатуры функций.

### Вам может не понравится
- Браузер должен поддерживать новые функции для массивов (Array extras), а это IE >= 9
- Самые сложные функции покрыты тестами; в целом тесты покрывают лишь 14 из 127 
  экспортируемых функций. Все функции обязательно тестируются в REPL,
  и все функции используются в бою, так что ошибки находятся и правятся
  в течение дня. Соответственно, текущая версия не содержит известных ошибок.

### Технические особенности
- Стандартные функции обхода коллекций (map, each) поддерживают обход 
  произвольного числа коллекций: map(iterator, coll_1, coll_2, ...)
- Релиз под две модульные системы (AMD, CommonJS) через преобразование заголовка файла,
  без ветвлений и дополнительных условий (if module)
  Версию для CommonJS можно использовать и в браузере, но подходит она плохо. Если будет
  спрос, то будет отдельный формат для прямого подключения в браузере.
- Скорость. Релизация функций работы с массивами, а также bind и partial, близка к fast.js.
  Она опускает рассмотрение редких пропускает крайних случаев, ради скорости.
  Со временем будут и бенчмарки.
- Нерекурсивные функции глубокого клонирования, и слияния объектов.
- Маленький размер:
  - f-empower.min.js.gz ~ 4.4кб 
  - f-empower.min.js ~ 14кб
- Для функций map, pluck, invoke учтен аспект работы с массивами для V8: для массивов
  длинной менее 64 000 элементов, используются массивы фиксированной длины,
  иначе динамической
- Поддерживается как обратная, так и прямая функциональная композиция

### Стилистические особенности
- Сигнатура функций. Для большинства функций второстепенные параметры идут первыми.
  Субъективное предположение, что это удобнее для создания замыканий через `partial`. 
  Пример:
``` coffee
names = pluck('name', users)
# vs
names = pluck_name(users) # при заранее подготовленной функции pluck_name = partial(pluck, 'name')
```
- Именование через нижнее подчеркивание. Помимо персональных предпочтений, идентификаторы 
  с нижним подчеркиванием читаются на 13.5% быстрее кэмелкейса, согласно 
  [исследованию](http://whathecode.wordpress.com/2011/02/10/camelcase-vs-underscores-scientific-showdown/).
  Как правило, участок кода пишется один раз, а читается или сканируется глазами намного чаще.
  Вот почему имеет смысл писать код оптимальный для чтения.
- Написано на CoffeeScript, с учетом особенностей его компиляции.


### Что оставлено за пределами библиотеки
- Индексы для функций обхода коллекций
- Аргумент thisContext для функций обхода коллекций. Можно компенсировать использовав bind
  для итератора заранее
- Chaining API. Потому что проблемы вызова методов по цепочке не стоит, пока вы используете
  возвращающие функции. Если же вас смущает необходимость постоянно писать `_.function_name`,
  для каждого вызова -- то CoffeeScript имеет решение - деструктурирование объектов:
```coffee
# Распаковать функции в текущую область видимости
{ function_name_1
  favorite_2
  favorite_3 } = lib
# Использовать без префикса
result = function_name_1( favorite_2( data ) )
```
- HTML шаблоны.

### Планы
- Бенчмарки производительности
- Больше тестов
- Модуляризация:
  - Выделение меньшего ядра функций
  - Написание новых тематических модулей
- Дальнейшая оптимизация под V8 и Crankshaft
- Подробная документация

## Установка
#### npm
`npm install -s f-empower`
#### Bower
`bower install -S f-empower`

## Использование
### CommonJS (~ NodeJS)
```coffee
functions = require "f-empower"
{ apply
  bind }  = functions
array1 = [ 1, 2, 3 ]
push_to_array1 = (bind array1.push, array1)

(apply push_to_array1, [ 4, 5, 6 ])
console.log(array1) # -> [ 1, 2, 3, 4, 5, 6 ]
```
### AMD (~ RequireJS)
```coffee
require.config
  paths:
    'f-empower': 'path/to/f-empower/dist/f-empower'

define [ 'f-empower' ], (functions) ->
  { apply
    bind }  = functions
  array1 = [ 1, 2, 3 ]
  push_to_array1 = (bind array1.push, array1)

  (apply push_to_array1, [ 4, 5, 6 ])
  console.log(array1) # -> [ 1, 2, 3, 4, 5, 6 ]
```
### Браузер напрямую (нет специальной поддержки, под вопросом)
```html
<!-- включив этот код в страницу -->
<script src='path/to/f-empower/dist-cj/f-empower'></script>
<!-- вы получите объект exports со всеми функциями -->
<!-- также все функции будут в глобальной области видимости -->
<script>
console.log(typeof exports.map)
// function
</script>
```
C другой стороны можно попробовать подключить AMD модуль, 
только определите предварительно функцию define


## Краткая документация
Ниже следует описание функций библиотеки разбитое на категории.
Документация функций подчиняется шаблону:
```
# название функции   сигнатура_1            сигнатура_2               описание
reduce             : (fn(prev, cur), arr) | (fn(prev, cur), val, arr) прогоняет функцию fn по всем элементам массива...
```

### Работа с массивами
Сочетание массив-ориентированная значит, что массив принимается первым аргументом.

- a_contains   : (arr, item) массив-ориентированная версия `contains`.
Проверяет наличие элемента в массиве через строгое равенство.
- a_each       : (arr, fn) массив-ориентированная версия `each`, работает только с одним массивом
- a_filter     : (arr, fn) массив-ориентированная версия `filter`
- a_map        : (arr, fn) массив-ориентированная версия `map`, работает только с одним массивом
- a_reduce     : (arr, fn) | (arr, fn, val) массив-ориентированная версия `reduce`
- a_reject     : (arr, fn) массив-ориентированная версия `reject`
- a_sum        : (arr.<number>) суммирует все числа в массиве
- butlast      : (arr) вернет новый массив состоящий из всех-кроме-последнего элементов оригинала
- count        : (array_like) вернет значение свойства `length` объекта
- drop         : (x, arr) вернет новый массив без первых `x` элементов
- each         : (fn(item), arr...) вызывает функцию `fn` на каждом срезе переданных массивов, см `map`
- filter       : (criteria(fn/obj/string), arr) вернет новый список элементов удовлетворяющих условию. 
Условие может быть задано:

1) функцией, результат которой приводится к логическому значению
```coffee
filter(((x) -> x), [0, 1, 2, 0, 3])
# [1, 2, 3]
```
2) объектом задающим необходимые значения свойств
```coffee
filter({type: 'editor'}, [{name: 'vim', type: 'editor'}, {name: 'tmux', type: 'terminal multiplexer'})
# [{name: 'vim', type: 'editor'}] 
```
3) строкой указывающей имя свойства членов массива которое будет проверяться на логическое значение
```coffee
filter('has_lisp', [{name: 'emacs', has_lisp: true}, {name:'vim', has_lisp: false}])
# [{name: 'emacs', has_lisp: true}]
```
- first        : (arr) вернет первый элемент в массиве
- index_of     : (item, arr) вернет индекс первого элемента в массиве удовлетворяющий строгому равенству
- last         : (arr) вернет последний элемент массива
- list         : (items...) создаст массив из аргументов `list(1, 2, 3) # -> [1, 2, 3]`
- list_compact : (items...) ярлык для `compact(list(args...))`
- map          : (fn, arrs...) map работающий с произвольным числом коллекций. Пример работы 
```coffee
map(
    Array,
    [0, 1, 2, 3],
    ['zero', 'one' , 'two', 'three'], # en
    ['ноль', 'один', 'два', 'три'  ], # ru
    ['zero', 'uno' , 'due', 'tre'  ]  # it
)
# [ [ 0, 'zero ', 'ноль', 'zero' ],
#   [ 1, 'one'  , 'один', 'uno'  ],
#   [ 2, 'two'  , 'два' , 'due'  ],
#   [ 3, 'three', 'три' , 'tre'  ] ]
```

- push         : (arr, item) ярлык для arr.push(item)
- reduce       : (fn(prev, cur), arr) | (fn(prev, cur), val, arr) прогоняет функцию `fn` по всем элементам массива,
вызывая ее каждый раз с результатом предыдущего вычисления и текущим элементом массива.
```coffeescript
reduce(and2, true, [true, null, false]) # null
reduce(sum2, [1, 2, 3]) # 6

reduce(bind(console.log, console), [1, 2, 3])
# 1 2
# undefined, 3
```

- reject       : (fn/object/string, arr) антагонист filter, вернет новый массив где будут только те элементы
оригинала, для которых условие приводится к false
- rest         : (arr) вернет все элементы массива кроме первого
- remap        : (fn, arr) обновит каждый элемент массива используя функцию `fn` # `arr[i] = fn(arr[i])`
- remove       : (item, arr) удалит элемент из массива опираясь на строгое равенство
- remove_at    : (idx, arr) удалит из массива элемент с заданным индексом
- range        : (end_num) | (start_num, end_num) | (start_num, end_num, step)
Создаст новый масив чисел от `start_num` до `end_num`, с шагом `step`
- repeat       : (times, val) создаст новый массив длины `times`, заполненный значением `val`
- second       : (arr) вернет второй элемент массива
- set_difference : (arr1, arr2) -> вернет новый массив с такими элементами из `arr1`, которых нет в `arr2`,
для сравнения элементов используется строгое равенство
- set_symmetric_difference (arr1, arr2) ярлык для [set_difference(arr1, arr2), set_difference(arr2, arr1)]
- slice        : (arr [, start_idx, end_idx]) обертка нативного `slice`
- splice       : (arr [, start_idx, remove_count, new_elements...]) обертка нативного `splice`
- take         : (x, arr) вернет новый массив в котором будут только первые `x` элементов из массива `arr`
- unshift      : (arr, item) ярлык для `arr.unshift(item)`

### Работа с функциями
- apply        : (fn, args...) вернет результат вызова fn.apply(this, args)
- bind         : (fn, this_arg) вернет новую функцию, будет привязана к контексту `this_arg`
```coffee
animals = []
populate_animals = bind(animals.push, animals)
populate_animals('cat', 'dog', 'monkey')
console.log(animals) # ['cat', 'dog', 'monkey']
```
- compose      : (fn...) вернет новую функцию которая будет возвращать результат выражения проведенный
через цепочку переданных функций. Пример: 
```coffeescript
square = (x) -> x * x
add2   = (x) -> x + 2
mult2  = (x) -> x * 2
all_math = compose(mult2, square, add2)
all_math( 0 ) # 8
# эквивалентно:
mult2( square( add2( 0 ) ) ) # 8 
```
Также смотри `pipeline`
- complement   : (predicate_fn) вернет новую функцию которая будет возвращать отрицание результата вычисления
переданной функции предиката. Используется для создания антагонистов предикатов:
```coffee
not_number = complement( is_number )
is_number(4)  # true
not_number(4) # false
```
- debounce     : (debounce_timeout, fn) вернет новую функцию `x` которая будет вызвать `fn`, после прохождения
`debounce_timeout` миллисекунд с момента последнего вызова `x`
- delay        : (delay_ms, fn) ярлык для `setTimeout`, с обратным порядком передачи аргументов.
На мой взгляд это делает код более читаемым: не приходится листать код вниз в поисках значения задержки
Вызов вернет идентификатор таймаута.
- multicall    : (fn...) вернет функцию вызов которой будет вызывать каждую из переданных функций
с переданными аргументами.
- partial      : (fn, args...), вернет новую функцию `x`, которая при каждом вызове будет вызывать `fn`, подставляя
`args...` в начало списка аргументов переданных `x`. Пример:
```coffee
map_int = partial(map, parseInt)
map_int(["1", "0", "123", "123153"]) # [1, 0, 123, 123153]
```
Результат тот же что и для `map(parseInt, ["1", "0", "123", "123153"])`, но в момент вызова передается меньше аргументов
- partialr     : (fn, args...) то же что и partial, только args... будет подставляться с правой стороны,
для каждого вызова x. Пример:
```coffee
map_my_set = partialr(map, [1, 2, 3], ['one', 'two', 'three'])
map_my_set(list) # [[1, 'one'], [2, 'two'], [3, 'three']]
```
Есть ярлык: `pt`
- pipeline     : (fn...) то же что и compose только код переходит по функциям слева направо, а не наоборот.
Пример: 
```coffee
assemble_item = pipeline(step1, step2, step3)
assemble_item( resources )
# эквивалентно:
step3( step2( step1( resources ) ) )
```
- pt           : ярлык для `partial`
- throttle     : (throttle_ms, fn) вернет новую функцию `x`, которая будет вызывать `fn`
не раньше чем раз в `throttle_ms`
- no_operation : не делает ничего, и ничего не возвращает
- noop         : ярлык для `no_operation`

### Функции-предикаты, возвращают логическое значение
- and2         : (a, b) вернет результат `a && b`, удобно вместе с `reduce`
- is_array     : (item) проверяет является ли `item` массивом. Ярлык для `Array.isArray`
- is_defined   : (item) проверяет определен ли `item`
- is_empty     : (array_like) вернет результат `array_like.length == 0`
- is_function  : (item) вернет результат `'function' == typeof item`
- is_number    : (item) вернет результат `'number' == typeof item`
- is_object    : (item) вернет результат `'object' == typeof item`
- is_plain_object : (item) проверяет является ли объект простым. Реализация повторяет
`shimIsPlainObject` из lodash. Объект считается простым, если его прототипом является `Object`
- is_zero      : (num) вернет результат `num == 0`
- not_array    : антагонист `is_array`
- not_defined  : антагонист `is_defined`
- not_empty    : антагонист `is_empty`
- not_function : антагонист `is_function`
- not_number   : антагонист `is_number`
- not_object   : антагонист `is_object`
- not_zero     : антагонист `is_zero`

### Фунцкии обхода массивов с предположениями о свойствах массивов
- invoke       : (method_name, arr) | (method_name, method_args..., arr)
вызовет метод `method_name`, на каждом из элементов массива, с аргументами `method_args...`
вернет массив с результатами выполнения метода, на каждом из элементов
Пример:
```coffee
results = invoke('peace', {plant_flowers: true}, [soldier1, soldier1, soldier3])
# Эквивалент:
results =
  [ soldier1.peace({plant_flowers: true})
  , soldier2.peace({plant_flowers: true})
  , soldier3.peace({plant_flowers: true}) ]
```
- pluck        : (key, arr) вернет новый массив наполненный значениями аттрибута `key` для каждого
элемента из `arr`

### Работа с объектами
- assign       : (dest, src...) поочередно, для каждого элемента из `src...` записывает все его ключи в `dest`
```coffee
assign({}, {editor: 'vim', foo: 'bar'}, {editor: 'emacs'}) # {editor: 'emacs', foo: 'bar'}
```
- clone        : (item) вернет поверхностную копию `item`
- clonedeep    : (item) вернет глубокую копию `item`. Кольцевые ссылки правильно копируются
- clonedeep2   : (item) то же что и `clonedeep`, другая реализация. Вместо рекурсивного
вызова используется внутренний стек.
- defaults     : (dest, src...) поочередно, для каждого элемента из `src...` записывает каждый его
ключ в объект `dest`, если такой ключ еще не определен в `dest`
- extend       : ярлык для `assign`
- keys         : (obj) вернет массив ключей переданного объекта
- merge        : (dest, src) глубокое слияние объектов, без использования рекурсивного вызова
- o_map        : (obj, keys_list) вернет значения соответствующие ключу в `obj`, для каждого ключа
указанного в массиве `keys_list`
```coffee
o_map({age: 35}, ['age']) # -> [ 35 ]
```
- o_match      : (criteria_object, matched_object) вернет `true` если каждое свойство
внутри `criteria_object` строго равно такому внутри `matched_object`
- pull         : (key, obj) удалит ключ из объекта и вернет его значение
- read         : (key, obj) вернет значение ключа `key` из объекта `obj`
- recurse      : (fn(son, parent, son_idx, son_depth), root, depth) рекурсивно пройдет по дереву
где лежат в массиве `sons`, на каждом вызовет функцию `fn`
- vals         : (obj) вернет массив значений объекта

### Функции для работы со строками
- comma        : (strings...) вернет новую строку составленную из переданных строк соединенный через запятую.
Удобно для создания HTML селекторов.
- head         : (x, string) вернет подстроку от `string` состоящую из ее первых `x` символов
- match        : (str, regexp) обертка вокруг метода строки `match`
- mk_regexp    : (regex_str, regex_flags_str) вернет экземпляр `RegExp`
- space        : (strings...) соединит все переданные строки в одну разделив их пробелом
- str          : (strings...) соединит все переданные строки в одну
- str_breplace : (replace_map, string) - заменит все символы указанные в `replace_map` как ключи, на 
символы указанные как значения. Полезно для создания функций транслитерации. Пример:
```coffee
en2ru_chars = { 'a': 'ф', 'b': 'и', 'f': 'а' }
en_str = 'bafbaffab'
str_breplace(en2ru_chars, en_str) # 'ифаифаафи'
```
- str_join     : (join_str, strings_arr) соединит строки из массива `strings_arr` через заданную строку `join_str`
- str_split    : (split_str, string_to_split) разъединит строку `string_to_split` по заданной подстроке `split_str`
- tail         : (x, string) вернет подстроку от `string` без первых `x` символов

### Разное
- jquery_wrap_to_array : (jquery_wrap) переводит все элементы внутри обертки jquery в массив
оберток. Удобно для дальнейшей работы с обычными функциями коллекций.
- varynum      : (numbers_arr [, start_with_one]) принимает массив чисел. вернет новый массив
  чисел где каждое число из оригинального массива поочередно умножено на -1 и 1. Пример:
```coffee
varynum([1, 2, 3, 4]) # [-1, 2, -3, 4]
```