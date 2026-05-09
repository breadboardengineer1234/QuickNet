---
layout: docs
title: Quickstart
---

# Quickstart

## 1. Setup
Place QuickNet inside ReplicatedStorage (either directly or a in sub container), then simply require it.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quicknet = require(ReplicatedStorage.your.path.QuickNet)
```

## 2. Register a network event
First capture the ```Data``` field of QuickNet to have easy access to QuickNet's data types. Then simply use the ```:register``` method to register events.

```lua
local data = QuickNet.Data
local event1 = QuickNet:register("SomeEventName", data.NumberU8, data.String)
```
The same exact event must be registered on both the client and the server. To avoid repeating code, use a shared ModuleScript and register events once, then require the module on both client and server.

## 3. Firing an event (Client-Server)
On the client:
```lua
event1:FireServer(123, "whatever")
```
On the server:
```lua
event1.OnServerEvent:Connect(function(player, num, str)
  print(num)
  print(str)
end)
```

## 4. Firing an event (Server-Client)
On the server:
```lua
event1:FireAllClients(123, "whatever")
```
On the client:
```lua
event1.OnClientEvent:Connect(function(num, str)
  print(num)
  print(str)
end)
```
