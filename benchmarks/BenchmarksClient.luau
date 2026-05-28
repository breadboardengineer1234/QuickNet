local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Defs = require(script.Parent.Definitions)
local Warp = require(ReplicatedStorage.Warp).Client()

local methods = {
	QuickNet = "FireServer",
	Packet = "Fire",
	RemoteEvent = "FireServer",
	ByteNet = "send",
	Jolt = "Fire",
	Blink = "Fire",
	VNet = "send",
	NetRay = "Fire",
}

local functionMethods = {
	QuickNet = "InvokeServer",
	Blink = "Invoke",
	NetRay = "Call",
}

local events = {
	QuickNet = {
		Booleans = Defs.bool1,
		Entities = Defs.entities1,
		Strings = Defs.strings1, 
		Numbers = Defs.numbers1,
		Dict = Defs.dict1,
		Instance = Defs.testInst,
		ChangingNumbers = Defs.changingNumbers1,
	},

	Packet = {
		Booleans = Defs.bool2,
		Entities = Defs.entities2,
		Strings = Defs.strings2,
		Numbers = Defs.numbers2,
		Dict = Defs.dict2,
	},

	RemoteEvent = {
		Booleans = Defs.bool3,
		Entities = Defs.entities3,
		Strings = Defs.strings3,
		Numbers = Defs.numbers3,
		Dict = Defs.dict3,
		
		Instance = Defs.bool3,
	},

	ByteNet = {
		Booleans = Defs.bool4.BoolTest,
		Entities = Defs.entities4.EntitiesTest,
		Strings = Defs.strings4.StringsTest,
		Numbers = Defs.numbers4.NumbersTest,
		Dict = Defs.dict4.DictTest,
	},
	
	Jolt = {
		Booleans = Defs.bool5,
		Entities = Defs.entities5,
		Strings = Defs.strings5,
		Numbers = Defs.numbers5,
		Dict = Defs.dict5,
	},
	
	Blink = {
		Booleans = Defs.bool6,
		Entities = Defs.entities6,
		Strings = Defs.strings6,
		Numbers = Defs.numbers6,
		Dict = Defs.dict6,
	},
	
	Warp = {
		Booleans = {},
		Entities = {},
		Strings = {},
		Numbers = {},
		Dict = {},
		ChangingNumbers = {},
	},
	
	VNet = {
		Booleans = Defs.bool8,
		Entities = Defs.entities8,
		Strings = Defs.strings8,
		Numbers = Defs.numbers8,
		Dict = Defs.dict8,
	},
	
	NetRay = {
		Booleans = Defs.bool9,
		Entities = Defs.entities9,
		Strings = Defs.strings9,
		Numbers = Defs.numbers9,
		Dict = Defs.dict9,
	}
}

local functions = {
	QuickNet = {
		RemoteFunction = Defs.remoteFunction1,
	},
	
	Blink = {
		RemoteFunction = Defs.remoteFunction2,
	},
	
	NetRay = {
		RemoteFunction = Defs.remoteFunction3,
	}
}


local function getEntitiesData()
	local array = {}
	for i = 1, 100 do
		table.insert(array, {
			id = math.random(1, 255),
			x = math.random(1, 255),
			y = math.random(1, 255),
			z = math.random(1, 255),
			orientation = math.random(1, 255),
			animation = math.random(1, 255),
		})
	end
	return array
end

local function getNumbersData(amount: number)
	local nums = {}
	for i = 1, amount do
		nums[i] = math.random(0, 255)
	end
	return nums
end

local function getDictData()
	local dict = {}
	for i = 1, 500 do
		local key = "Key"..i
		dict[key] = math.random(0, 255)
	end
	return dict
end

local testData = {
	Booleans = table.create(1000, true),
	Entities = getEntitiesData(),
	Strings = table.create(500, "Hello"),
	Numbers = getNumbersData(2000),
	Dict = getDictData(),
}

--dont use deltaTime it doesnt show below 15 fps
local function startTest(networkName: string, testName: string, firesPerFrame: number, duration: number?)
	duration = duration or 10	
	local methodName = methods[networkName]
	local event = events[networkName][testName]
	local fire = event[methodName]
	local data = testData[testName]	
	local isByteNet = networkName == "ByteNet"
	local isBlink = networkName == "Blink"
	local isWarp = networkName == "Warp"
	local isVNet = networkName == "VNet"
	local isNetRay = networkName == "NetRay"
	local dotCall = isByteNet or isBlink or isVNet or isNetRay

	task.wait(3)
	local numFrames = 0
	local timePassed = 0
	local timestamp
	local kbps = 0

	local conn
	conn = RunService.PostSimulation:Connect(function()
		--data = getNumbersData(2000)
		if dotCall then
			for i = 1, firesPerFrame do
				fire(data)
			end
		elseif isWarp then
			for i = 1, firesPerFrame do
				Warp.Fire(testName, true, data)
			end
		else
			for i = 1, firesPerFrame do
				fire(event, data)
			end
		end

		local now = os.clock()
		if timestamp then
			numFrames += 1
			timePassed += now - timestamp
			kbps += Stats.DataSendKbps
		end
		timestamp = now

		if timePassed >= duration then
			local avgFps = numFrames/timePassed
			--scale kbps by 60/fps, more fps will send packets more often
			local avgKbps = (60 / avgFps) * kbps / numFrames
			print(string.format("\n[%s] [%s] \nAverage FPS: %.3f \nAverage Kbps %.3f", 
				networkName, testName, avgFps, avgKbps))
			conn:Disconnect()
		end
	end)
end

local function startFunction(networkName: string, testName: string, firesPerFrame: number, duration: number?)
	duration = duration or 300	
	local methodName = functionMethods[networkName]
	local func = functions[networkName][testName]
	local invoke = func[methodName]
	local data = getNumbersData(500)
	local isByteNet = networkName == "ByteNet"
	local isBlink = networkName == "Blink"
	local isNetRay = networkName == "NetRay"
	local dotCall = isByteNet or isBlink or isNetRay

	task.wait(3)
	local numFrames = 0
	local timePassed = 0
	local timestamp
	local kbps = 0

	local conn
	conn = RunService.PostSimulation:Connect(function()
		if dotCall then
			for i = 1, firesPerFrame do
				task.spawn(invoke, data)
			end
		else
			for i = 1, firesPerFrame do
				task.spawn(invoke, func, data)
			end
		end

		local now = os.clock()
		if timestamp then
			numFrames += 1
			timePassed += now - timestamp
			kbps += Stats.DataSendKbps
		end
		timestamp = now

		if timePassed >= duration then
			local avgFps = numFrames/timePassed
			--scale kbps by 60/fps, more fps will send packets more often
			local avgKbps = (60 / avgFps) * kbps / numFrames
			print(string.format("\n[%s] [%s] \nAverage FPS: %.3f \nAverage Kbps %.3f", 
				networkName, testName, avgFps, avgKbps))
			conn:Disconnect()
		end
	end)
end

return {
	start = startTest,
	startFunction = startFunction,
}




