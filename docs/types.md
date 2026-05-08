# Types
This section explains how each type works and indicates their respective footprints.
## Numbers (1-8 bytes)
QuickNet supports all number types supported by the buffer library as well as float16 (F16). Because float16 lacks native support, using it incurrs much higher CPU overhead compared to other number types; this is despite QuickNet having a fairly optimal implementation of it. Below is a list of the supported number types with their ranges. Note that floating point numbers stop being able to accurately represent integer increments at values far above/below the min/max bounds.
| Number Type | Minimum Value | Maximum Value | Footprint (bytes) |
|-------------|--------------|---------------| ---------------|
| NumberU8    | 0            | 255           | 1 |
| NumberU16   | 0            | 65,535        | 2 |
| NumberU32   | 0            | 4,294,967,295 | 4 |
| NumberI8    | -128         | 127           | 1 |
| NumberI16   | -32,768      | 32,767        | 2 |
| NumberI32   | -2,147,483,648 | 2,147,483,647 | 4 |
| NumberF16   | -65504      | 65504        | 2 |
| NumberF32   | -3.4e38      | 3.4e38        | 4 |
| NumberF64   | -1.7e308     | 1.7e308       | 8 |

## String (length+1 bytes)
The String type can be used for any string but has a max length of 255 characters. For longer strings, use StringLong.

## StringLong (length+4 bytes)
Same as String except it uses 4 bytes to store the length, which allows a maximum of 4,294,967,295 characters.

## Boolean (1 bit/1 byte)
A ```true``` or ```false``` value. When sending many booleans at once in a table QuickNet will automatically bit pack the values, meaning each value will use 1 bit. When the data is not eligible for bit packing, each value will use 1 byte.

## Nil (0 bytes)
A ```nil ``` value.

## Color3 (3 bytes)
A Color3 object, such as 
```lua 
local color = Color3.new(1, 1, 1)
```

## Buffer (length+2 bytes)
Buffer object, max length 65535.

## EnumItem (1 byte)
Roblox EnumItem. To use this type, a list of the enums used must be supplied to QuickNet beforehand using the :setEnumItems method, which must be called on both client and server.
```lua
local enums = {
  Enum.EasingDirection.Out,
  Enum.EasingStyle.Bounce,
  Enum.Material.Ice,
  Enum.HumanoidStateType.Running,
}

QuickNet:setEnumItems(enums)
```

## Instance
Any Roblox Instance which exists on both client and server. Since Instances cannot serialize into buffers, they are passed over the network directly. As a result, QuickNet is not faster than default RemoteEvents when sending Instances.

## Any
When using the Any type there is a 1 byte overhead to store the type tag.

## CFrames (6-24 bytes)
FX stands for fixed point and is achieved by simply scaling the value by a constant. Doing so allows us to represent decimal values using integers at the cost of range. For example, for FX8 the position values are multiplied by 10 when encoding, and dividied by 10 when decoding. For rotation values the full range of the integer type is mapped to [-pi, pi], meaning even with FX16 the rotation values retain very high precision. The CFrameF32FX16 type exists for that reason: it uses F32 for the position but FX16 for the rotation.
| CFrame Type | Minimum Value | Maximum Value | Footprint (bytes) |
|-------------|--------------|---------------| ---------------|
| CFrameFX8    | -12.8            | 12.7           | 6 |
| CFrameFX16   | -256            | 255.9921875        | 12 |
| CFrameF16  | -65504          | 65504 | 12 |
| CFrameF32FX16    |    -3.4e38     | 3.4e38          | 18 |
| CFrameF32   | -3.4e38      | 3.4e38        | 24 |

## Vector3 (3-12 bytes)
| Vector3 Type | Minimum Value | Maximum Value | Footprint (bytes) |
|-------------|--------------|---------------| ---------------|
| Vector3FX8    | -12.8            | 12.7           | 3 |
| Vector3FX16   | -256            | 255.9921875        | 6 |
| Vector3F16  | -65504          | 65504 | 6 |
| Vector3F32   | -3.4e38      | 3.4e38        | 12 |

## Vector2 (2-8 bytes)
| Vector3 Type | Minimum Value | Maximum Value | Footprint (bytes) |
|-------------|--------------|---------------| ---------------|
| Vector2FX8    | -12.8            | 12.7           | 2 |
| Vector2FX16   | -256            | 255.9921875        | 4 |
| Vector2F16  | -65504          | 65504 | 4 |
| Vector2F32   | -3.4e38      | 3.4e38        | 8 |

## Arrays

