local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Defs = require(script.Parent.Definitions)

local methods = {
	QuickNet = "FireServer",
	Packet = "Fire",
	RemoteEvent = "FireServer",
	ByteNet = "send",
}

local events = {
	QuickNet = {
		Booleans = Defs.bool1,
		Entities = Defs.entities1,
		Strings = Defs.strings1, 
		Numbers = Defs.numbers1,
		Dict = Defs.dict1,
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
	},

	ByteNet = {
		Booleans = Defs.bool4.BoolTest,
		Entities = Defs.entities4.EntitiesTest,
		Strings = Defs.strings4.StringsTest,
		Numbers = Defs.numbers4.NumbersTest,
		Dict = Defs.dict4.DictTest,
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

local function getNumbersData()
	local nums = {}
	for i = 1, 2000 do
		table.insert(nums, math.random(1, 255))
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
	Numbers = getNumbersData(),
	Dict = getDictData(),
}

local function startTest(networkName: string, testName: string, firesPerFrame: number, duration: number?)
	duration = duration or 10	
	local methodName = methods[networkName]
	local event = events[networkName][testName]
	local fire = event[methodName]
	local data = testData[testName]
	local isByteNet = networkName == "ByteNet"

	task.wait(3)
	local numFrames = 0
	local timePassed = 0
	local timestamp
	local kbps = 0

	local conn
	conn = RunService.PostSimulation:Connect(function()
		if isByteNet then
			for i = 1, firesPerFrame do
				fire(data)
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
--dont use deltaTime it doesnt show below 15 fps

return {start = startTest}
