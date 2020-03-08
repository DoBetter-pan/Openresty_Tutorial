# Openresty基础教程

## 前言

本人使用Openresty做为后段的开发框架已经有五年多了，通过一段时间的使用对Openresty的使用有了一定的了解，希望将本人知道的一些知识整理出来，做一个小的教程，希望能够帮助到一些初学者。本文章是基于使用Openresty做为后段服务的基础教程，希望大家通过本人的教程能够快速掌握Openresty这一优秀的框架，既然无太多编程经验的人也可以写出简单高效的服务。本人的水平有限，如果有不对之处，也希望大家批评指正。

## 第一章 Openresty简介

以下是Openresty的官方简介：

OpenResty® 是一个基于 Nginx 与 Lua 的高性能 Web 平台，其内部集成了大量精良的 Lua 库、第三方模块以及大多数的依赖项。用于方便地搭建能够处理超高并发、扩展性极高的动态 Web 应用、Web 服务和动态网关。

OpenResty® 通过汇聚各种设计精良的 Nginx 模块（主要由 OpenResty 团队自主开发），从而将 Nginx 有效地变成一个强大的通用 Web 应用平台。这样，Web 开发人员和系统工程师可以使用 Lua 脚本语言调动 Nginx 支持的各种 C 以及 Lua 模块，快速构造出足以胜任 10K 乃至 1000K 以上单机并发连接的高性能 Web 应用系统。

OpenResty® 的目标是让你的Web服务直接跑在 Nginx 服务内部，充分利用 Nginx 的非阻塞 I/O 模型，不仅仅对 HTTP 客户端请求,甚至于对远程后端诸如 MySQL、PostgreSQL、Memcached 以及 Redis 等都进行一致的高性能响应。

对于我来说：Openresty就是一个性能高效、编程简单的优秀后段框架。

## 第二章 Openresty的第一个程序

学习语言与框架，第一个程序都是那一个经典程序"Hello World!"，我们也从这一经典程序开始，让我们逐步进入Openresty的世界。

为了方便清晰起见，我将Openresty安装在/opt/openresty目录下。什么？不会安装Openresty。请参考如下命令，找不到的包请教下度娘吧。

去https://github.com/openresty/lua-nginx-module下载代码，我们使用的是1.15.8.1版本，使用如下命令安装：

```shell
tar xvfz openresty-1.15.8.1.tar.gz
cd openresty-1.15.8.1
./configure --prefix=/opt/openresty
make
make install
```

安装好了之后，在/opt/openresty下创建services目录，我们自己的程序将都在这个目录下。

具体的目录结构如下：
```shell
/opt/openresty/services/
/opt/openresty/services/conf/
/opt/openresty/services/src/
/opt/openresty/services/src/lua/
/opt/openresty/services/src/libs/
```

其中:

/opt/openresty/services/conf/目录下放我们的ngxin的conf文件。

/opt/openresty/services/src/lua/目录下放我们自己的lua代码。

/opt/openresty/services/src/libs/目录下放我们自己开发的lua的C库。

其实大家自己的代码可以按照自己的方式放代码，但是为了整洁，我是这样放代码的，同时也是为了说明的方便。

Openresty已经安装完成，代码的目录结构也已经创建好了，基本的准备工作已经完成了，那么就开始写我们的一个程序吧。

见证奇迹的时候到来了。

## Example

```lua
local pb = require "pb"
local protoc = require "protoc"

-- load schema from text
assert(protoc:load [[
   message Phone {
      optional string name        = 1;
      optional int64  phonenumber = 2;
   }
   message Person {
      optional string name     = 1;
      optional int32  age      = 2;
      optional string address  = 3;
      repeated Phone  contacts = 4;
   } ]])

-- lua table data
local data = {
   name = "ilse",
   age  = 18,
   contacts = {
      { name = "alice", phonenumber = 12312341234 },
      { name = "bob",   phonenumber = 45645674567 }
   }
}

-- encode lua table data into binary format in lua string and return
local bytes = assert(pb.encode("Person", data))
print(pb.tohex(bytes))

-- and decode the binary data back into lua table
local data2 = assert(pb.decode("Person", bytes))
print(require "serpent".block(data2))

```

## Use case

[![零境交错](https://img.tapimg.com/market/images/e59627dc9039ff22ba7d000b5c9fe7f6.jpg?imageView2/2/h/560/q/40/format/jpg/interlace/1/ignore-error/1)](http://djwk.qq.com)



## Usage

### `protoc` Module

| Function                | Returns       | Descriptions                                         |
| ----------------------- | ------------- | ---------------------------------------------------- |
| `protoc.new()`          | Proroc object | create a new compiler instance                       |
| `protoc.reload()`       | true          | reload all google standard messages into `pb` module |
| `p:parse(string)`       | table         | transform schema to `DescriptorProto` table          |
| `p:parsefile(string)`   | table         | like `p:parse()`, but accept filename                |
| `p:compile(string)`     | string        | transform schema to binary *.pb format data          |
| `p:compilefile(string)` | string        | like `p:compile()`, but accept filename              |
| `p:load(string)`        | true          | load schema into `pb` module                         |
| `p:loadfile(string)`    | true          | like `pb:loadfile()`, but accept filename            |
| `p.loaded`              | table         | contains all parsed `DescriptorProto` table          |
| `p.paths`               | table         | a table contains import search directories           |
| `p.unknown_module`      | see below     | handle schema import error                           |
| `p.unknown_type`        | see below     | handle unknown type in schema                        |
| `p.include_imports`     | bool          | auto load imported proto                             |

To parse a text schema file, create a compiler instance first:

```lua
local p = protoc.new()
```

Then, set some options to the compiler, e.g. the search path, the unknown handlers, etc.

```lua
-- set the search path
p.paths[#p.paths+1] = "whatever/folder/hold/.proto/files"
-- set some hooks
p.unknown_module = function(self, module_name) ... end
p.unknown_type   = function(self, type_name) ... end
-- ... and options
p.include_imports = true
```

The `unknwon_module` and `unknown_type` handle could be `true`, string or a function.  Seting it to `true` means all *non-exist* modules and types are given a default value without triggering an error;  A string means a Lua pattern that indicates whether an unknown module or type should raise an error, e.g.

```lua
p.unknown_type = "Foo.*"
```

means all types prefixed by `Foo` will be treat as existing type and do not trigger errors.

If these are functions, the unknown type and module name will be passed to functions.  For module handler, it should return a `DescriptorProto` Table produced by `p:load[file]()` functions, for type handler, it should return a type name and type, such as `message` or `enum`, e.g.

```lua
function p:unknown_module(name)
  -- if can not find "foo.proto", load "my_foo.proto" instead
  return p:load("my_"..name)
end

function p:unknown_type(name)
  -- if cannot find "Type", treat it as ".MyType" and is a message type return ".My"..name, "message"
end
```

After setting options, use `load[file]()` or `compile[file]()` or `parse[file]()` function to get result.

### `pb` Module

`pb` module has high-level routines to manipulate protobuf messages.

in below table of functions, we have several types that have special means:

- `type`: a string that indicates the protobuf message type, `".Foo"` means the type in a proto file that has not `package` statement declared.  `"foo.Foo"` means the type in a proto file that declared `package foo;`

- `data`: could be string, `pb.Slice` value or `pb.Buffer` value.

- `iterator`: a function that can use in Lua `for in` statement, e.g.

  ```lua
  for name in pb.types() do
    print(name)
  end
  ```


all functions raise a Lua error when meets errors.

| Function                       | Returns         | Description                                       |
| ------------------------------ | --------------- | ------------------------------------------------- |
| `pb.clear()`                   | None            | clear all types                                   |
| `pb.clear(type)`               | None            | delete specific type                              |
| `pb.load(data)`                | boolean,integer | load a binary schema data into `pb` module        |
| `pb.loadfile(string)`          | boolean,integer | same as `pb.load()`, but accept file name         |
| `pb.encode(type, table)`       | string          | encode a message table into binary form           |
| `pb.encode(type, table, b)`    | buffer          | encode a message table into binary form to buffer |
| `pb.decode(type, data)`        | table           | decode a binary message into Lua table            |
| `pb.decode(type, data, table)` | table           | decode a binary message into a given Lua table    |
| `pb.pack(fmt, ...)`            | string          | same as `buffer.pack()` but return string         |
| `pb.unpack(data, fmt, ...)`    | values...       | same as `slice.unpack()` but accept data          |
| `pb.types()`                   | iterator        | iterate all types in `pb` module                  |
| `pb.type(type)`                | see below       | return informations for specific type             |
| `pb.fields(type)`              | iterator        | iterate all fields in a message                   |
| `pb.field(type, string)`       | see below       | return informations for specific field of type    |
| `pb.enum(type, string)`        | number          | get the value of a enum by name                   |
| `pb.enum(type, number)`        | string          | get the name of a enum by value                   |
| `pb.defaults(type[, table])`   | table           | get the default table of type                     |
| `pb.hook(type[, function])`    | function        | get or set hook functions                         |
| `pb.option(string)`            | string          | set options to decoder/encoder                    |
| `pb.state()`                   | `pb.State`      | retrieve current pb state                         |
| `pb.state(newstate \| nil)`    | `pb.State`      | set new pb state and retrieve the old one         |

#### Scheme file loading

`pb.load()` accepts the schema binary data directly, and `pb.loadfile()` reads data from file. they returns a boolean indicates the result of loading, success or failure, and a offset reading in schema so far that is useful to figure out the reason of failure.

#### Type Information

Using `pb.(type|field)[s]()` functions retrieve type information for loaded messages.  

`pb.type()` returns multiple informations for specified type:

- name : the full qualifier name of type, e.g. ".package.TypeName"
- basename: the type name without package prefix, e.g. "TypeName"
- `"map"` | `"enum"` | `"message"`: whether the type is a map_entry type, enum type or message type.

`pb.types()` returns a iterators, behavior like call `pb.type()` on every types of all messages.

```lua
print(pb.type "MyType")

-- list all types that loaded into pb
for name, basename, type in pb.types() do
  print(name, basename, type)
end
```

`pb.field()` returns information of the specified field for one type:

- name: the name of the field
- number: number of field in the schema
- type: field type
- default value: if no default value, nil
- `"packed"`|`"repeated"`| `"optional"`: label of the field, optional or repeated, required is not supported
- [oneof_name, oneof_index]: if this is a `oneof` field, this is the `oneof` name and index

And `pb.fields()` iterates all fields in a message:

```lua
print(pb.field("MyType", "the_first_field"))

-- notice that you needn't receive all return values from iterator
for name, number, type in pb.fields "MyType" do
  print(name, number, type)
end
```

`pb.enum()` maps from enum name and value:

```lua
protoc:load [[
enum Color { Red = 1; Green = 2; Blue = 3 }
]]
print(pb.enum("Color", "Red")) --> 1
print(pb.enum("Color", 2)) --> "Green"
```

#### Default Values

Using `pb.defaults()` to get a table with all default values from a message. this table will be used as the metatable of the corresponding decoded message table when setting `use_default_metatable` option.

```lua
   check_load [[
      message TestDefault {
         optional int32 defaulted_int = 10 [ default = 777 ];
         optional bool defaulted_bool = 11 [ default = true ];
         optional string defaulted_str = 12 [ default = "foo" ];
         optional float defaulted_num = 13 [ default = 0.125 ];
      } ]]
   print(require "serpent".block(pb.defaults "TestDefault"))
-- output:
-- {
--   defaulted_bool = true,
--   defaulted_int = 777,
--   defaulted_num = 0.125,
--   defaulted_str = "foo"
-- } --[[table: 0x7f8c1e52b050]]

```

#### Hooks

If set `pb.option "enable_hooks"`, the hook function will enabled. you could use `pb.hook()` to set or get a hook function. call it with type name directly get current setted hook. call it with two arguments to set a hook. and call it with `nil` as the second argument to remove the hook. in all case, the original one will be returned.

After the hook function setted and hook enabled, the function will be called *after* a message get decoded. So you could get all values in the table passed to hook function. That's the only argument of hook.

If you need type name in hook functions, use this helper:

```lua
local function make_hook(name, func)
  return pb.hook(name, function(t)
    return func(name, t)
  end)
end
```

#### Options

Setting options to change the behavior of other routines.
These options are supported currently:

| Option                  | Description                                                  |
| ----------------------- | ------------------------------------------------------------ |
| `enum_as_name`          | set value to enum name when decode a enum **(default)**      |
| `enum_as_value`         | set value to enum value when decode a enum                   |
| `int64_as_number`       | set value to integer when it fit int32, otherwise return a number **(default)** |
| `int64_as_string`       | same as above, but when it not fit int32, return a string instead |
| `int64_as_hexstring`    | same as above, but return a hexadigit string instead         |
| `no_default_values`     | do not default values for decoded message table **(default)** |
| `use_default_values`    | set default values by copy values from default table before decode |
| `use_default_metatable` | set default values by set table from `pb.default()` as the metatable |
| `enable_hooks`          | `pb.decode` will call `pb.hooks()` hook functions            |
| `disable_hooks`         | `pb.decode` do not call hooks **(default)**                  |

 *Note*: The string returned by `int64_as_string` or `int64_as_hexstring` will prefix a `'#'` character. Because Lua may convert between string with number, prefix a `'#'` makes Lua return the string as-is.

all routines in all module accepts `'#'` prefix `string`/`hex string` as arguments regardless of the option setting.

#### Multiple State

`pb` module support multiple states. A state is a database that contains all type information of registered messages. You can retrieve current state by `pb.state()`, or set new state by `pb.state(newstate)`.

Use `pb.state(nil)` to discard current state, but not to set a new one (the following routines call that use the state will create a new default state automatedly). Use `pb.state()` to retrieve current state without setting a new one. e.g.

```lua
local old = pb.state(nil)
-- if you use protoc.lua, call protoc.reload() here.
assert(pb.load(...))
-- do someting ...
pb.state(old)
```

Notice that if you use `protoc.lua` module, it will register some message to the state, so you should call `proto.reload()` after setting a new state.



### `pb.io` Module

`pb.io` module reads binary data from a file or `stdin`/`stdout`, `pb.io.read()` reads binary data from a file, or `stdin` if no file name given as the first parameter.

`pb.io.write()` and `pb.io.dump()` are same as Lua's `io.write()` except they write binary data.  the former writes data to `stdout`, and the latter writes data to a file specified by the first parameter as the file name.

All these functions return a true value when success, and return `nil, errmsg` when an error occurs.

| Function               | Returns | Description                         |
| ---------------------- | ------- | ----------------------------------- |
| `io.read()`            | string  | read all binary data from `stdin`   |
| `io.read(string)`      | string  | read all binary data from file name |
| `io.write(...)`        | true    | write binary data to `stdout`       |
| `io.dump(string, ...)` | string  | write binary data to file name      |



### `pb.conv` Module

`pb.conv` provide functions to convert between numbers.

| Encode Function        | Decode Function        |
| ---------------------- | ---------------------- |
| `conv.encode_int32()`  | `conv.decode_int32()`  |
| `conv.encode_uint32()` | `conv.decode_uint32()` |
| `conv.encode_sint32()` | `conv.decode_sint32()` |
| `conv.encode_sint64()` | `conv.decode_sint64()` |
| `conv.encode_float()`  | `conv.decode_float()`  |
| `conv.encode_double()` | `conv.decode_double()` |



### `pb.slice` Module

Slice object parse binary protobuf data in a low-level way.  Use `slice.new()` to create a slice object, with the optional offset `i` and `j` to access a subpart of the original data (named a *view*).

A slice object has a stack itself.  calling `s:enter(i, j)` saves current position and enters next level with the optional offset `i` and `j` just as `slice.new()`.  calling `s:leave()` restore the prior view.  `s:level()` returns the current level, and `s:level(n)` returns the current position, the start and the end position information of the `n`th level.  calling `s:enter()` without parameter will read a length delimited type value from the slice and enter the view in reading value.  Using `#a` to get the count of bytes remains in current view.

To read values from slice, use `slice.unpack()`, it use a format string to control how to read into a slice as below table (same format character are also used in `buffer.pack()`):

| Format | Description                                                  |
| ------ | ------------------------------------------------------------ |
| v      | variable Int value                                           |
| d      | 4 bytes fixed32 value                                        |
| q      | 8 bytes fixed64 value                                        |
| s      | length delimited value, usually a `string`, `bytes` or `message` in protobuf. |
| c      | receive a extra number parameter `count` after the format, and reads `count` bytes in slice. |
| b      | variable int value as a Lua `boolean` value.                 |
| f      | 4 bytes `fixed32` value as floating point `number` value.    |
| F      | 8 bytes `fixed64` value as floating point `number` value.    |
| i      | variable int value as signed int value, i.e. `int32`         |
| j      | variable int value as zig-zad encoded signed int value, i.e.`sint32` |
| u      | variable int value as unsigned int value, i.e. `uint32`      |
| x      | 4 bytes fixed32 value as unsigned fixed32 value, i.e.`fixed32` |
| y      | 4 bytes fixed32 value as signed fixed32 value, i.e. `sfixed32` |
| I      | variable int value as signed int value, i.e.`int64`          |
| J      | variable int value as zig-zad encoded signed int value, i.e. `sint64` |
| U      | variable int value and treat it as `uint64`                  |
| X      | 8 bytes fixed64 value as unsigned fixed64 value, i.e. `fixed64` |
| Y      | 8 bytes fixed64 value as signed fixed64 value, i.e. `sfixed64` |

And extra format can be used to control the read cursor in one `slice.unpack()` process:

| Format | Description                                                  |
| ------ | ------------------------------------------------------------ |
| @      | returns current cursor position in the slice, related with the beginning of the current view. |
| *      | set the current cursor position to the extra parameter after format string. |
| +      | set the relate cursor position, i.e. add the extra parameter to the current position. |

e.g. If you want to read a `varint` value twice, you can write it as:

```lua
local v1, v2 = s:unpack("v*v", 1)
-- v: reads a `varint` value
-- *: receive the second parameter 1 and set it to the current cursor position, i.e. restore the cursor to the head of the view
-- v: reads the first `varint` value again
```

All routines in `pb.slice` module:

| Function                  | Returns      | Description                                                  |
| ------------------------- | ------------ | ------------------------------------------------------------ |
| `slice.new(data[,i[,j]])` | Slice object | create a new slice object                                    |
| `s:delete()`              | none         | same as `s:reset()`, free it's content                       |
| `tostring(s)`             | string       | return the string repr of the object                         |
| `#s`                      | number       | returns the count of bytes can read in current view          |
| `s:reset([...])`          | self         | reset object to another data                                 |
| `s:level()`               | number       | returns the count of stored state                            |
| `s:level(number)`         | p, i, j      | returns the informations of the `n`th stored state           |
| `s:enter()`               | self         | reads a bytes value, and enter it's view                     |
| `s:enter(i[, j])`         | self         | enter a view start at `i` and ends at `j`, includes          |
| `s:leave([number])`       | self, n      | leave the number count of level (default 1) and return current level |
| `s:unpack(fmt, ...)`      | values...    | reads values of current view from slice                      |



### `pb.buffer` Module

Buffer module used to construct a protobuf data format stream in a low-level way. It's just a bytes data buffer. using `buffer.pack()` to append values to the buffer, and `buffer.result()` to get the encoded raw data, or `buffer.tohex()` to get the human-readable hex digit value of data.

 `buffer.pack()` use the same format syntax with `slice.unpack()`, and support `'()'` format means the inner value will be encoded as a length delimited value, i.e. a message value encoded format.

parenthesis can be nested.

e.g.

```lua
b:pack("(vvv)", 1, 2, 3) -- get a bytes value that contains three varint value.
```



`buffer.pack()` also support '#' format, it means prepends a length into the buffer.

e.g.

```lua
b:pack("#", 5) -- prepends a varint length #b-5+1 at offset 5
```

All routines in `pb.buffer` module:

| Function            | Returns       | Description                                                  |
| ------------------- | ------------- | ------------------------------------------------------------ |
| `buffer.new([...])` | Buffer object | create a new buffer object, extra args will passed to `b:reset()` |
| `b:delete()`        | none          | same as `b:reset()`, free it's content                       |
| `tostring(b)`       | string        | returns the string repr of the object                        |
| `#b`                | number        | returns the encoded count of bytes in buffer                 |
| `b:reset()`         | self          | free buffer content, reset it to a empty buffer              |
| `b:reset([...])`    | self          | resets the buffer and set its content as the concat of it's args |
| `b:tohex([i[, j]])` | string        | return the string of hexadigit represent of the data, `i` and `j` are ranges in encoded data, includes. Omit it means the whole range |
| `b:result([i[,j]])` | string        | return the raw data, `i` and `j` are ranges in encoded data, includes,. Omit it means the whole range |
| `b:pack(fmt, ...)`  | self          | encode the values passed to `b:pack()`, use `fmt` to indicate how to encode value |

