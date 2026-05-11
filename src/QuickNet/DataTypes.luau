local Enums = require(script.Parent.Enums)

local dataTypes = {	
	NumberU8 = Enums.NumberU8,	
	NumberU16 = Enums.NumberU16,
	NumberU32 = Enums.NumberU32,
	NumberI8 = Enums.NumberI8,
	NumberI16 = Enums.NumberI16,
	NumberI32 = Enums.NumberI32,
	NumberF16 = Enums.NumberF16,
	NumberF32 = Enums.NumberF32,
	NumberF64 = Enums.NumberF64,
	
	--cframes
	CFrameFX8 = Enums.CFrameFX8 :: CFrame,
	CFrameFX16 = Enums.CFrameFX16 :: CFrame,
	CFrameF16 = Enums.CFrameF16 :: CFrame,
	CFrameF32Aligned = Enums.CFrameF32Aligned :: CFrame,
	CFrameF32FX16 = Enums.CFrameF32FX16 :: CFrame,
	CFrameF32 = Enums.CFrameF32 :: CFrame,
	
	--vector3
	Vector3FX8 = Enums.Vector3FX8 :: Vector3,
	Vector3FX16 = Enums.Vector3FX16 :: Vector3,
	Vector3F16 = Enums.Vector3F16 :: Vector3,
	Vector3F32 = Enums.Vector3F32 :: Vector3,
	
	--vector2
	Vector2FX8 = Enums.Vector2FX8 :: Vector2,
	Vector2FX16 = Enums.Vector2FX16 :: Vector2,
	Vector2F16 = Enums.Vector2F16 :: Vector2,
	Vector2F32 = Enums.Vector2F32 :: Vector2,
	
	--misc
	String = Enums.String :: string,
	StringLong = Enums.StringLong :: string,
	Color3 = Enums.Color3 :: Color3,
	BrickColor = Enums.BrickColor :: BrickColor,
	Boolean = Enums.Boolean :: boolean,
	Nil = Enums.Nil :: any,
	Buffer = Enums.Buffer :: buffer,
	EnumItem = Enums.EnumItem :: EnumItem,
	Instance = Enums.Instance :: Instance,
	DateTime32 = Enums.DateTime32 :: DateTime,
	DateTime64 = Enums.DateTime64 :: DateTime,
	TweenInfo = Enums.TweenInfo :: TweenInfo,
	
	--custom
	Any = Enums.Any :: any,
}

return dataTypes
