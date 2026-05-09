---
layout: docs
title: General
---

# General
The following methods must be called on both client and server.

## ``:register(name: string, ...: A...): NetworkEvent``
Registers a network event. This method takes in a name and the types of the event arguments and returns a ``NetworkEvent`` object. The max number of events is 255. Attempting to register more than this amount will throw an error. Providing a name that has already been registered will also throw an error.
```lua
local myEvent = QuickNet:register("MyEvent", data.NumberF32, data.String, data.Boolean)
```

## ``:setEnumItems(enums: {EnumItem})``
Attaches a table of EnumItems to enable the use of the ``data.EnumItem`` type. The provided table must be a flat array containing all EnumItems that will be used.
```lua
local enums = {
  Enum.EasingDirection.Out,
  Enum.EasingStyle.Bounce,
  Enum.Material.Ice,
  Enum.HumanoidStateType.Running,
}

QuickNet:setEnumItems(enums)
```

## ``:setMaxPayloadSize(size: number)``
Sets the maximum byte size of any payload. Payloads exceeding this limit will immediately be dropped. This method accepts a size in bytes as input. The provided size must be an integer greater than 0.
```lua
QuickNet:setMaxPayloadSize(20000)
```

## ``NetworkEvent``
### ``:Response(...: B...): NetworkFunction``
When registering a network event, this method can be chained to create a network function. It accepts the types of the response values as input and returns a ``NetworkFunction`` object.
```lua
local myFunction = QuickNet:register("MyFunction", {[data.String] = data.NumberI32}):Response(data.Boolean, data.String)
```

### ``:SetRateLimit(max: number, timeWindow: number): NetworkEvent``
Sets the rate limit for the network event. The first argument is the maximum number of calls, the second argument is the time window in seconds. For example, if the max calls is 20 and the time window is 1, the event can be fired (by the same client) at most 20 times within a 1 second period. Additional fires will be dropped until the timer resets. Calling this method returns the ``NetworkEvent`` itself.
```lua
myEvent:SetRateLimit(20, 1)
```

## ``NetworkFunction``
### ``:SetResponseTimeout(timeout: number): NetworkFunction``
Sets the amount of time before a function invoke times out. This method accepts a time in seconds and returns the calling ``NetworkFunction``. The timeout amount must be in the range [0, 60].
```lua
myFunction:SetResponseTimeout(10)
```

### ``:SetRateLimit(max: number, timeWindow: number): NetworkFunction``
Sets the rate limit for the network function. The first argument is the maximum number of calls, the second argument is the time window in seconds. For example, if the max calls is 20 and the time window is 1, the event can be fired (by the same client) at most 20 times within a 1 second period. Additional fires will be dropped until the timer resets. Calling this method returns the ``NetworkEvent`` itself.
```lua
myFunction:SetRateLimit(20, 1)
```

