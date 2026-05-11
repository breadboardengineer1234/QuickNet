---
layout: docs
title: Events
---

# Events

## ``.OnServerEvent``
This signal fires when data sent by a client arrives on the server.

### ``:Connect(callback: (Player, A...) -> ()): QuickNetConnection``
Attaches a listener to the signal. When using this method QuickNet will run the listener synchronously, meaning any yields will block other calls from the same client. Only use this method if the listener does not yield. This method accepts a callback as input where the first argument is the player that initiated the fire, and the following arguments are the event arguments. This method returns a ``QuickNetConnection`` object.
```lua
local conn = myEvent.OnServerEvent:Connect(function(player, num, str, bool)
  print(num)
  print(str)
  print(bool)
end)
```
### ``:ConnectAsync(callback: (Player, A...) -> ()): QuickNetConnection``
Does the same thing as ``:Connect`` but runs the listener asynchronously. Use this method for listeners that yield. Note that async connections have higher overhead. Calling this method returns a ``QuickNetConnection`` object.
```lua
local conn = myEvent.OnServerEvent:ConnectAsync(function(player, num, str, bool)
  print(num)
  print(str)
  task.wait(5)
  print(bool)
end)
```

### ``:Once(callback: (Player, A...) -> ()): QuickNetConnection``
Connects a listener to the event one time. The connection object is cleaned up immediately before the callback runs. This method runs the listener asynchronously.
```lua
local conn = myEvent.OnServerEvent:Once(function(player, num, str, bool)
  print(num)
  print(str)
  task.wait(2)
  print(bool)
end)
```

### ``:Wait(): A...``
Yields the caller's thread until the next ``.OnServerEvent`` signal, at which point it returns the signal's arguments.
```lua
myEvent.OnServerEvent:Wait()
print("Fired")
```

## ``:FireClient(player: Player, ...: A...)``
Fires data to a specificed client. Accepts a player instance and a set of arguments.
```lua
myEvent:FireClient(somePlayer, 123, "blah", true)
```

## ``:FireClients(players: {Player}, ...: A...)``
Fires data to a list of specified clients. Accepts a table of player instances and a set of arguments.
```lua
local players = {player1, player2, player3, player4}
myEvent:FireClients(players, 123, "blah", true)
```

## ``:FireAllClients(...: A...)``
Fires data to all clients in the game. Accepts a set of arguments.
```lua
myEvent:FireAllClients(123, "blah", true)
```

## ``:FireAllExcept(excludePlayer: Player, ...: A...)``
Fires data to every client except for the specified client. Accepts a player instance and a set of arguments.
```lua
myEvent:FireAllExcept(blacklistedPlayer, 123, "blah", true)
```

## ``.OnClientEvent``
This signal fires when data sent by the server arrives on the client.

### ``:Connect(callback: (A...) -> ()): QuickNetConnection``
Attaches a listener to the signal. When using this method QuickNet will run the listener synchronously, meaning any yields will block other calls from the server. Only use this method if the listener does not yield. This method accepts a callback as input where the arguments are the event arguments and returns a ``QuickNetConnection`` object.
```lua
local conn = myEvent.OnClientEvent:Connect(function(num, str, bool)
  print(num)
  print(str)
  print(bool)
end)
```

### ``:ConnectAsync(callback: (A...) -> ()): QuickNetConnection``
Does the same thing as ``:Connect`` but runs the listener asynchronously. Use this method for listeners that yield. Note that async connections have higher overhead. Calling this method returns a ``QuickNetConnection`` object.
```lua
local conn = myEvent.OnClientEvent:ConnectAsync(function(num, str, bool)
  print(num)
  print(str)
  task.wait(5)
  print(bool)
end)
```

### ``:Once(callback: (Player, A...) -> ()): QuickNetConnection``
Connects a listener to the event one time. The connection object is cleaned up immediately before the callback runs. This method runs the listener asynchronously.
```lua
local conn = myEvent.OnClientEvent:Once(function(player, num, str, bool)
  print(num)
  print(str)
  task.wait(2)
  print(bool)
end)
```

### ``:Wait(): A...``
Yields the caller's thread until the next ``.OnClientEvent`` signal, at which point it returns the signal's arguments.
```lua
myEvent.OnClientEvent:Wait()
print("Fired")
```

## ``:FireServer(...: A...)``
Fires the server with the given arguments.
```lua
myEvent:FireServer(123, "blah", true)
```

