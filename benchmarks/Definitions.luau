local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.QuickNet)
local Packet = require(ReplicatedStorage.Packet)
local ByteNet = require(ReplicatedStorage.ByteNet)
local Jolt = require(ReplicatedStorage.Jolt)
local isServer = RunService:IsServer()
local blinkFolder = ReplicatedStorage.Blink
local Blink = isServer and require(blinkFolder.Server) or require(blinkFolder.Client)
local env = isServer and "Server" or "Client"
local remote = ReplicatedStorage:WaitForChild("BenchmarkRemote")
local data = Net.Data

local module = {
	bool1 = Net:register("BoolTest", {Net.Data.Boolean}):SetRateLimit(1000000000, 30),
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

	entities1 = Net:register("EntitiesTest",
		{
			{
				id = Net.Data.NumberU8,
				x = Net.Data.NumberU8,
				y = Net.Data.NumberU8,
				z = Net.Data.NumberU8,
				orientation = Net.Data.NumberU8,
				animation = Net.Data.NumberU8,
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

	strings1 = Net:register("StringsTest", {Net.Data.String}):SetRateLimit(1000000000, 30),
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

	numbers1 = Net:register("NumbersTest", {Net.Data.NumberU8}):SetRateLimit(1000000000, 30),
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

	dict1 = Net:register("DictTest", {[Net.Data.String] = Net.Data.NumberU8}):SetRateLimit(1000000000, 30),
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
	
	remoteFunction1 = Net:register("RemoteFunctionTest", {Net.Data.NumberU8}):Response({Net.Data.Boolean})
		:SetRateLimit(1000000000000, 30),	
	remoteFunction2 = Blink.RemoteFunction,
}

return module
