# Types
This section explains how each type works and indicates their respective footprints.
## Numbers (1-8 bytes)
QuickNet supports all number types supported by the buffer library as well as float16 (F16). Because float16 lacks native support, using it incurrs much higher CPU overhead compared to other number types; this is despite QuickNet having a fairly optimal implementation of it. Below is a list of the supported number types with their ranges. Note that floating point numbers stop being able to accurately represent integer increments at values far above/below the min/max bounds.
| Number Type | Minimum Value | Maximum Value | Footprint |
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
A ```lua true``` or ```lua false``` value. When sending many booleans at once in a table QuickNet will automatically bit pack the values, meaning each value will use 1 bit. When the data is not eligible for bit packing, each value will use 1 byte.

## Nil (0 bytes)
A ```lua nil ``` value.

## Color3 (3 bytes)
A Color3 object, such as ```lua local color = Color3.new(1, 1, 1) ```

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

## Instance (unknown bytes)
Any Roblox Instance which exists on both client and server. Since Instances cannot serialize into buffers, they are passed over the network directly. As a result, QuickNet is not faster than default RemoteEvents when sending Instances.

## CFrames
