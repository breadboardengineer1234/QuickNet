# Events

## ``.OnServerEvent``
This signal is fired when data sent by a client arrives on the server.

### ``:Connect``
Attaches a listener to the signal. When using this method QuickNet will run the listener synchronously, meaning any yields will block other calls from the same client. Only use this method if the listener does not yield. This method accepts a callback as input where the first argument is the player that initiated the fire, and the following arguments are the event arguments. This method returns a ``QuickNetConnection`` object.

```lua
local conn = myEvent.OnServerEvent:Connect(function(player, num, str, bool)
  print(num)
  print(str)
  print(bool)
end)
```

### ``:ConnectAsync``
This method does the same thing as ``:Connect`` but runs the listener asynchronously. Use this method for listeners that yield. Note that async connections have higher overhead. Calling this method returns a ``QuickNetConnection`` object.
```lua
local conn = myEvent.OnServerEvent:ConnectAsync(function(player, num, str, bool)
  print(num)
  print(str)
  print(bool)
end)
```

### ``:Wait``
Yields the caller's thread until the next ``.OnServerEvent`` signal.
```lua
myEvent.OnServerEvent:Wait()
print("Fired")
```
