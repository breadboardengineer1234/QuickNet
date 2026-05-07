local Enums = require(script.Parent.Enums)

local SOURCE = "[QuickNet]"

local function getReverseEnums(): {[number]: string}
	local new = {}
	for k, v in Enums do
		new[v] = k
	end
	return new
end

local reverseEnums = getReverseEnums()

local fastPaths = {
	Array = {
		[Enums.NumberU8] = Enums.FastNumberU8Array,
		[Enums.NumberI32] = Enums.FastNumberI32Array,
		[Enums.NumberF32] = Enums.FastNumberF32Array,
		[Enums.Boolean] = Enums.FastBoolArray,
		[Enums.String] = Enums.FastStringArray,
	},

	DictStatic = {
		[Enums.NumberU8] = Enums.FastNumberU8DictStatic,
		[Enums.NumberI32] = Enums.FastNumberI32DictStatic,
		[Enums.NumberF32] = Enums.FastNumberF32DictStatic,
		[Enums.Boolean] = Enums.FastBoolDictStatic,
		[Enums.String] = Enums.FastStringDictStatic,
	},

	Dict = {
		[Enums.NumberU8] = Enums.FastNumberU8Dict,
		[Enums.NumberI32] = Enums.FastNumberI32Dict,
		[Enums.NumberF32] = Enums.FastNumberF32Dict,
		[Enums.Boolean] = Enums.FastBoolDict,
		[Enums.String] = Enums.FastStringDict,
	}
}

local function checkSameTypes(data: {any}): (boolean, number)
	local sameValTypes = true
	local prevVal = data[1]

	for _, val in data do
		if val ~= prevVal then
			sameValTypes = false
			break
		end
		prevVal = val
	end
	return sameValTypes, prevVal
end

--Indexes
--1: Type
--2: Data
--3: FastPath
local function arrayStatic(data: {any}): {any}
	local sameTypes, dataType = checkSameTypes(data)

	local schema = {
		Enums.ArrayStatic, 
		data,
		sameTypes and fastPaths.Array[dataType] or nil
	}
	return schema
end

local function array<T>(data: {T}): {T}
	local dataType = data[1]
	local schema = {
		Enums.Array, 
		dataType,
		fastPaths.Array[dataType],
	}
	return schema
end

local function arrayDynamic(): {any}
	local schema = {
		Enums.ArrayDynamic,
	}
	return schema
end

local dictId = 1

local function getDictId(): number
	local id = dictId
	dictId += 1
	return id
end

--1: Type
--2: Data
--3: KeysMap
--4: FastPath
local function dictStatic(data: {[string | number]: any}): {[string | number]: any}
	local keys = {}
	for key, val in data do
		table.insert(keys, key)
	end
	table.sort(keys, function(a, b)
		local aType = type(a)
		local bType = type(b)

		if aType ~= bType then
			return aType < bType
		end
		return a < b
	end)

	local vals = {}
	local template = {}
	for idx, key in keys do		
		vals[idx] = data[key]
		template[key] = 123
	end	
	local sameTypes, dataType = checkSameTypes(vals)

	local schema = {
		Enums.DictStatic,
		vals,
		keys,
		template,
		sameTypes and fastPaths.DictStatic[dataType] or nil,
	}
	return schema
end

--1: Type
--2: KeyData
--3: ValueData
--4: KeyFastPath
--5: ValueFastPath
local function dict<K, V>(data: {[K]: V}): {[K]: V}
	local keyData, valData = next(data)
	local keyFastPath = fastPaths.Dict[keyData]
	local valFastPath = fastPaths.Dict[valData]

	local schema = {
		[1] = Enums.Dict,
		[2] = keyData,
		[3] = valData,
		[4] = keyFastPath,
		[5] = valFastPath,
		[6] = getDictId(),
	}
	return schema
end

local function dictDynamic(): {[any]: any}
	local schema = {
		Enums.DictDynamic,
	}
	return schema
end

local function processSchema(schema: {[any]: any})
	if type(schema) ~= "table" then
		if not reverseEnums[schema] then
			error(SOURCE.." invalid data type")
		end
		return schema
	end

	local newSchema
	local isArrayStatic = true
	local count = 0
	for i, arg in schema do
		count += 1
		if i ~= count then
			isArrayStatic = false
		end
	end

	local k, v = next(schema)
	local isArray = count == 1 and k == 1
	local isDict = not isArray and count == 1
	local isDictStatic = not isArrayStatic and count > 1

	if isArray then
		newSchema = array(schema)
		local data = newSchema[2]
		if data == Enums.Any then
			newSchema = arrayDynamic()
		else
			newSchema[2] = processSchema(data)
		end

	elseif isArrayStatic then
		newSchema = arrayStatic(schema)
		local data = newSchema[2]
		local newData = {}
		for i, val in data do
			newData[i] = processSchema(val)
		end
		newSchema[2] = newData

	elseif isDict then
		newSchema = dict(schema)
		local key = newSchema[2]
		local val = newSchema[3]
		if key == Enums.Any and val == Enums.Any then
			newSchema = dictDynamic()
		else
			newSchema[2] = processSchema(key)
			newSchema[3] = processSchema(val)
		end

	elseif isDictStatic then
		newSchema = dictStatic(schema)
		local vals = newSchema[2]
		for i, val in vals do
			vals[i] = processSchema(val)
		end

	else
		error(SOURCE.. " invalid schema")
	end
	return newSchema
end

local function getSchema(...)
	local args = {...}
	for i, arg in args do
		args[i] = processSchema(arg)
	end
	return args
end

local Parser = {
	getSchema = getSchema,
}

return Parser
