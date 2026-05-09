# Functions

## ``.OnServerInvoke``
### ``callback(Player, A...) -> B...``
Fires when a network function is invoked by a client. This signal must be set to a callback that accepts the player and arguments and returns a set of values. The callback is run synchronously and can block other calls from the same client if it yields.

```lua
myFunction.OnServerInvoke = function(player, data)
  print(data)
  return true, "whatever"
end
```

## ``.OnServerInvokeAsync``
### ``callback(Player, A...) -> B...``
Does the same thing as ``.OnServerInvoke`` except it runs the attached callback asynchronously, allowing it to yield safely.

```lua
myFunction.OnServerInvokeAsync = function(player, data)
  print(data)
  return true, "whatever"
end
```

## ``:InvokeServer(A...) -> B...``
Invokes the server with the given arguments, yields the current thread until the server responds with the return values, then returns these values back to the caller.
```lua
local data = {Key1 = 2, Key2 = 4, Key3 = 8, Key4 = 16}
local success, msg = myFunction:InvokeServer(data)
print(success)
print(msg)
```
