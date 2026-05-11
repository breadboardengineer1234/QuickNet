---
layout: docs
title: Types
---

# Types
This section explains how each type works and indicates their respective sizes. In all code examples, ```local data = QuickNet.Data``` is implied.
## Numbers (1-8 bytes)
QuickNet supports all number types supported by the buffer library as well as float16 (F16). Because float16 is not natively supported in luau, using it incurs much higher CPU overhead compared to other number types; this is despite QuickNet having a fairly optimal implementation of it. Below is a list of the supported number types with their ranges. Note that floating point numbers stop being able to accurately represent integer increments at values far above/below the min/max bounds.

| Number Type | Minimum Value | Maximum Value | Size (bytes) |
|-------------|--------------|---------------| ---------------|
| NumberU8    | 0            | 255           | 1 |
| NumberU16   | 0            | 65,535        | 2 |
| NumberU32   | 0            | 4,294,967,295 | 4 |
| NumberI8    | -128         | 127           | 1 |
| NumberI16   | -32,768      | 32,767        | 2 |
| NumberI32   | -2,147,483,648 | 2,147,483,647 | 4 |
| NumberF16   | -65,504      | 65,504        | 2 |
| NumberF32   | -3.4e38      | 3.4e38        | 4 |
| NumberF64   | -1.7e308     | 1.7e308       | 8 |

## String (length+1 bytes)
The String type can be used for any string but has a max length of 255 characters. For longer strings, use StringLong.

## StringLong (length+4 bytes)
Same as String except it uses 4 bytes to store the length, which allows a maximum of 4,294,967,295 characters.

## Boolean (1 bit/1 byte)
A ```true``` or ```false``` value. QuickNet will automatically bit pack booleans when it's worth it. In these cases, each value will use 1 bit. When the data is not eligible for bit packing, each value will use 1 byte.

## Nil (0 bytes)
A ```nil``` value.

## Color3 (3 bytes)
A Color3 object, such as 
```lua 
local color = Color3.new(1, 1, 1)
```

## BrickColor (2 bytes)
A BrickColor object. If the intended color is one of the BrickColor presets, usage of BrickColor over Color3 is recommended as it saves 1 byte and a few buffer operations.

## Buffer (length+2 bytes)
Buffer object, max length 65535.

## EnumItem (1 byte)
Roblox EnumItem. To use this type, a list of the enums used must be supplied to QuickNet using the ```:setEnumItems``` method, which must be called on both client and server. The list can contain a maximum of 255 enums.
```lua
local enums = {
  Enum.EasingDirection.Out,
  Enum.EasingStyle.Bounce,
  Enum.Material.Ice,
  Enum.HumanoidStateType.Running,
}

QuickNet:setEnumItems(enums)
```

## DateTime32 (4 bytes)
A DateTime object serialized using the unix timestamp in seconds.

## DateTime64 (8 bytes)
A DateTime object serialized using the unix timestamp in miliseconds.

## TweenInfo (6 bytes)
A TweenInfo object. The Time and DelayTime are both serialized using FX16 (16 bit fixed point), meaning their minimum and maximum values are -327.68 and 327.67, respectively, and they have a precision of 2 decimal places. The RepeatCount is stored as a NumberI8, and the rest of the fields are bit packed into a single byte.

## Instance
Any Roblox Instance which exists on both client and server. Since Instances cannot serialize into buffers, they are passed over the network directly. As a result, QuickNet does not usually have better performance than default RemoteEvents when sending Instances. There are a few exceptions under heavy load when QuickNet can take advantage of its call batching.

## Any
Any QuickNet data type. When using the Any type there is a 1 byte overhead to store the type tag.

## Optionals
To define an optional type simply use the Any type and cast it to the desired type. For example, if we wanted an optional Color3 we would do: ```data.Any :: Color3?```

## FX Types
FX stands for [fixed point](https://en.wikipedia.org/wiki/Fixed-point_arithmetic), which involves multiplying a value by a constant. For example, for FX8 the position values are multiplied by 10 when encoding, and dividied by 10 when decoding. Fixed point allows us to represent decimal values using integers, which helps reduce the data size and decrease CPU usage compared to floating point representations. One downside of fixed point is it limits the values to a small range. Therefore, when using FX types it's important to pay attention to the bounds.

## CFrames (6-24 bytes)
### FX Rotations
CFrame FX types follow the scaling discussed above for position, but not for rotation. Instead, for rotation values the full range of the integer type is mapped to [-π, π], meaning even with FX16 they retain very high precision. The CFrameF32FX16 type exists for that reason: it uses F32 for the position but FX16 for the rotation.

### Aligned CFrames
A CFrame is considered to be aligned if its rotatation is aligned with one of the 3 axes (X, Y, or Z). In simple terms, if each rotation value is a multiple of 90 degrees then the CFrame is aligned. Under this condition, the rotation can only have 24 possible states. Therefore, instead of sending the full rotation we can do some math to map the alignment to a number id that fits in 1 byte, saving a significant amount of bandwidth as well as CPU usage. The CFrameF32Aligned type does exactly this. When using this type if the given CFrame is not actually aligned, the serializer will automatically snap it to the nearest aligned axis. This behavior can be quite useful, since if your "aligned" CFrame is off by some rounding errors it will still work.

| CFrame Type | Minimum Value | Maximum Value | Size (bytes) |
|-------------|--------------|---------------| ---------------|
| CFrameFX8    | -12.8            | 12.7           | 6 |
| CFrameFX16   | -327.68            | 327.67       | 12 |
| CFrameF16  | -65,504          | 65,504 | 12 |
| CFrameF32Aligned  | -3.4e38          | 3.4e38 | 13 |
| CFrameF32FX16    |    -3.4e38     | 3.4e38          | 18 |
| CFrameF32   | -3.4e38      | 3.4e38        | 24 |

## Vector3 (3-12 bytes)

| Vector3 Type | Minimum Value | Maximum Value | Size (bytes) |
|-------------|--------------|---------------| ---------------|
| Vector3FX8    | -12.8            | 12.7           | 3 |
| Vector3FX16   | -327.68           | 327.67        | 6 |
| Vector3F16  | -65504          | 65504 | 6 |
| Vector3F32   | -3.4e38      | 3.4e38        | 12 |

## Vector2 (2-8 bytes)

| Vector2 Type | Minimum Value | Maximum Value | Size (bytes) |
|-------------|--------------|---------------| ---------------|
| Vector2FX8    | -12.8            | 12.7           | 2 |
| Vector2FX16   | -327.68            | 327.67       | 4 |
| Vector2F16  | -65,504          | 65,504 | 4 |
| Vector2F32   | -3.4e38      | 3.4e38        | 8 |

## Arrays
Arrays are tables with consecutive indices starting from 1. Examples of arrays:
```lua
local array1 = {1, 2, 3, 4, 5, 6, 7, 8}
local array2 = {[1] = "a", [2] = "b", [3] = "c", [4] = "d"}
local array3 = {CFrame.new(0,0,0), 5, "hello", workspace.Part, {1, 2, 3}}
```

Examples of non-arrays:
```lua
local notArray1 = {whatever = 56, blah = 123, someOtherKey = "whatever"}
local notArray2 = {[1] = "aa", [2] = "bb", [4] = "cc", [5] = "dd"}
local notArray3 = {[2] = 23423, [3] = 1234, [4] = 764}
```
QuickNet supports 3 types of arrays: static arrays, uniform arrays, and dynamic arrays.

### Static Array
Use a static array when the types of each element in the array is known at compile time and are not subject to change during run time. The byte size of a static array is simply the size of each element added up. To define a static array, list out each type in a table. For example: ```{data.NumberU8, data.String, data.Boolean, data.CFrameF32}```.

### Uniform Array
Use a uniform array when the type of each element is the same, but the number of elements can vary. Uniform arrays use 2 extra bytes to store the length, but have the highest CPU optimization. The byte size of a uniform array is the sum of the sizes of the elements plus the aforementioned 2 bytes. To define a uniform array, declare a table with 1 type inside of it, such as: ```{data.Vector3F32}```.

### Dynamic Array
Use a dynamic array when both the types of the elements and the number of them are not known at compile time. In other words, a dynamic array can contain any number of elements of any type. However, this flexibility comes at a significant cost to CPU usage and network bandwidth because QuickNet has to perform extra scans on each element to determine its type, then perform extra buffer operations to store a type tag for each element. The size of a dynamic array is the sum of the sizes of the elements plus 2 bytes for the length plus 1 byte for each element. To define a dynamic array simply declare a table with the Any type: ```{data.Any}```.

## Dictionaries
Dictionaries are tables with keys that aren't consecutive integers starting from 1. Examples of dictionaries:
```lua
local dict1 = {key1 = 234, key2 = 23432, key3 = 2}
local dict2 = {[5] = "a", [6] = "b", [7] = "c"}
```
Examples of non-dictionaries:
```lua
local notDict1 = {1, 55, 43, 89, 141241}
local notDict2 = {[1] = "whatever", [2] = "somestring", [3] = "someotherstring"}
```
QuickNet supports 3 types of dictionaries: static dictionaries, uniform dictionaries, and dynamic dictionaries. With some exceptions*, any QuickNet data type can be used as keys.

### Static Dictionary
Use a static dictionary when the keys themselves and the types of the values are known at compile time. Static dictionaries are extremely powerful because they can reduce the network traffic by 2x. How is this possible? Because the keys are known at compile time QuickNet is able to build a sorted keys map on start up, allowing us to send only the values over the network without losing any information. Therefore, the byte size of a static dictionary is only the sum of the sizes of each value. Furthermore, because we send 2x less data we also perform 2x less buffer operations, which significantly reduces the CPU overhead. Note that static dictionaries currently only support strings and numbers as keys (subject to change). To define a static dictionary, declare a table with the keys set equal to the types of the corresponding values: ```{name = data.String, health = data.NumberU32, speed = data.NumberU8, isAlive = data.Boolean}```.

### Uniform Dictionary
Use a uniform dictionary when the types of both the keys and values are known at compile time, but the number of key-value pairs can vary. Uniform dictionaries, like uniform arrays, use 2 extra bytes to store the number of key-value pairs, meaning the byte size is the total size of the elements plus 2 bytes. Nonetheless, it's highly optimized for CPU usage and should be used over dynamic dictionaries whenever possible. To define a uniform dictionary, declare a table with a single key-value entry where the key is the type of the keys and the value is the type of the values: ```{[data.String] = data.NumberU8}```.

### Dynamic Dictionary
Use a dynamic dictionary when the keys and values can be any type and there can be any number of key-value pairs. Like dynamic arrays, dynamic dictionaries have a significant cost to CPU usage and network bandwidth for the same reasons as discussed for the former. The byte size of a dynamic dictionary is the total size of all the keys and values plus 2 bytes for the length plus 1 byte for each key and each value. To define a dynamic dictionary: ```{[data.Any] = data.Any}```.

## Nested Arrays & Dictionaries
QuickNet supports any kind of nested table structure. In order to define a nested type, simply nest the table type definitions in the same way as your actual data. Some examples:
```lua
local dictsInArray = {
    {
      id = data.NumberU8,
      x = data.NumberU8,
      y = data.NumberU8,
      z = data.NumberU8,
      orientation = data.NumberU8,
      animation = data.NumberU8,
  }
}

local arraysInDict = { [data.String] = {data.Boolean, data.Color3, data.Vector3F32} }

local arraysInArraysInDictsInArray = { { [data.String] = { {data.NumberU8}, data.Vector2F32, data.CFrameFX16, data.NumberF64} } }
```
Any combination of the array and dictionary types can be nested any which way.

## Fast Paths
QuickNet can boost performance for eligible arrays and dictionaries via fast paths. Think of a fast path like an expressway. Internally, QuickNet takes advantage of data uniformity to vectorize operations, which reduces the number of buffer operations and function calls, and leads to significantly lower CPU usage. Currently, fast paths can be accessed when using static arrays where each element is the same type as every other element, uniform arrays, static dictionaries where each value is the same type as every other value, and uniform dictionaries. Here's a list of primitive types with fast paths:
* NumberU8
* NumberI32
* NumberF32
* String
* Boolean

## Limitations of Arrays and Dictionaries
* *Static dictionaries can only have numbers or strings as keys (subject to change)
* Uniform and dynamic arrays have a maximum size of 65,535 elements
* Uniform and dynamic dictionaries have a maximum of 65,535 key-value pairs
* Cyclic tables not supported
* Metatables not supported
* Tables containing functions not supported

## Performance
While QuickNet is highly optimized overall, it's not possible to achieve the same level of performance for every use case. Here are some tips to extract the maximum performance out of QuickNet:
* Take advantage of fast paths whenever possible
* Do not use Any type and dynamic tables unless necessary
* Avoid sending deeply nested tables
* Avoid sending instances (send names or instance IDs instead)
* Use NumberF32 over NumberF16 in most cases
* Send Vector3s instead of CFrames if there is no rotation

Note: not following these guidelines will not suddenly lag or crash your game; QuickNet should still have better performance than default Remotes. These guidelines are for users who want the absolute maximum performance.
