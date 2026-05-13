local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = Instance.new("RemoteEvent")
remote.Name = "BenchmarkRemote"
remote.Parent = ReplicatedStorage

local Defs = require(script.Parent.Definitions)

Defs.bool1.OnServerEvent:Connect(function(player, data)
	--print(data)
end)


Defs.bool2.OnServerEvent:Connect(function(player, data)

end)

Defs.bool3.OnServerEvent:Connect(function(player, data)

end)

Defs.bool4.BoolTest.listen(function(data, player)

end)

Defs.bool5:Connect(function(player, data)
	
end)

Defs.bool6.On(function(player, data)
	
end)

Defs.entities1.OnServerEvent:Connect(function(player, data)

end)

Defs.entities2.OnServerEvent:Connect(function(player, data)

end)

Defs.entities3.OnServerEvent:Connect(function(player, data)

end)

Defs.entities4.EntitiesTest.listen(function(data, player)

end)

Defs.entities5:Connect(function(player, data)
	
end)

Defs.entities6.On(function(player, data)
	
end)

Defs.strings1.OnServerEvent:Connect(function(player, data)

end)

Defs.strings2.OnServerEvent:Connect(function(player, data)

end)

Defs.strings3.OnServerEvent:Connect(function(player, data)

end)

Defs.strings4.StringsTest.listen(function(data, player)

end)

Defs.strings5:Connect(function(player, data)
	
end)

Defs.strings6.On(function(player, data)
	
end)

Defs.numbers1.OnServerEvent:Connect(function(player, data)
	--print(data)
end)

Defs.numbers2.OnServerEvent:Connect(function(player, data)

end)

Defs.numbers3.OnServerEvent:Connect(function(player, data)

end)

Defs.numbers4.NumbersTest.listen(function(data, player)

end)

Defs.numbers5:Connect(function(player, data)
	
end)

Defs.numbers6.On(function(player, data)
	
end)

Defs.dict1.OnServerEvent:Connect(function(player, data)

end)

Defs.dict2.OnServerEvent:Connect(function(player, data)

end)

Defs.dict3.OnServerEvent:Connect(function(player, data)

end)

Defs.dict4.DictTest.listen(function(data, player)

end)

Defs.dict5:Connect(function(player, data)
	
end)

Defs.dict6.On(function(player, data)
	
end)

local bools = table.create(500, true)
Defs.remoteFunction1.OnServerInvoke = function(player, data)
	return bools
end

Defs.remoteFunction2.On(function(player, data)
	return bools
end)

return {}
