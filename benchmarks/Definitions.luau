local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local QuickNet = require(ReplicatedStorage.QuickNet)
local Packet = require(ReplicatedStorage.Packet)
local ByteNet = require(ReplicatedStorage.ByteNet)
local Jolt = require(ReplicatedStorage.Jolt)
local isServer = RunService:IsServer()
local blinkFolder = ReplicatedStorage.Blink
local Blink = isServer and require(blinkFolder.Server) or require(blinkFolder.Client)
local Warp = isServer and require(ReplicatedStorage.Warp).Server() or require(ReplicatedStorage.Warp).Client()
local NetRay = isServer and require(ReplicatedStorage.NetRay.Server) or require(ReplicatedStorage.NetRay.Client)
if not isServer then
	Warp.awaitReady()
end
local VNet = require(ReplicatedStorage.VNet)
local env = isServer and "Server" or "Client"
local remote = ReplicatedStorage:WaitForChild("BenchmarkRemote")
local data = QuickNet.Data

local module = {
	bool1 = QuickNet:register("BoolTest", {data.Boolean}):SetRateLimit(1000000000, 30),
	bool2 = Packet("BoolTest", {Packet.Boolean8}),
	bool3 = remote,
	bool4 = ByteNet.defineNamespace("BoolTest", function()
		return {
			BoolTest = ByteNet.definePacket({
				value = ByteNet.array(ByteNet.bool),
			})
		}
	end),
	bool5 = Jolt[env]("BoolTest"),
	bool6 = Blink.Booleans,
	bool7 = Warp.Schema.array(Warp.Schema.boolean),
	bool8 = VNet.packet("Booleans", VNet.t.array("bool"), {rate = "100000000000/s", burst = 100000000000}),
	bool9 = NetRay.Booleans,

	entities1 = QuickNet:register("EntitiesTest",
		{
			{
				id = data.NumberU8,
				x = data.NumberU8,
				y = data.NumberU8,
				z = data.NumberU8,
				orientation = data.NumberU8,
				animation = data.NumberU8,
			}
		}):SetRateLimit(1000000000, 30),
	
	entities2 = Packet("EntitiesTest", {
		{
			id = Packet.NumberU8, 
			x = Packet.NumberU8, 
			y = Packet.NumberU8,
			z = Packet.NumberU8,
			orientation = Packet.NumberU8,
			animation = Packet.NumberU8,
		}
	}),	
	entities3 = remote,
	
	entities4 = ByteNet.defineNamespace("EntitiesTest", function()
		return {
			EntitiesTest = ByteNet.definePacket({
				value = ByteNet.array(ByteNet.struct(
					{
						id = ByteNet.uint8, 
						x = ByteNet.uint8, 
						y = ByteNet.uint8,
						z = ByteNet.uint8,
						orientation = ByteNet.uint8,
						animation = ByteNet.uint8,
					}
					)),
			})
		}
	end),
	entities5 = Jolt[env]("EntitiesTest"),
	entities6 = Blink.Entities,
	entities7 = Warp.Schema.array(Warp.Schema.struct({
		id = Warp.Schema.u8,
		x = Warp.Schema.u8, 
		y = Warp.Schema.u8,
		z = Warp.Schema.u8,
		orientation = Warp.Schema.u8,
		animation = Warp.Schema.u8,
	})),
	entities8 = VNet.packet("Entities", VNet.t.array(VNet.t.struct({
		id = "u8",
		x = "u8", 
		y = "u8",
		z = "u8",
		orientation = "u8",
		animation = "u8",
	})), {rate = "100000000000/s", burst = 100000000000}),
	entities9 = NetRay.Entities,
	
	strings1 = QuickNet:register("StringsTest", {data.String}):SetRateLimit(1000000000, 30),
	strings2 = Packet("StringsTest", {Packet.String}),
	strings3 = remote,
	strings4 = ByteNet.defineNamespace("StringsTest", function()
		return {
			StringsTest = ByteNet.definePacket({
				value = ByteNet.array(ByteNet.string),
			})
		}
	end),
	strings5 = Jolt[env]("StringsTest"),
	strings6 = Blink.Strings,
	strings7 = Warp.Schema.array(Warp.Schema.string),
	strings8 = VNet.packet("Strings", VNet.t.array("string"), {rate = "100000000000/s", burst = 100000000000}),
	strings9 = NetRay.Strings,
	
	numbers1 = QuickNet:register("NumbersTest", {data.NumberU8}):SetRateLimit(1000000000, 30),
	numbers2 = Packet("NumbersTest", {Packet.NumberU8}),
	numbers3 = remote,
	numbers4 = ByteNet.defineNamespace("NumbersTest", function()
		return {
			NumbersTest = ByteNet.definePacket({
				value = ByteNet.array(ByteNet.uint8),
			})
		}
	end),
	numbers5 = Jolt[env]("NumbersTest"),
	numbers6 = Blink.Numbers,
	numbers7 = Warp.Schema.array(Warp.Schema.u8),
	numbers8 = VNet.packet("Numbers", VNet.t.array("u8"), {rate = "100000000000/s", burst = 100000000000}),
	numbers9 = NetRay.Numbers,

	dict1 = QuickNet:register("DictTest", {[data.String] = data.NumberU8}):SetRateLimit(1000000000, 30),
	dict2 = Packet("DictTest", Packet.Any),
	dict3 = remote,
	dict4 = ByteNet.defineNamespace("DictTest", function()
		return {
			DictTest = ByteNet.definePacket({
				value = ByteNet.map(ByteNet.string, ByteNet.uint8),
			})
		}
	end),
	dict5 = Jolt[env]("DictTest"),
	dict6 = Blink.Dictionary,
	dict7 = Warp.Schema.map(Warp.Schema.string, Warp.Schema.u8),
	dict8 = VNet.packet("Dict", VNet.t.map("string", "u8"), {rate = "100000000000/s", burst = 100000000000}),
	dict9 = NetRay.Dictionary,
	
	remoteFunction1 = QuickNet:register("RemoteFunctionTest", {data.NumberU8}):Response({data.Boolean})
		:SetRateLimit(1000000000000, 30),
	
	remoteFunction2 = Blink.RemoteFunction,
	remoteFunction3 = NetRay.RemoteFunction,
	
	changingNumbers1 = QuickNet:register("ChangingNumbers", {data.NumberU8}):SetRateLimit(1000000000000, 30),
	changingNumbers2 = Warp.Schema.array(Warp.Schema.u8),
}

Warp.useSchema("Booleans", module.bool7)
Warp.useSchema("Entities", module.entities7)
Warp.useSchema("Strings", module.strings7)
Warp.useSchema("Numbers", module.numbers7)
Warp.useSchema("Dict", module.dict7)
Warp.useSchema("ChangingNumbers", module.changingNumbers2)

return module
