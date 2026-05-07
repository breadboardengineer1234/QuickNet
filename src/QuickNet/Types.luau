
export type Signal<T...> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> QuickNetConnection,
	ConnectAsync: (self: Signal<T...>, callback: (T...) -> ()) -> QuickNetConnection,
	Wait: (self: Signal<T...>) -> (),
}

export type NetworkFunction<A..., B...> = {
	--server
	OnServerInvoke: (player: Player, A...) -> B...,
	OnServerInvokeAsync: (player: Player, A...) -> B...,	
	--shared
	SetRateLimit: (self: NetworkFunction<A..., B...>, max: number, timeWindow: number) -> NetworkFunction<A..., B...>,
	SetResponseTimeout: (self: NetworkFunction<A..., B...>, timeout: number) -> NetworkFunction<A..., B...>,
	--client
	InvokeServer: (self: NetworkFunction<A..., B...>, A...) -> B...,
}

export type NetworkEvent<A...> = {
	--server
	Response: <B...>(self: NetworkEvent<A...>, B...) -> NetworkFunction<A..., B...>,
	OnServerEvent: Signal<(Player, A...)>,
	FireClient: (self: NetworkEvent<A...>, player: Player, A...) -> (),
	FireClients: (self: NetworkEvent<A...>, players: {Player}, A...) -> (),
	FireAllClients: (self: NetworkEvent<A...>, A...) -> (),
	FireAllExcept: (self: NetworkEvent<A...>, excludePlayer: Player, A...) -> (),	
	--shared
	SetRateLimit: (self: NetworkEvent<A...>, max: number, timeWindow: number) -> NetworkEvent<A...>,
	--client
	OnClientEvent: Signal<A...>,
	FireServer: (self: NetworkEvent<A...>, A...) -> (),
}

export type QuickNetConnection = {
	Connected: boolean,
	Disconnect: (self: QuickNetConnection) -> (),
	Destroy: (self: QuickNetConnection) -> (),
}

export type NetworkInfo<A..., B...> = {
	Name: string,
	Id: number,
	NetworkType: number,
	RateLimit: {Time: number, Max: number},
	SendSchema: {any},
	ResponseSchema: {any}?,
	Callbacks: {[QuickNetConnection]: (...any) -> (...any)},
	AsyncCallbacks: {[QuickNetConnection]: (...any) -> (...any)},
	WaitThreads: {thread},
	Object: NetworkEvent<A...> | NetworkFunction<A..., B...>,
	ResponseTimeout: number,
}

export type SchemaArg = {any} | number

export type Queue = {
	QueueSize: number,
	ByteSize: number,
	TempBuffer: buffer,
	Instances: {Instance},
}

local module = {}


return module
