# General
The following methods must be called on both client and server.

## ``:register``
Registers a network event. This method takes in a name and the types of the arguments and returns a ``NetworkEvent`` object. Providing a name that has already been registered will throw an error.
```lua
local myEvent = QuickNet:register("MyEvent", data.NumberF32, data.String, data.Boolean)
```

## ``NetworkEvent``
### ``:Response``
When registering a network event, this method can be chained to create a network function. It accepts the types of the arguments as input and returns a ``NetworkFunction`` object.
```lua
local myFunction = QuickNet:register("MyFunction", {[data.String] = data.NumberI32}):Response(data.Boolean, data.String)
```

