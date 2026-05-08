# Types

## Numbers
QuickNet supports all number types supported by the buffer library as well as float16 (F16). Because float16 lacks native support, using it incurrs much higher CPU overhead compared to other number types; this is despite QuickNet having a fairly optimal implementation of it. Below is a list of the supported number types with their ranges. Note that floating point numbers stop being able to accurately represent integer increments at values far above/below the min/max bounds.
| Number Type | Minimum Value | Maximum Value |
|-------------|--------------|---------------|
| NumberU8    | 0            | 255           |
| NumberU16   | 0            | 65,535        |
| NumberU32   | 0            | 4,294,967,295 |
| NumberI8    | -128         | 127           |
| NumberI16   | -32,768      | 32,767        |
| NumberI32   | -2,147,483,648 | 2,147,483,647 |
| NumberF16   | -65504      | 65504        |
| NumberF32   | -3.4e38      | 3.4e38        |
| NumberF64   | -1.7e308     | 1.7e308       |

## String
The String type can be used for any string but has a max length of 255 characters. For longer strings, use StringLong.

## StringLong
Same as String except it has a maximum of 4,294,967,295 characters.

## Boolean
