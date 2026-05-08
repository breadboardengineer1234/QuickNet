## ``QuickNetConnection``
QuickNetConnection objects can be used to clean up network connections. They are compatible with the Janitor module.

### ``.Connected``
A read-only boolean property that indicates if the connection is currently connected.
```lua
local isConnected = conn.Connected
print(isConnected)
```

### ``:Disconnect``
Disconnects a listener.
```lua
conn:Disconnect()
```

### ``:Destroy``
Does the same thing as ``:Disconnect``.

