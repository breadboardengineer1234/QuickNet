--!strict
--!native
--!optimize 2
-- Name: Types
-- Purpose: Generated Luau types for NetRay schema
-- Generated-by: NetRay-Compiler

export type TypeBranding = "Off" | "On"
export type ActiveTypeBranding = "Off"
export type Brand<T, B> = T & { __brand: B }
export type u8 = number
export type i8 = number
export type u16 = number
export type i16 = number
export type u32 = number
export type i32 = number
export type f16 = number
export type f32 = number
export type f64 = number

export type Connection = {
    Connected: boolean,
    Disconnect: (self: Connection) -> (),
}

export type EventSender1<T> = {
    Fire: (T) -> boolean,
}
export type EventReceiver1<T> = {
    On: ((T) -> ()) -> Connection,
}
export type EventDuplex1<T> = EventSender1<T> & EventReceiver1<T>

export type NetStats = {
    GetReliableDropped: () -> number,
    GetUnreliableDropped: () -> number,
    GetReliableQueueSize: () -> number,
    GetUnreliableQueueSize: () -> number,
}

export type Entity = {
    id: u8,
    x: u8,
    y: u8,
    z: u8,
    orientation: u8,
    animation: u8,
}

export type Net_Entities_reliable_Args = () -> { Entity }
export type Net_Entities_reliable_TupleHandler = ({ Entity }) -> ()
export type Net_Entities_reliable_ClientEventCallback = (data: { Entity }) -> ()
export type Net_Entities_reliable_ServerEventCallback = (player: Player, data: { Entity }) -> ()
export type Net_Entities_reliable_ClientApi = {
    Fire: ({ Entity }) -> boolean,
}
export type Net_Entities_reliable_ServerApi = {
    On: (Net_Entities_reliable_ServerEventCallback) -> Connection,
}

export type Net_Booleans_reliable_Args = () -> { boolean }
export type Net_Booleans_reliable_TupleHandler = ({ boolean }) -> ()
export type Net_Booleans_reliable_ClientEventCallback = (data: { boolean }) -> ()
export type Net_Booleans_reliable_ServerEventCallback = (player: Player, data: { boolean }) -> ()
export type Net_Booleans_reliable_ClientApi = {
    Fire: ({ boolean }) -> boolean,
}
export type Net_Booleans_reliable_ServerApi = {
    On: (Net_Booleans_reliable_ServerEventCallback) -> Connection,
}

export type Net_Strings_reliable_Args = () -> { string }
export type Net_Strings_reliable_TupleHandler = ({ string }) -> ()
export type Net_Strings_reliable_ClientEventCallback = (data: { string }) -> ()
export type Net_Strings_reliable_ServerEventCallback = (player: Player, data: { string }) -> ()
export type Net_Strings_reliable_ClientApi = {
    Fire: ({ string }) -> boolean,
}
export type Net_Strings_reliable_ServerApi = {
    On: (Net_Strings_reliable_ServerEventCallback) -> Connection,
}

export type Net_Numbers_reliable_Args = () -> { u8 }
export type Net_Numbers_reliable_TupleHandler = ({ u8 }) -> ()
export type Net_Numbers_reliable_ClientEventCallback = (data: { u8 }) -> ()
export type Net_Numbers_reliable_ServerEventCallback = (player: Player, data: { u8 }) -> ()
export type Net_Numbers_reliable_ClientApi = {
    Fire: ({ u8 }) -> boolean,
}
export type Net_Numbers_reliable_ServerApi = {
    On: (Net_Numbers_reliable_ServerEventCallback) -> Connection,
}

export type Net_Dictionary_reliable_Args = () -> { [string]: u8 }
export type Net_Dictionary_reliable_TupleHandler = ({ [string]: u8 }) -> ()
export type Net_Dictionary_reliable_ClientEventCallback = (data: { [string]: u8 }) -> ()
export type Net_Dictionary_reliable_ServerEventCallback = (player: Player, data: { [string]: u8 }) -> ()
export type Net_Dictionary_reliable_ClientApi = {
    Fire: ({ [string]: u8 }) -> boolean,
}
export type Net_Dictionary_reliable_ServerApi = {
    On: (Net_Dictionary_reliable_ServerEventCallback) -> Connection,
}

export type Net_RemoteFunction_function_RequestTuple = () -> { u8 }
export type Net_RemoteFunction_function_ResponseTuple = () -> { boolean }
export type Net_RemoteFunction_function_ClientCall = ({ u8 }) -> { boolean }
export type Net_RemoteFunction_function_ServerCall = (Player, { u8 }) -> { boolean }
export type Net_RemoteFunction_function_ClientHandler = ({ u8 }) -> { boolean }
export type Net_RemoteFunction_function_ServerHandler = (Player, { u8 }) -> { boolean }
export type Net_RemoteFunction_function_ClientFunctionCallback = (data: { u8 }) -> { boolean }
export type Net_RemoteFunction_function_ServerFunctionCallback = (player: Player, data: { u8 }) -> { boolean }
export type Net_RemoteFunction_function_ClientApi = {
    On: (Net_RemoteFunction_function_ClientFunctionCallback) -> Connection,
    Call: Net_RemoteFunction_function_ClientCall,
}
export type Net_RemoteFunction_function_ServerApi = {
    On: (Net_RemoteFunction_function_ServerFunctionCallback) -> Connection,
    Call: Net_RemoteFunction_function_ServerCall,
}

export type NetClient = {
Entities: Net_Entities_reliable_ClientApi,
Booleans: Net_Booleans_reliable_ClientApi,
Strings: Net_Strings_reliable_ClientApi,
Numbers: Net_Numbers_reliable_ClientApi,
Dictionary: Net_Dictionary_reliable_ClientApi,
RemoteFunction: Net_RemoteFunction_function_ClientApi,
StepReplication: () -> (),
Stats: NetStats,
}

export type NetServer = {
Entities: Net_Entities_reliable_ServerApi,
Booleans: Net_Booleans_reliable_ServerApi,
Strings: Net_Strings_reliable_ServerApi,
Numbers: Net_Numbers_reliable_ServerApi,
Dictionary: Net_Dictionary_reliable_ServerApi,
RemoteFunction: Net_RemoteFunction_function_ServerApi,
StepReplication: () -> (),
Stats: NetStats,
}

export type Net = NetClient | NetServer

local Types = {
    u8 = (0 :: any) :: u8,
    i8 = (0 :: any) :: i8,
    u16 = (0 :: any) :: u16,
    i16 = (0 :: any) :: i16,
    u32 = (0 :: any) :: u32,
    i32 = (0 :: any) :: i32,
    f16 = (0 :: any) :: f16,
    f32 = (0 :: any) :: f32,
    f64 = (0 :: any) :: f64,
    Connection = ({ Connected = true, Disconnect = function(_self) end } :: any) :: Connection,
    NetStats = ({ GetReliableDropped = function() return 0 end, GetUnreliableDropped = function() return 0 end, GetReliableQueueSize = function() return 0 end, GetUnreliableQueueSize = function() return 0 end } :: any) :: NetStats,
    Entity = ({} :: any) :: Entity,
    Net_Entities_reliable_ClientEventCallback = ((function(...) end) :: any) :: Net_Entities_reliable_ClientEventCallback,
    Net_Entities_reliable_ServerEventCallback = ((function(...) end) :: any) :: Net_Entities_reliable_ServerEventCallback,
    Net_Entities_reliable_ClientApi = ({} :: any) :: Net_Entities_reliable_ClientApi,
    Net_Entities_reliable_ServerApi = ({} :: any) :: Net_Entities_reliable_ServerApi,
    Net_Booleans_reliable_ClientEventCallback = ((function(...) end) :: any) :: Net_Booleans_reliable_ClientEventCallback,
    Net_Booleans_reliable_ServerEventCallback = ((function(...) end) :: any) :: Net_Booleans_reliable_ServerEventCallback,
    Net_Booleans_reliable_ClientApi = ({} :: any) :: Net_Booleans_reliable_ClientApi,
    Net_Booleans_reliable_ServerApi = ({} :: any) :: Net_Booleans_reliable_ServerApi,
    Net_Strings_reliable_ClientEventCallback = ((function(...) end) :: any) :: Net_Strings_reliable_ClientEventCallback,
    Net_Strings_reliable_ServerEventCallback = ((function(...) end) :: any) :: Net_Strings_reliable_ServerEventCallback,
    Net_Strings_reliable_ClientApi = ({} :: any) :: Net_Strings_reliable_ClientApi,
    Net_Strings_reliable_ServerApi = ({} :: any) :: Net_Strings_reliable_ServerApi,
    Net_Numbers_reliable_ClientEventCallback = ((function(...) end) :: any) :: Net_Numbers_reliable_ClientEventCallback,
    Net_Numbers_reliable_ServerEventCallback = ((function(...) end) :: any) :: Net_Numbers_reliable_ServerEventCallback,
    Net_Numbers_reliable_ClientApi = ({} :: any) :: Net_Numbers_reliable_ClientApi,
    Net_Numbers_reliable_ServerApi = ({} :: any) :: Net_Numbers_reliable_ServerApi,
    Net_Dictionary_reliable_ClientEventCallback = ((function(...) end) :: any) :: Net_Dictionary_reliable_ClientEventCallback,
    Net_Dictionary_reliable_ServerEventCallback = ((function(...) end) :: any) :: Net_Dictionary_reliable_ServerEventCallback,
    Net_Dictionary_reliable_ClientApi = ({} :: any) :: Net_Dictionary_reliable_ClientApi,
    Net_Dictionary_reliable_ServerApi = ({} :: any) :: Net_Dictionary_reliable_ServerApi,
    Net_RemoteFunction_function_ClientFunctionCallback = ((function(...) end) :: any) :: Net_RemoteFunction_function_ClientFunctionCallback,
    Net_RemoteFunction_function_ServerFunctionCallback = ((function(...) end) :: any) :: Net_RemoteFunction_function_ServerFunctionCallback,
    Net_RemoteFunction_function_ClientApi = ({} :: any) :: Net_RemoteFunction_function_ClientApi,
    Net_RemoteFunction_function_ServerApi = ({} :: any) :: Net_RemoteFunction_function_ServerApi,
    NetClient = ({} :: any) :: NetClient,
    NetServer = ({} :: any) :: NetServer,
    Net = ({} :: any) :: Net,
}

return table.freeze(Types)

