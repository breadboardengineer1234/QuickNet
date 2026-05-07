--!optimize 2

local Types = require(script.Parent.Types)
local Enums = require(script.Parent.Enums)

type SchemaArg = Types.SchemaArg

local MAX_STR_LEN = 255
local MAX_BUFFER_LEN = 65535
local FX8_SCALE = 10
local FX8_ROT_SCALE = 40.42
local FX16_SCALE = 128
local FX16_ROT_SCALE = 10430
local DYNAMIC_DEFAULTS = {
	number = Enums.NumberF64,
	CFrame = Enums.CFrameF32,
	Vector3 = Enums.Vector3F32,
	Vector2 = Enums.Vector2F32,
	["nil"] = Enums.Nil,
	string = Enums.String,
	Color3 = Enums.Color3,
	boolean = Enums.Boolean,
	table = Enums.DictDynamic,
	buffer = Enums.Buffer,
	Instance = Enums.Instance,
}
local TBL_POOL_SIZE = 200

local writeu8 = buffer.writeu8 
local writeu16 = buffer.writeu16 
local writeu32 = buffer.writeu32 
local writei8 = buffer.writei8 
local writei16 = buffer.writei16 
local writei32 = buffer.writei32 
local writef32 = buffer.writef32 
local writef64 = buffer.writef64 
local writestring = buffer.writestring 
local readu8 = buffer.readu8 
local readu16 = buffer.readu16 
local readu32 = buffer.readu32 
local readi8 = buffer.readi8 
local readi16 = buffer.readi16 
local readi32 = buffer.readi32 
local readf32 = buffer.readf32 
local readf64 = buffer.readf64 
local readstring = buffer.readstring
local bufferCopy = buffer.copy
local stringLen = string.len
local stringSub = string.sub 
local mathRound = math.round
local mathFrexp = math.frexp 
local mathFloor = math.floor 
local mathHuge = math.huge 

local tablePool = table.create(TBL_POOL_SIZE)

for i = 1, TBL_POOL_SIZE do
	tablePool[i] = {}
end

@native local function getTable(): {any}
	local poolIdx = #tablePool
	local tbl = tablePool[poolIdx]
	tablePool[poolIdx] = nil
	return tbl or {}
end

@native local function recycleTable(tbl: {any})
	local poolIdx = #tablePool
	if poolIdx > TBL_POOL_SIZE then
		return
	end
	table.clear(tbl)
	tablePool[poolIdx + 1] = tbl
end

@native local function isArray(tbl: {any}): boolean
	local count = 1
	for i, val in tbl do
		if i ~= count then
			return false
		end
		count += 1
	end
	return true
end

@native local function getDataType(value: any): number?
	local generalType = typeof(value)
	local dataType = DYNAMIC_DEFAULTS[generalType] or Enums.Nil

	if generalType == "table" then
		if isArray(value) then
			dataType = Enums.ArrayDynamic
		end
	end
	return dataType
end

@native local function encodeFloat16(value: number): number
	if value == 0 then
		return value
	end
	local sign = 0
	if value < 0 then
		sign = 1
		value = -value
	end

	local mantissa, exponent = mathFrexp(value)
	local expNum = exponent + 14
	if expNum <= 0 then
		return 0
	elseif expNum >= 31 then
		return sign * 32768 + 31744
	end
	local mant = mantissa * 2048 - 1024
	mant = mathFloor(mant + .5)
	return sign * 32768 + expNum * 1024 + mant
end

@native local function decodeFloat16(value: number): number
	if value == 0 then
		return 0
	end

	local sign = (value >= 0x8000) and -1 or 1
	if sign == -1 then
		value -= 0x8000
	end

	local exponent = mathFloor(value / 1024)
	local mantissa = value - exponent * 1024

	if exponent == 0 then
		return 0
	elseif exponent == 31 then
		return sign * mathHuge
	end

	local normalized = 1 + mantissa / 1024
	return sign * normalized * 2^(exponent - 15)
end

--number
@native local function encodeNumberU8(buff: buffer, offset: number, arg: SchemaArg, value: number): number
	writeu8(buff, offset, value)
	return 1
end

@native local function encodeNumberU16(buff: buffer, offset: number, arg: SchemaArg, value: number): number
	writeu16(buff, offset, value)
	return 2
end

@native local function encodeNumberU32(buff: buffer, offset: number, arg: SchemaArg, value: number): number
	writeu32(buff, offset, value)
	return 4
end

@native local function encodeNumberI8(buff: buffer, offset: number, arg: SchemaArg, value: number): number
	writei8(buff, offset, value)
	return 1
end

@native local function encodeNumberI16(buff: buffer, offset: number, arg: SchemaArg, value: number): number
	writei16(buff, offset, value)
	return 2
end

@native local function encodeNumberI32(buff: buffer, offset: number, arg: SchemaArg, value: number): number
	writei32(buff, offset, value)
	return 4
end

@native local function encodeNumberF16(buff: buffer, offset: number, arg: SchemaArg, value: number): number
	writeu16(buff, offset, encodeFloat16(value))
	return 2	
end

@native local function encodeNumberF32(buff: buffer, offset: number, arg: SchemaArg, value: number): number
	writef32(buff, offset, value)
	return 4
end

@native local function encodeNumberF64(buff: buffer, offset: number, arg: SchemaArg, value: number): number
	writef64(buff, offset, value)
	return 8
end

@native local function decodeNumberU8(buff: buffer, offset: number, arg: SchemaArg): (number, number)
	return readu8(buff, offset), 1
end

@native local function decodeNumberU16(buff: buffer, offset: number, arg: SchemaArg): (number, number)
	return readu16(buff, offset), 2
end

@native local function decodeNumberU32(buff: buffer, offset: number, arg: SchemaArg): (number, number)
	return readu32(buff, offset), 4
end

@native local function decodeNumberI8(buff: buffer, offset: number, arg: SchemaArg): (number, number)
	return readi8(buff, offset), 1
end

@native local function decodeNumberI16(buff: buffer, offset: number, arg: SchemaArg): (number, number)
	return readi16(buff, offset), 2
end

@native local function decodeNumberI32(buff: buffer, offset: number, arg: SchemaArg): (number, number)
	return readi32(buff, offset), 4
end

@native local function decodeNumberF16(buff: buffer, offset: number, arg: SchemaArg): (number, number)
	return decodeFloat16(readu16(buff, offset)), 2
end

@native local function decodeNumberF32(buff: buffer, offset: number, arg: SchemaArg): (number, number)
	return readf32(buff, offset), 4
end

@native local function decodeNumberF64(buff: buffer, offset: number, arg: SchemaArg): (number, number)
	return readf64(buff, offset), 8
end

--cframe
@native local function encodeCFrameFX8(buff: buffer, offset: number, arg: SchemaArg, value: CFrame): number
	local pos = value.Position
	local x, y, z = value:ToEulerAnglesXYZ()
	writei8(buff, offset, pos.X * FX8_SCALE)
	writei8(buff, offset + 1, pos.Y * FX8_SCALE)
	writei8(buff, offset + 2, pos.Z * FX8_SCALE)
	writei8(buff, offset + 3, x * FX8_ROT_SCALE)
	writei8(buff, offset + 4, y * FX8_ROT_SCALE)
	writei8(buff, offset + 5, z * FX8_ROT_SCALE)
	return 6
end

@native local function encodeCFrameFX16(buff: buffer, offset: number, arg: SchemaArg, value: CFrame): number
	local pos = value.Position
	local x, y, z = value:ToEulerAnglesXYZ()
	writei16(buff, offset, pos.X * FX16_SCALE)
	writei16(buff, offset + 2, pos.Y * FX16_SCALE)
	writei16(buff, offset + 4, pos.Z * FX16_SCALE)
	writei16(buff, offset + 6, x * FX16_ROT_SCALE)
	writei16(buff, offset + 8, y * FX16_ROT_SCALE)
	writei16(buff, offset + 10, z * FX16_ROT_SCALE)
	return 12
end

@native local function encodeCFrameF16(buff: buffer, offset: number, arg: SchemaArg, value: CFrame): number
	local pos = value.Position
	local x, y, z = value:ToEulerAnglesXYZ()
	writeu16(buff, offset, encodeFloat16(pos.X))
	writeu16(buff, offset + 2, encodeFloat16(pos.Y))
	writeu16(buff, offset + 4, encodeFloat16(pos.Z))
	writeu16(buff, offset + 6, encodeFloat16(x))
	writeu16(buff, offset + 8, encodeFloat16(y))
	writeu16(buff, offset + 10, encodeFloat16(z))
	return 12
end

@native local function encodeCFrameF32FX16(buff: buffer, offset: number, arg: SchemaArg, value: CFrame): number
	local pos = value.Position
	local x, y, z = value:ToEulerAnglesXYZ()
	writef32(buff, offset, pos.X)
	writef32(buff, offset + 4, pos.Y)
	writef32(buff, offset + 8, pos.Z)
	writei16(buff, offset + 12, x * FX16_ROT_SCALE)
	writei16(buff, offset + 14, y * FX16_ROT_SCALE)
	writei16(buff, offset + 16, z * FX16_ROT_SCALE)
	return 18
end

@native local function encodeCFrameF32(buff: buffer, offset: number, arg: SchemaArg, value: CFrame): number
	local pos = value.Position
	local x, y, z = value:ToEulerAnglesXYZ()
	writef32(buff, offset, pos.X)
	writef32(buff, offset + 4, pos.Y)
	writef32(buff, offset + 8, pos.Z)
	writef32(buff, offset + 12, x)
	writef32(buff, offset + 16, y)
	writef32(buff, offset + 20, z)
	return 24
end

@native local function decodeCFrameFX8(buff: buffer, offset: number, arg: SchemaArg): (CFrame, number)
	local posX = readi8(buff, offset) / FX8_SCALE
	local posY = readi8(buff, offset + 1) / FX8_SCALE
	local posZ = readi8(buff, offset + 2) / FX8_SCALE
	local x = readi8(buff, offset + 3) / FX8_ROT_SCALE
	local y = readi8(buff, offset + 4) / FX8_ROT_SCALE
	local z = readi8(buff, offset + 5) / FX8_ROT_SCALE
	return CFrame.Angles(x, y, z) + Vector3.new(posX, posY, posZ), 6
end

@native local function decodeCFrameFX16(buff: buffer, offset: number, arg: SchemaArg): (CFrame, number)
	local posX = readi16(buff, offset) / FX16_SCALE
	local posY = readi16(buff, offset + 2) / FX16_SCALE
	local posZ = readi16(buff, offset + 4) / FX16_SCALE
	local x = readi16(buff, offset + 6) / FX16_ROT_SCALE
	local y = readi16(buff, offset + 8) / FX16_ROT_SCALE
	local z = readi16(buff, offset + 10) / FX16_ROT_SCALE
	return CFrame.Angles(x, y, z) + Vector3.new(posX, posY, posZ), 12
end

@native local function decodeCFrameF16(buff: buffer, offset: number, arg: SchemaArg): (CFrame, number)
	local posX = decodeFloat16(readu16(buff, offset))
	local posY = decodeFloat16(readu16(buff, offset + 2))
	local posZ = decodeFloat16(readu16(buff, offset + 4))
	local x = decodeFloat16(readu16(buff, offset + 6))
	local y = decodeFloat16(readu16(buff, offset + 8))
	local z = decodeFloat16(readu16(buff, offset + 10))
	return CFrame.Angles(x, y, z) + Vector3.new(posX, posY, posZ), 12
end

@native local function decodeCFrameF32FX16(buff: buffer, offset: number, arg: SchemaArg): (CFrame, number)
	local posX = readf32(buff, offset)
	local posY = readf32(buff, offset + 4)
	local posZ = readf32(buff, offset + 8)
	local x = readi16(buff, offset + 12) / FX16_ROT_SCALE
	local y = readi16(buff, offset + 14) / FX16_ROT_SCALE
	local z = readi16(buff, offset + 16) / FX16_ROT_SCALE
	return CFrame.Angles(x, y, z) + Vector3.new(posX, posY, posZ), 18
end

@native local function decodeCFrameF32(buff: buffer, offset: number, arg: SchemaArg): (CFrame, number)
	local posX = readf32(buff, offset)
	local posY = readf32(buff, offset + 4)
	local posZ = readf32(buff, offset + 8)
	local x = readf32(buff, offset + 12)
	local y = readf32(buff, offset + 16)
	local z = readf32(buff, offset + 20)
	return CFrame.Angles(x, y, z) + Vector3.new(posX, posY, posZ), 24
end

--vector3
@native local function encodeVector3FX8(buff: buffer, offset: number, arg: SchemaArg, value: Vector3): number
	writei8(buff, offset, value.X * FX8_SCALE)
	writei8(buff, offset + 1, value.Y * FX8_SCALE)
	writei8(buff, offset + 2, value.Z * FX8_SCALE)
	return 3
end

@native local function encodeVector3FX16(buff: buffer, offset: number, arg: SchemaArg, value: Vector3): number
	writei16(buff, offset, value.X * FX16_SCALE)
	writei16(buff, offset + 2, value.Y * FX16_SCALE)
	writei16(buff, offset + 4, value.Z * FX16_SCALE)
	return 6
end

@native local function encodeVector3F16(buff: buffer, offset: number, arg: SchemaArg, value: Vector3): number	
	writeu16(buff, offset, encodeFloat16(value.X))
	writeu16(buff, offset + 2, encodeFloat16(value.Y))
	writeu16(buff, offset + 4, encodeFloat16(value.Z))
	return 6
end

@native local function encodeVector3F32(buff: buffer, offset: number, arg: SchemaArg, value: Vector3): number
	writef32(buff, offset, value.X)
	writef32(buff, offset + 4, value.Y)
	writef32(buff, offset + 8, value.Z)
	return 12
end

@native local function decodeVector3FX8(buff: buffer, offset: number, arg: SchemaArg): (Vector3, number)
	local x = readi8(buff, offset) / FX8_SCALE
	local y = readi8(buff, offset + 1) / FX8_SCALE
	local z = readi8(buff, offset + 2) / FX8_SCALE
	return Vector3.new(x, y, z), 3
end

@native local function decodeVector3FX16(buff: buffer, offset: number, arg: SchemaArg): (Vector3, number)
	local x = readi16(buff, offset) / FX16_SCALE
	local y = readi16(buff, offset + 2) / FX16_SCALE
	local z = readi16(buff, offset + 4) / FX16_SCALE
	return Vector3.new(x, y, z), 6
end

@native local function decodeVector3F16(buff: buffer, offset: number, arg: SchemaArg): (Vector3, number)
	local x = decodeFloat16(readu16(buff, offset))
	local y = decodeFloat16(readu16(buff, offset + 2))
	local z = decodeFloat16(readu16(buff, offset + 4))
	return Vector3.new(x, y, z), 6
end

@native local function decodeVector3F32(buff: buffer, offset: number, arg: SchemaArg): (Vector3, number)
	local x = readf32(buff, offset)
	local y = readf32(buff, offset + 4)
	local z = readf32(buff, offset + 8)
	return Vector3.new(x, y, z), 12
end

--vector2
@native local function encodeVector2FX8(buff: buffer, offset: number, arg: SchemaArg, value: Vector2): number
	writei8(buff, offset, value.X * FX8_SCALE)
	writei8(buff, offset + 1, value.Y * FX8_SCALE)
	return 2
end

@native local function encodeVector2FX16(buff: buffer, offset: number, arg: SchemaArg, value: Vector2): number
	writei16(buff, offset, value.X * FX16_SCALE)
	writei16(buff, offset + 2, value.Y * FX16_SCALE)
	return 4
end

@native local function encodeVector2F16(buff: buffer, offset: number, arg: SchemaArg, value: Vector2): number
	writeu16(buff, offset, encodeFloat16(value.X))
	writeu16(buff, offset + 2, encodeFloat16(value.Y))
	return 4
end

@native local function encodeVector2F32(buff: buffer, offset: number, arg: SchemaArg, value: Vector2): number
	writef32(buff, offset, value.X)
	writef32(buff, offset + 4, value.Y)
	return 8
end

@native local function decodeVector2FX8(buff: buffer, offset: number, arg: SchemaArg): (Vector2, number)
	local x = readi8(buff, offset) / FX8_SCALE
	local y = readi8(buff, offset + 1) / FX8_SCALE
	return Vector2.new(x, y), 2
end

@native local function decodeVector2FX16(buff: buffer, offset: number, arg: SchemaArg): (Vector2, number)
	local x = readi16(buff, offset) / FX16_SCALE
	local y = readi16(buff, offset + 2) / FX16_SCALE
	return Vector2.new(x, y), 4
end

@native local function decodeVector2F16(buff: buffer, offset: number, arg: SchemaArg): (Vector2, number)
	local x = decodeFloat16(readu16(buff, offset))
	local y = decodeFloat16(readu16(buff, offset + 2))
	return Vector2.new(x, y), 4
end

@native local function decodeVector2F32(buff: buffer, offset: number, arg: SchemaArg): (Vector2, number)
	local x = readf32(buff, offset)
	local y = readf32(buff, offset + 4)
	return Vector2.new(x, y), 8
end

--misc
@native local function encodeString(buff: buffer, offset: number, arg: SchemaArg, value: string): number
	local bytes = stringLen(value)
	writeu8(buff, offset, bytes)
	writestring(buff, offset + 1, value, bytes)
	return bytes + 1
end

@native local function decodeString(buff: buffer, offset: number, arg: SchemaArg): (string, number)
	local bytes = readu8(buff, offset)
	return readstring(buff, offset + 1, bytes), bytes + 1
end

@native local function encodeStringLong(buff: buffer, offset: number, arg: SchemaArg, value: string): number
	local bytes = stringLen(value)
	writeu32(buff, offset, bytes)
	writestring(buff, offset + 4, value, bytes)
	return bytes + 4
end

@native local function decodeStringLong(buff: buffer, offset: number, arg: SchemaArg, value: string): (string, number)
	local bytes = readu32(buff, offset)
	return readstring(buff, offset + 4, bytes), bytes + 4
end

@native local function encodeColor(buff: buffer, offset: number, arg: SchemaArg, value: Color3): number
	writeu8(buff, offset, mathRound(value.R * 255))
	writeu8(buff, offset + 1, mathRound(value.G * 255))
	writeu8(buff, offset + 2, mathRound(value.B * 255))
	return 3
end

@native local function decodeColor(buff: buffer, offset: number, arg: SchemaArg): (Color3, number)
	local r = readu8(buff, offset)
	local g = readu8(buff, offset + 1)
	local b = readu8(buff, offset + 2)
	return Color3.new(r / 255, g / 255, b / 255), 3
end

@native local function encodeBool(buff: buffer, offset: number, arg: SchemaArg, value: boolean): number
	writeu8(buff, offset, value and 1 or 0)
	return 1
end

@native local function decodeBool(buff: buffer, offset: number, arg: SchemaArg): (boolean, number)
	local val = readu8(buff, offset)
	return val == 1, 1
end

@native local function encodeNil(buff: buffer, offset: number, arg: SchemaArg, value: any): number
	return 0
end

@native local function decodeNil(buff: buffer, offset: number, arg: SchemaArg): (any, number)
	return nil, 0
end

@native local function encodeBuffer(buff: buffer, offset: number, arg: SchemaArg, value: buffer): number
	local len = buffer.len(value)
	writeu16(buff, offset, len)
	bufferCopy(buff, offset + 2, value, 0, len)
	return len + 2
end

@native local function decodeBuffer(buff: buffer, offset: number, arg: SchemaArg): (buffer?, number)
	local len = readu16(buff, offset)
	if len > MAX_BUFFER_LEN then
		return nil, 2
	end
	local newBuff = buffer.create(len)
	bufferCopy(newBuff, 0, buff, offset + 2, len)
	return newBuff, len + 2
end

@native local function encodeBulkNumberU8Array(buff: buffer, offset: number, array: {number}): number
	local ptr = offset
	local arrayLen = #array
	local mod = arrayLen % 4
	local iters = (arrayLen - mod) / 4
	local bytePtr = 1
	
	for i = 1, iters do
		writeu32(buff, ptr, 
				array[bytePtr] +
				array[bytePtr + 1] * 256 +
				array[bytePtr + 2] * 65536 +
				array[bytePtr + 3] * 16777216
		)
		ptr += 4
		bytePtr += 4
	end
	
	for i = arrayLen - mod + 1, arrayLen do
		writeu8(buff, ptr, array[i])
		ptr += 1
	end
	return ptr - offset
end

@native local function decodeBulkNumberU8Array(buff: buffer, offset: number, arrayLen: number, tbl: {any}?)
	: ({number}, number)
	local ptr = offset
	local array = tbl or table.create(arrayLen)
	local mod = arrayLen % 4
	local iters = (arrayLen - mod) / 4
	local bytePtr = 1
	
	for i = 1, iters do
		local b = readu32(buff, ptr)
		local b1 = b // 256
		local b2 = b1 // 256
		local b3 = b2 // 256		
		array[bytePtr]     = b - b1 * 256
		array[bytePtr + 1] = b1 - b2 * 256
		array[bytePtr + 2] = b2 - b3 * 256
		array[bytePtr + 3] = b3
		ptr += 4
		bytePtr += 4
	end
	
	for i = arrayLen - mod + 1, arrayLen do
		array[i] = readu8(buff, ptr)
		ptr += 1
	end
	return array, ptr - offset
end

@native local function encodeBulkNumberI32Array(buff: buffer, offset: number, array: {number}): number
	local ptr = offset
	for _, val in array do
		writei32(buff, ptr, val)
		ptr += 4
	end
	return ptr - offset
end

@native local function decodeBulkNumberI32Array(buff: buffer, offset: number, arrayLen: number, tbl: {any}?)
	: ({number}, number)
	local ptr = offset
	local array = tbl or table.create(arrayLen)
	for i = 1, arrayLen do
		array[i] = readi32(buff, ptr)
		ptr += 4
	end
	return array, ptr - offset
end

@native local function encodeBulkNumberF32Array(buff: buffer, offset: number, array: {number}): number
	local ptr = offset
	for _, val in array do
		writef32(buff, ptr, val)
		ptr += 4
	end
	return ptr - offset
end

@native local function decodeBulkNumberF32Array(buff: buffer, offset: number, arrayLen: number, tbl: {any}?)
	: ({number}, number)
	local ptr = offset
	local array = tbl or table.create(arrayLen)
	for i = 1, arrayLen do
		array[i] = readf32(buff, ptr)
		ptr += 4
	end
	return array, ptr - offset
end

@native local function encodeBulkBoolArray(buff: buffer, offset: number, array: {boolean}): number
	local ptr = offset
	local arrayLen = #array
	local mod = arrayLen % 8
	local bitIters = (arrayLen - mod) / 8

	local bitPtr = 1
	for i = 1, bitIters do
		writeu8(buff, ptr,
				(array[bitPtr] and 1 or 0) +
				(array[bitPtr + 1] and 2 or 0) + 
				(array[bitPtr + 2] and 4 or 0) +
				(array[bitPtr + 3] and 8 or 0) +
				(array[bitPtr + 4] and 16 or 0) +
				(array[bitPtr + 5] and 32 or 0) +
				(array[bitPtr + 6] and 64 or 0) +
				(array[bitPtr + 7] and 128 or 0)
		)
		bitPtr += 8
		ptr += 1
	end
	
	for i = arrayLen - mod + 1, arrayLen do
		writeu8(buff, ptr, array[i] and 1 or 0)
		ptr += 1
	end
	
	return ptr - offset
end

local byteToBools = table.create(256)
local function buildByteToBools()
	for byte = 0, 255 do
		local t = table.create(8)
		local val = byte

		for i = 1, 8 do
			t[i] = (val % 2) == 1
			val = val // 2
		end
		byteToBools[byte] = t
	end
end

buildByteToBools()

@native local function decodeBulkBoolArray(buff: buffer, offset: number, arrayLen: number, tbl: {any}?)
	: ({boolean}, number)
	local ptr = offset
	local array = tbl or table.create(arrayLen)
	local mod = arrayLen % 8
	local bitIters = (arrayLen - mod) / 8
	local bitPtr = 1

	for i = 1, bitIters do
		local byte = readu8(buff, ptr)
		ptr += 1
		
		local bits = byteToBools[byte]
		array[bitPtr]     = bits[1]
		array[bitPtr + 1] = bits[2]
		array[bitPtr + 2] = bits[3]
		array[bitPtr + 3] = bits[4]
		array[bitPtr + 4] = bits[5]
		array[bitPtr + 5] = bits[6]
		array[bitPtr + 6] = bits[7]
		array[bitPtr + 7] = bits[8]
		
		bitPtr += 8
	end
	
	for i = arrayLen - mod + 1, arrayLen do
		array[i] = readu8(buff, ptr) == 1
		ptr += 1
	end
	
	return array, ptr - offset
end

@native local function encodeBulkStringArray(buff: buffer, offset: number, array: {string}): number
	local totalLen = 0
	local ptr = offset

	for _, str in array do
		local len = stringLen(str)
		writeu8(buff, ptr, len)
		ptr += 1
		totalLen += len
	end

	local largeStr = table.concat(array)
	writestring(buff, ptr, largeStr, totalLen)
	return ptr + totalLen - offset
end

@native local function decodeBulkStringArray(buff: buffer, offset: number, arrayLen: number, tbl: {any}?)
	: ({string}, number)
	local ptr = offset
	local lens = getTable()
	local totalLen = 0
	local array = tbl or table.create(arrayLen)
	for i = 1, arrayLen do
		local len = readu8(buff, ptr)
		lens[i] = len
		ptr += 1
		totalLen += len
	end
	
	local largeStr = readstring(buff, ptr, totalLen)
	local largeStrPtr = 1
	
	for i, len in lens do
		local start = largeStrPtr
		largeStrPtr += len
		array[i] = stringSub(largeStr, start, largeStrPtr - 1)
	end	
	recycleTable(lens)
	return array, ptr + totalLen - offset
end

@native local function encodeBulkNumberU8DictStatic(buff: buffer, offset: number, dict: {[any]: number}, keysMap: {any})
	: number
	local ptr = offset
	for _, key in keysMap do
		writeu8(buff, ptr, dict[key])
		ptr += 1
	end
	return ptr - offset
end

@native local function decodeBulkNumberU8DictStatic(buff: buffer, offset: number, keysMap: {any}, 
	template: {[string | number]: any}): ({[any]: number}, number)
	local ptr = offset
	local dict = table.clone(template)
	for _, key in keysMap do
		dict[key] = readu8(buff, ptr)
		ptr += 1
	end
	return dict, ptr - offset
end

@native local function encodeBulkNumberI32DictStatic(buff: buffer, offset: number, dict: {[any]: number}, keysMap: {any})
	: number
	local ptr = offset
	for _, key in keysMap do
		writei32(buff, ptr, dict[key])
		ptr += 4
	end
	return ptr - offset
end

@native local function decodeBulkNumberI32DictStatic(buff: buffer, offset: number, keysMap: {any},
	template: {[string | number]: any}): ({[any]: number}, number)
	local ptr = offset
	local dict = table.clone(template)
	for _, key in keysMap do
		dict[key] = readi32(buff, ptr)
		ptr += 4
	end
	return dict, ptr - offset
end

@native local function encodeBulkNumberF32DictStatic(buff: buffer, offset: number, dict: {[any]: number}, keysMap: {any})
	: number
	local ptr = offset

	for _, key in keysMap do
		writef32(buff, ptr, dict[key])
		ptr += 4
	end
	return ptr - offset
end

@native local function decodeBulkNumberF32DictStatic(buff: buffer, offset: number, keysMap: {any},
	template: {[string | number]: any}): ({[any]: number}, number)
	local ptr = offset
	local dict = table.clone(template)
	for _, key in keysMap do
		dict[key] = readf32(buff, ptr)
		ptr += 4
	end
	return dict, ptr - offset
end

@native local function encodeBulkBoolDictStatic(buff: buffer, offset: number, dict: {[any]: boolean}, keysMap: {any})
	: number
	local ptr = offset
	for _, key in keysMap do
		writeu8(buff, ptr, dict[key] and 1 or 0)
		ptr += 1
	end
	return ptr - offset
end

@native local function decodeBulkBoolDictStatic(buff: buffer, offset: number, keysMap: {any},
	template: {[string | number]: any}): ({[any]: boolean}, number)
	local ptr = offset
	local dict = table.clone(template)
	for _, key in keysMap do
		dict[key] = readu8(buff, ptr) == 1
		ptr += 1
	end
	return dict, ptr - offset
end

@native local function encodeBulkStringDictStatic(buff: buffer, offset: number, dict: {[any]: string}, keysMap: {any})
	: number
	local ptr = offset
	local str = getTable()
	
	for i, key in keysMap do
		local val = dict[key]
		local strLen = stringLen(val)
		writeu8(buff, ptr, strLen)
		ptr += 1
		str[i] = val
	end
	
	local largeStr = table.concat(str)
	local totalStrLen = stringLen(largeStr)
	writestring(buff, ptr, largeStr, totalStrLen)
	ptr += totalStrLen
	recycleTable(str)
	return ptr - offset
end

@native local function decodeBulkStringDictStatic(buff: buffer, offset: number, keysMap: {any},
	template: {[string | number]: any}): ({[any]: string}, number)
	local ptr = offset
	local dictLen = #keysMap
	local strPtr = 1
	local totalLen = 0
	local dict = table.clone(template)
	local lens = getTable()
	
	for i = 1, dictLen do
		local len = readu8(buff, ptr)
		lens[i] = len
		totalLen += len
		ptr += 1
	end
	
	local largeStr = readstring(buff, offset + dictLen, totalLen)
	for i, key in keysMap do
		local start = strPtr
		strPtr += lens[i]
		dict[key] = stringSub(largeStr, start, strPtr - 1)
	end
	recycleTable(lens)
	return dict, strPtr - offset
end

@native local function encodeBulkNumberU8Dict(buff: buffer, offset: number, dict: {[any]: number}, keys: boolean?)
	: (number, number?)
	local ptr = offset
	local len
	
	if keys then
		for key, val in dict do
			writeu8(buff, ptr, key)
			ptr += 1
		end
		len = ptr - offset
	else
		for key, val in dict do
			writeu8(buff, ptr, val)
			ptr += 1
		end
	end
	return ptr - offset, len
end

@native local function encodeBulkNumberI32Dict(buff: buffer, offset: number, dict: {[any]: number}, keys: boolean?)
	: (number, number?)
	local ptr = offset
	local len

	if keys then
		for key, val in dict do
			writei32(buff, ptr, key)
			ptr += 4
		end
		len = ptr - offset
	else
		for key, val in dict do
			writei32(buff, ptr, val)
			ptr += 4
		end
	end
	return ptr - offset, len
end

@native local function encodeBulkNumberF32Dict(buff: buffer, offset: number, dict: {[any]: number}, keys: boolean)
	: (number, number?)
	local ptr = offset
	local len
	
	if keys then
		for key, val in dict do
			writef32(buff, ptr, key)
			ptr += 4
		end
		len = (ptr - offset) / 4
	else
		for key, val in dict do
			writef32(buff, ptr, val)
			ptr += 4
		end
	end
	return ptr - offset, len
end

@native local function encodeBulkBoolDict(buff: buffer, offset: number, dict: {[any]: boolean}, keys: boolean?)
	: (number, number?)
	local ptr = offset
	local len
	
	if keys then
		for key, val in dict do
			writeu8(buff, ptr, key and 1 or 0)
			ptr += 1
		end
		len = ptr - offset
	else
		for key, val in dict do
			writeu8(buff, ptr, val and 1 or 0)
			ptr += 1
		end
	end
	return ptr - offset, len
end

@native local function encodeBulkStringDict(buff: buffer, offset: number, dict: {[any]: string}, keys: boolean?)
	: (number, number?)
	local ptr = offset
	local str = getTable()
	
	local len
	if keys then
		len = 0
		for key, val in dict do
			local strLen = stringLen(key)
			writeu8(buff, ptr, strLen)
			ptr += 1
			len += 1
			str[len] = key
		end
	else
		local count = 0
		for key, val in dict do
			local strLen = stringLen(val)
			writeu8(buff, ptr, strLen)
			ptr += 1
			count += 1
			str[count] = val
		end
	end	
	local largeStr = table.concat(str)
	local totalStrLen = stringLen(largeStr)
	writestring(buff, ptr, largeStr, totalStrLen)
	ptr += totalStrLen
	recycleTable(str)
	return ptr - offset, len
end

local enumItems: {EnumItem} = {}
local enumItemsByEnum: {[EnumItem]: number} = {}
local encodeData: {[number]: (buffer, number, any, any?, any?) -> number}
local decodeData: {[number]: (buffer, number, any?, any?) -> (any, number)}

@native local function encodeEnumItem(buff: buffer, offset: number, arg: SchemaArg, value: EnumItem): number
	writeu16(buff, offset, enumItemsByEnum[value] or 0)
	return 2
end

@native local function decodeEnumItem(buff: buffer, offset: number, arg: SchemaArg): (EnumItem?, number)
	local idx = readu16(buff, offset)
	return enumItems[idx], 2
end

@native local function encodeInstance(buff: buffer, offset: number, arg: SchemaArg, value: Instance, inst: {Instance})
	: number
	inst[#inst + 1] = value
	return 0
end

@native local function decodeInstance(buff: buffer, offset: number, arg: SchemaArg, inst: {Instance})
	: (Instance, number)
	local ptrIdx = #inst
	local ptr = inst[ptrIdx]
	inst[ptrIdx] += 1
	return inst[ptr], 0
end

@native local function encodeAny(buff: buffer, offset: number, arg: SchemaArg, value: any, inst: {Instance}): number
	local dataType = getDataType(value)
	writeu8(buff, offset, dataType)
	local bytes = 1
	local encode = encodeData[dataType] :: ((buffer, number, SchemaArg, any, {Instance}?) -> number)?
	bytes += encode(buff, offset + bytes, arg, value, inst)
	return bytes
end

@native local function decodeAny(buff: buffer, offset: number, arg: SchemaArg, inst: {Instance}?): (any, number)
	local dataType = readu8(buff, offset)
	local bytes = 1
	local decode = decodeData[dataType] :: (buffer, number, SchemaArg, {Instance}?) -> (any, number)
	if not decode then
		return nil, 1
	end
	local val, b = decode(buff, offset + bytes, arg, inst)
	bytes += b
	return val, bytes
end

@native local function encodeArrayStatic(buff: buffer, offset: number, schema: SchemaArg, array: {any}, inst: {Instance})
	: number
	local ptr = offset
	local fastPath = schema[3]
	
	if fastPath then
		ptr += encodeData[fastPath](buff, ptr, array)
		return ptr - offset
	end
	
	for idx, arg: SchemaArg in schema[2] do
		local encode = encodeData[arg] or encodeData[arg[1]] 
		:: (buffer, number, SchemaArg, any, {Instance}?) -> number
		ptr += encode(buff, ptr, arg, array[idx], inst)
	end
	return ptr - offset
end

@native local function decodeArrayStatic(buff: buffer, offset: number, schema: {SchemaArg}, inst: {Instance}?)
	: ({any}, number)
	local ptr = offset
	local data = schema[2]
	local fastPath = schema[3]
	
	if fastPath then
		local array, b = decodeData[fastPath](buff, ptr, #data)
		return array, ptr + b - offset
	end
	
	local array = {}
	for i, arg: SchemaArg in data do
		local decode = decodeData[arg] or decodeData[arg[1]] 
		:: (buffer, number, SchemaArg, {Instance}?) -> (any, number)
		local val, b = decode(buff, ptr, arg, inst)
		ptr += b
		array[i] = val
	end
	return array, ptr - offset
end

@native local function encodeArray(buff: buffer, offset: number, schema: SchemaArg, array: {any}, inst: {Instance})
	: number
	local len = #array
	writeu16(buff, offset, len)
	local ptr = offset + 2
	
	local fastPath = schema[3]
	if fastPath then
		ptr += encodeData[fastPath](buff, ptr, array)
		return ptr - offset
	end
	
	local arg = schema[2]
	local encode = encodeData[arg] or encodeData[arg[1]] :: (buffer, number, SchemaArg, any, {Instance}?) -> number
	for i, value in array do
		ptr += encode(buff, ptr, arg, value, inst)
	end
	return ptr - offset
end

@native local function decodeArray(buff: buffer, offset: number, schema: SchemaArg, inst: {Instance}?): ({any}, number)
	local len = readu16(buff, offset)
	local ptr = offset + 2
	
	local fastPath = schema[3]
	if fastPath then
		local array, b = decodeData[fastPath](buff, ptr, len)
		return array, ptr + b - offset
	end
	
	local arg = schema[2]
	local decode = decodeData[arg] or decodeData[arg[1]] 
	:: (buffer, number, SchemaArg, {Instance}?) -> (any, number)
	local array = table.create(len)

	for i = 1, len do
		local val, b = decode(buff, ptr, arg, inst)
		ptr += b
		array[i] = val
	end
	return array, ptr - offset
end

@native local function encodeArrayDynamic(buff: buffer, offset: number, schema: SchemaArg, array: {any}, inst: {Instance})
	: number
	local len = #array
	writeu16(buff, offset, len)
	local ptr = offset + 2

	for i = 1, len do
		local val = array[i]
		local dataType = getDataType(val)
		writeu8(buff, ptr, dataType)
		ptr += 1
		local encode = encodeData[dataType] :: (buffer, number, SchemaArg, any, {Instance}?) -> number
		ptr += encode(buff, ptr, schema, val, inst)
	end
	return ptr - offset
end

@native local function decodeArrayDynamic(buff: buffer, offset: number, schema: SchemaArg, inst: {Instance}?)
	: ({any}, number)
	local len = readu16(buff, offset)
	local ptr = offset + 2
	local array = table.create(len)

	for i = 1, len do
		local dataType = readu8(buff, ptr)
		ptr += 1
		local decode = decodeData[dataType] or decodeData[Enums.Nil] 
		:: (buffer, number, SchemaArg, {Instance}?) -> (any, number)
		local val, b = decode(buff, ptr, schema, inst)
		ptr += b
		array[i] = val
	end
	return array, ptr - offset
end

@native local function encodeDictStatic(buff: buffer, offset: number, schema: SchemaArg, dict: {[string | number]: any},
	inst: {Instance}): number
	local ptr = offset
	local data = schema[2]
	local keysMap = schema[3]
	local fastPath = schema[5]
	
	if fastPath then
		ptr += encodeData[fastPath](buff, ptr, dict, keysMap)
		return ptr - offset
	end
	
	local idx = 0	
	for i, key in keysMap do
		idx += 1
		local arg = data[idx]
		local val = dict[key]
		local encode = encodeData[arg] or encodeData[arg[1]] :: 
		(buffer, number, SchemaArg, any, {Instance}?) -> number
		ptr += encode(buff, ptr, arg, val, inst)
	end
	return ptr - offset
end

@native local function decodeDictStatic(buff: buffer, offset: number, schema: SchemaArg, inst: {Instance}?)
	: ({[number | string]: any}, number)
	local ptr = offset
	local data = schema[2]
	local keysMap = schema[3]
	local template = schema[4]
	local fastPath = schema[5]
	
	if fastPath then
		local values, b = decodeData[fastPath](buff, ptr, keysMap, template)
		ptr += b
		return values, ptr - offset
	end
	
	local dict = table.clone(template)	
	for i, arg in data do
		local decode = decodeData[arg] or decodeData[arg[1]] 
		:: (buffer, number, SchemaArg, {Instance}?) -> (any, number)
		local val, b = decode(buff, ptr, arg, inst)
		ptr += b
		local key = keysMap[i]
		dict[key] = val
	end
	return dict, ptr - offset
end

@native local function encodeDict(buff: buffer, offset: number, schema: SchemaArg, dict: {[any]: any}, inst: {Instance})
	: number
	local len = 0
	local ptr = offset + 2	
	local keyFastPath = schema[4]
	local valFastPath = schema[5]
	
	if keyFastPath then
		local bytes
		bytes, len = encodeData[keyFastPath](buff, ptr, dict, true)
		ptr += bytes
	else
		local keyArg = schema[2]
		local encodeKey = encodeData[keyArg] or encodeData[keyArg[1]] 
		:: (buffer, number, SchemaArg, any, {Instance}?) -> number
		for key, val in dict do
			ptr += encodeKey(buff, ptr, keyArg, key, inst)
			len += 1
		end
	end
	
	if valFastPath then
		ptr += encodeData[valFastPath](buff, ptr, dict)
	else
		local valArg = schema[3]
		local encodeVal = encodeData[valArg] or encodeData[valArg[1]] 
		:: (buffer, number, SchemaArg, any, {Instance}?) -> number
		for key, val in dict do
			ptr += encodeVal(buff, ptr, valArg, val, inst)
		end
	end

	writeu16(buff, offset, len)
	return ptr - offset
end

local dictTempCache: {[number]: {[any]: any}} = {}

@native local function decodeDict(buff: buffer, offset: number, schema: SchemaArg, inst: {Instance}?): ({[any]: any}, number)
	local len = readu16(buff, offset)
	local ptr = offset + 2	
	local keyFastPath = schema[4]
	local valFastPath = schema[5]	
	local keys, vals = getTable(), getTable()
	
	if keyFastPath then
		local bytes
		keys, bytes = decodeData[keyFastPath](buff, ptr, len, keys)
		ptr += bytes
	else
		local keyArg = schema[2]
		local decodeKey = decodeData[keyArg] or decodeData[keyArg[1]] 
		:: (buffer, number, SchemaArg, {Instance}?) -> (any, number)
		for i = 1, len do
			local key, b = decodeKey(buff, ptr, keyArg, inst)
			ptr += b
			keys[i] = key
		end
	end
	
	if valFastPath then
		local bytes
		vals, bytes = decodeData[valFastPath](buff, ptr, len, vals)
		ptr += bytes
	else
		local valArg = schema[3]
		local decodeVal = decodeData[valArg] or decodeData[valArg[1]] 
		:: (buffer, number, SchemaArg, {Instance}?) -> (any, number)
		for i = 1, len do
			local val, b = decodeVal(buff, ptr, valArg, inst)
			ptr += b
			vals[i] = val
		end
	end
	
	local dictId = schema[6]
	local template = dictTempCache[dictId]
	local dict
	if template then
		dict = table.clone(template)
		table.clear(dict)
	else
		dict = {}
	end

	for i, key in keys do
		dict[key] = vals[i]
	end
	recycleTable(keys)
	recycleTable(vals)
	if not template then
		dictTempCache[dictId] = table.clone(dict)
	end
	return dict, ptr - offset
end

@native local function encodeDictDynamic(buff: buffer, offset: number, schema: SchemaArg, dict: {[any]: any},
	inst: {Instance}): number
	local startOffset = offset
	local ptr = offset + 2
	local idx = 0

	for key, val in dict do
		local keyType = getDataType(key)	
		local encodeKey = encodeData[keyType] ::  (buffer, number, SchemaArg, any, {Instance}?) -> number
		writeu8(buff, ptr, keyType)			
		ptr += 1
		ptr += encodeKey(buff, ptr, schema, key, inst)
		
		local valType = getDataType(val)
		local encodeVal = encodeData[valType] :: (buffer, number, SchemaArg, any, {Instance}?) -> number
		writeu8(buff, ptr, valType)
		ptr += 1
		ptr += encodeVal(buff, ptr, schema, val, inst)
		idx += 1
	end
	writeu16(buff, offset, idx)
	return ptr - offset
end

@native local function decodeDictDynamic(buff: buffer, offset: number, schema: SchemaArg, inst: {Instance}?)
	: ({[any]: any}, number)
	local len = buffer.readu16(buff, offset)
	local ptr = offset + 2
	local dictId = schema[2]
	local template = dictTempCache[dictId]
	local dict
	if template then
		dict = table.clone(template)
		table.clear(dict)
	else
		dict = {}
	end

	for i = 1, len do
		local keyType = readu8(buff, ptr)
		ptr += 1
		local decodeKey = decodeData[keyType] or decodeData[Enums.Nil] 
		:: (buffer, number, SchemaArg, {Instance}?) -> (any, number)
		local key, b = decodeKey(buff, ptr, schema, inst)
		ptr += b

		local valType = readu8(buff, ptr)
		ptr += 1
		local decodeVal = decodeData[valType] or decodeData[Enums.Nil] 
		:: (buffer, number, SchemaArg, {Instance}?) -> (any, number)
		local val, b = decodeVal(buff, ptr, schema, inst)
		ptr += b
		dict[key] = val
	end
	if not template then
		dictTempCache[dictId] = table.clone(dict)
	end
	return dict, ptr - offset
end

encodeData = {
	[Enums.Start] = function() end,
	[Enums.NumberU8] = encodeNumberU8,
	[Enums.NumberU16] = encodeNumberU16,
	[Enums.NumberU32] = encodeNumberU32,
	[Enums.NumberI8] = encodeNumberI8,
	[Enums.NumberI16] = encodeNumberI16,
	[Enums.NumberI32] = encodeNumberI32,
	[Enums.NumberF16] = encodeNumberF16,
	[Enums.NumberF32] = encodeNumberF32,
	[Enums.NumberF64] = encodeNumberF64,

	[Enums.CFrameFX8] = encodeCFrameFX8,
	[Enums.CFrameFX16] = encodeCFrameFX16,
	[Enums.CFrameF16] = encodeCFrameF16,
	[Enums.CFrameF32FX16] = encodeCFrameF32FX16,
	[Enums.CFrameF32] = encodeCFrameF32,

	[Enums.Vector3FX8] = encodeVector3FX8,
	[Enums.Vector3FX16] = encodeVector3FX16,
	[Enums.Vector3F16] = encodeVector3F16,
	[Enums.Vector3F32] = encodeVector3F32,

	[Enums.Vector2FX8] = encodeVector2FX8,
	[Enums.Vector2FX16] = encodeVector2FX16,
	[Enums.Vector2F16] = encodeVector2F16,
	[Enums.Vector2F32] = encodeVector2F32,

	[Enums.String] = encodeString,
	[Enums.StringLong] = encodeStringLong,
	[Enums.Color3] = encodeColor,
	[Enums.Boolean] = encodeBool,
	[Enums.Nil] = encodeNil,
	[Enums.Buffer] = encodeBuffer,
	[Enums.EnumItem] = encodeEnumItem,
	[Enums.Instance] = encodeInstance,

	[Enums.Any] = encodeAny,
	[Enums.ArrayStatic] = encodeArrayStatic,
	[Enums.Array] = encodeArray,
	[Enums.ArrayDynamic] = encodeArrayDynamic,
	[Enums.DictStatic] = encodeDictStatic,
	[Enums.Dict] = encodeDict,
	[Enums.DictDynamic] = encodeDictDynamic,
	
	[Enums.FastNumberU8Array] = encodeBulkNumberU8Array,
	[Enums.FastNumberI32Array] = encodeBulkNumberI32Array,
	[Enums.FastNumberF32Array] = encodeBulkNumberF32Array,
	[Enums.FastBoolArray] = encodeBulkBoolArray,
	[Enums.FastStringArray] = encodeBulkStringArray,
	[Enums.FastNumberU8DictStatic] = encodeBulkNumberU8DictStatic,
	[Enums.FastNumberI32DictStatic] = encodeBulkNumberI32DictStatic,
	[Enums.FastNumberF32DictStatic] = encodeBulkNumberF32DictStatic,
	[Enums.FastBoolDictStatic] = encodeBulkBoolDictStatic,
	[Enums.FastStringDictStatic]= encodeBulkStringDictStatic,
	[Enums.FastNumberU8Dict] = encodeBulkNumberU8Dict,
	[Enums.FastNumberI32Dict] = encodeBulkNumberI32Dict,
	[Enums.FastNumberF32Dict] = encodeBulkNumberF32Dict,
	[Enums.FastBoolDict] = encodeBulkBoolDict,
	[Enums.FastStringDict] = encodeBulkStringDict,
}

decodeData = {
	[Enums.Start] = function() end,
	[Enums.NumberU8] = decodeNumberU8,
	[Enums.NumberU16] = decodeNumberU16,
	[Enums.NumberU32] = decodeNumberU32,
	[Enums.NumberI8] = decodeNumberI8,
	[Enums.NumberI16] = decodeNumberI16,
	[Enums.NumberI32] = decodeNumberI32,
	[Enums.NumberF16] = decodeNumberF16,
	[Enums.NumberF32] = decodeNumberF32,
	[Enums.NumberF64] = decodeNumberF64,

	[Enums.CFrameFX8] = decodeCFrameFX8,
	[Enums.CFrameFX16] = decodeCFrameFX16,
	[Enums.CFrameF16] = decodeCFrameF16,
	[Enums.CFrameF32FX16] = decodeCFrameF32FX16,
	[Enums.CFrameF32] = decodeCFrameF32,

	[Enums.Vector3FX8] = decodeVector3FX8,
	[Enums.Vector3FX16] = decodeVector3FX16,
	[Enums.Vector3F16] = decodeVector3F16,
	[Enums.Vector3F32] = decodeVector3F32,

	[Enums.Vector2FX8] = decodeVector2FX8,
	[Enums.Vector2FX16] = decodeVector2FX16,
	[Enums.Vector2F16] = decodeVector2F16,
	[Enums.Vector2F32] = decodeVector2F32,

	[Enums.String] = decodeString,
	[Enums.StringLong] = decodeStringLong,
	[Enums.Color3] = decodeColor,
	[Enums.Boolean] = decodeBool,
	[Enums.Nil] = decodeNil,
	[Enums.Buffer] = decodeBuffer,
	[Enums.EnumItem] = decodeEnumItem,
	[Enums.Instance] = decodeInstance,

	[Enums.Any] = decodeAny,
	[Enums.ArrayStatic] = decodeArrayStatic,
	[Enums.Array] = decodeArray,
	[Enums.ArrayDynamic] = decodeArrayDynamic,
	[Enums.DictStatic] = decodeDictStatic,
	[Enums.Dict] = decodeDict,
	[Enums.DictDynamic] = decodeDictDynamic,
	
	[Enums.FastNumberU8Array] = decodeBulkNumberU8Array,
	[Enums.FastNumberI32Array] = decodeBulkNumberI32Array,
	[Enums.FastNumberF32Array] = decodeBulkNumberF32Array,
	[Enums.FastBoolArray] = decodeBulkBoolArray,
	[Enums.FastStringArray] = decodeBulkStringArray,
	[Enums.FastNumberU8DictStatic] = decodeBulkNumberU8DictStatic,
	[Enums.FastNumberI32DictStatic] = decodeBulkNumberI32DictStatic,
	[Enums.FastNumberF32DictStatic] = decodeBulkNumberF32DictStatic,
	[Enums.FastBoolDictStatic] = decodeBulkBoolDictStatic,
	[Enums.FastStringDictStatic] = decodeBulkStringDictStatic,
	[Enums.FastNumberU8Dict] = decodeBulkNumberU8Array,
	[Enums.FastNumberI32Dict] = decodeBulkNumberI32Array,
	[Enums.FastNumberF32Dict] = decodeBulkNumberF32Array,
	[Enums.FastBoolDict] = decodeBulkBoolArray,
	[Enums.FastStringDict] = decodeBulkStringArray,
}

local Serialize = {
	encode = encodeData,
	decode = decodeData,
	enumItems = enumItems,
	enumItemsByEnum = enumItemsByEnum,
}

return Serialize
