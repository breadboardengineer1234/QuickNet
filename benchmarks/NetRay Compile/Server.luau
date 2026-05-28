--!strict
--!native
--!optimize 2
--!nolint LocalShadow
--#selene: allow(shadowing)
-- Name: Server
-- Purpose: Generated runtime for server networking
-- Generated-by: NetRay-Compiler
-- Version: 0.1.1

local Types = require(script.Parent.Types)
type u8 = typeof(Types.u8)
type i8 = typeof(Types.i8)
type u16 = typeof(Types.u16)
type i16 = typeof(Types.i16)
type u32 = typeof(Types.u32)
type i32 = typeof(Types.i32)
type f16 = typeof(Types.f16)
type f32 = typeof(Types.f32)
type f64 = typeof(Types.f64)
type NetRoot = typeof(Types.NetServer)
type NetStats = typeof(Types.NetStats)
type Connection = typeof(Types.Connection)
type Entity = typeof(Types.Entity)
type Net_Entities_reliable_ServerApi = typeof(Types.Net_Entities_reliable_ServerApi)
type Net_Entities_reliable_ServerEventCallback = typeof(Types.Net_Entities_reliable_ServerEventCallback)
type Net_Booleans_reliable_ServerApi = typeof(Types.Net_Booleans_reliable_ServerApi)
type Net_Booleans_reliable_ServerEventCallback = typeof(Types.Net_Booleans_reliable_ServerEventCallback)
type Net_Strings_reliable_ServerApi = typeof(Types.Net_Strings_reliable_ServerApi)
type Net_Strings_reliable_ServerEventCallback = typeof(Types.Net_Strings_reliable_ServerEventCallback)
type Net_Numbers_reliable_ServerApi = typeof(Types.Net_Numbers_reliable_ServerApi)
type Net_Numbers_reliable_ServerEventCallback = typeof(Types.Net_Numbers_reliable_ServerEventCallback)
type Net_Dictionary_reliable_ServerApi = typeof(Types.Net_Dictionary_reliable_ServerApi)
type Net_Dictionary_reliable_ServerEventCallback = typeof(Types.Net_Dictionary_reliable_ServerEventCallback)
type Net_RemoteFunction_function_ServerApi = typeof(Types.Net_RemoteFunction_function_ServerApi)
type Net_RemoteFunction_function_ServerFunctionCallback = typeof(Types.Net_RemoteFunction_function_ServerFunctionCallback)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local function FindOrCreateRemote(className, remoteName)
    local existing = ReplicatedStorage:FindFirstChild(remoteName)
    if existing ~= nil then
        if existing.ClassName ~= className then
            error(("Remote '%s' exists as '%s', expected '%s'"):format(remoteName, existing.ClassName, className))
        end
        return existing
    end
    local remote = Instance.new(className)
    remote.Name = remoteName
    remote.Parent = ReplicatedStorage
    return remote
end

local Reliable = FindOrCreateRemote("RemoteEvent", "NetRay_RELIABLE") :: RemoteEvent
local Unreliable = FindOrCreateRemote("UnreliableRemoteEvent", "NetRay_UNRELIABLE") :: UnreliableRemoteEvent
local FunctionRemote = FindOrCreateRemote("RemoteFunction", "NetRay_FUNCTION") :: RemoteFunction

local function WithCount(...)
    return select("#", ...), ...
end

local DEFAULT_ARENA_CAPACITY = 65536
local create = buffer.create
local copy = buffer.copy
local len = buffer.len
local writeu8 = buffer.writeu8
local writeu16 = buffer.writeu16

local readu8 = buffer.readu8
local readu16 = buffer.readu16

local readstring = buffer.readstring
local band = bit32.band
local bor = bit32.bor
local rshift = bit32.rshift
local lshift = bit32.lshift

local ERR_BOUNDS = "E_BOUNDS"
local ERR_SCHEMA = "E_SCHEMA"
local ERR_TAG = "E_TAG"
local ERR_TYPE = "E_TYPE"
local SEGMENT_MARKER_ID = 0

local function VarUIntSize(value)
    if value < 128 then return 1 end
    if value < 16384 then return 2 end
    if value < 2097152 then return 3 end
    if value < 268435456 then return 4 end
    return 5
end

local function WriteVarUInt(payload, offset, value)
    if value < 128 then
        writeu8(payload, offset, value)
        return offset + 1
    end
    if value < 16384 then
        writeu8(payload, offset, bor(band(value, 127), 128))
        writeu8(payload, offset + 1, band(rshift(value, 7), 127))
        return offset + 2
    end
    if value < 2097152 then
        writeu8(payload, offset, bor(band(value, 127), 128))
        writeu8(payload, offset + 1, bor(band(rshift(value, 7), 127), 128))
        writeu8(payload, offset + 2, band(rshift(value, 14), 127))
        return offset + 3
    end
    if value < 268435456 then
        writeu8(payload, offset, bor(band(value, 127), 128))
        writeu8(payload, offset + 1, bor(band(rshift(value, 7), 127), 128))
        writeu8(payload, offset + 2, bor(band(rshift(value, 14), 127), 128))
        writeu8(payload, offset + 3, band(rshift(value, 21), 127))
        return offset + 4
    end
    writeu8(payload, offset, bor(band(value, 127), 128))
    writeu8(payload, offset + 1, bor(band(rshift(value, 7), 127), 128))
    writeu8(payload, offset + 2, bor(band(rshift(value, 14), 127), 128))
    writeu8(payload, offset + 3, bor(band(rshift(value, 21), 127), 128))
    writeu8(payload, offset + 4, band(rshift(value, 28), 15))
    return offset + 5
end

local function ReadVarUInt(payload, payloadLength, offset)
    local next1 = offset + 1
    if next1 > payloadLength then error(ERR_BOUNDS) end
    local b1 = readu8(payload, offset)
    if b1 < 128 then return b1, next1 end
    local next2 = next1 + 1
    if next2 > payloadLength then error(ERR_BOUNDS) end
    local b2 = readu8(payload, next1)
    local value = band(b1, 127) + lshift(band(b2, 127), 7)
    if b2 < 128 then return value, next2 end
    local next3 = next2 + 1
    if next3 > payloadLength then error(ERR_BOUNDS) end
    local b3 = readu8(payload, next2)
    value += lshift(band(b3, 127), 14)
    if b3 < 128 then return value, next3 end
    local next4 = next3 + 1
    if next4 > payloadLength then error(ERR_BOUNDS) end
    local b4 = readu8(payload, next3)
    value += lshift(band(b4, 127), 21)
    if b4 < 128 then return value, next4 end
    local next5 = next4 + 1
    if next5 > payloadLength then error(ERR_BOUNDS) end
    local b5 = readu8(payload, next4)
    if b5 >= 16 then error(ERR_SCHEMA) end
    value += lshift(b5, 28)
    return value, next5
end

local function CreateConnection(disconnectFn: () -> ()): Connection
    local active = true
    local connection = {} :: any
    connection.Connected = true
    function connection:Disconnect()
        if not active then
            return
        end
        active = false
        connection.Connected = false
        disconnectFn()
    end
    return connection :: Connection
end

local MAX_RELIABLE_ID = 5
local MAX_UNRELIABLE_ID = 0
local MAX_FUNCTION_ID = 1
local RELIABLE_DISPATCH = table.create(MAX_RELIABLE_ID)
local UNRELIABLE_DISPATCH = table.create(MAX_UNRELIABLE_ID)
local RELIABLE_SKIP = table.create(MAX_RELIABLE_ID)
local UNRELIABLE_SKIP = table.create(MAX_UNRELIABLE_ID)
local FUNCTION_DISPATCH = table.create(MAX_FUNCTION_ID)

local RELIABLE_ARENA_CAPACITY = DEFAULT_ARENA_CAPACITY
local RELIABLE_ARENA = create(RELIABLE_ARENA_CAPACITY)
local RELIABLE_CURSOR = 0
local RELIABLE_QUEUE_SIZE = 0
local RELIABLE_DROPPED = 0
local RELIABLE_SEGMENT_HEADER_BYTES = 2
local RELIABLE_SEGMENT_MIN_COUNT = 4
local RELIABLE_SEGMENT_MIN_TAIL_BYTES = 3

local function FlushReliable()
    if RELIABLE_CURSOR == 0 then
        RELIABLE_QUEUE_SIZE = 0
        return
    end
    local payloadToSend = create(RELIABLE_CURSOR)
    local payloadOffset = RELIABLE_CURSOR
    if RELIABLE_QUEUE_SIZE >= RELIABLE_SEGMENT_MIN_COUNT then
        -- Only scan runs when the batch is large enough to amortize segment headers.
        local sourceOffset = 0
        payloadOffset = 0
        while sourceOffset < RELIABLE_CURSOR do
            local runStart = sourceOffset
            local messageId = readu8(RELIABLE_ARENA, sourceOffset)
            sourceOffset += 1
            local skip = RELIABLE_SKIP[messageId]
            local firstBodyEnd = skip(RELIABLE_ARENA, RELIABLE_CURSOR, sourceOffset)
            local runEnd = firstBodyEnd
            local runCount = 1
            if RELIABLE_CURSOR - firstBodyEnd < RELIABLE_SEGMENT_MIN_TAIL_BYTES then
                -- Remaining bytes cannot fit enough repeated IDs to make segmentation pay off.
                local tailSize = RELIABLE_CURSOR - runStart
                if tailSize > 0 then
                    copy(payloadToSend, payloadOffset, RELIABLE_ARENA, runStart, tailSize)
                    payloadOffset += tailSize
                end
                break
            end
            while runEnd < RELIABLE_CURSOR do
                local nextMessageId = readu8(RELIABLE_ARENA, runEnd)
                if nextMessageId ~= messageId then
                    break
                end
                local nextBodyStart = runEnd + 1
                runEnd = skip(RELIABLE_ARENA, RELIABLE_CURSOR, nextBodyStart)
                runCount += 1
            end
            if runCount * 1 > RELIABLE_SEGMENT_HEADER_BYTES + VarUIntSize(runCount) then
                writeu8(payloadToSend, payloadOffset, SEGMENT_MARKER_ID)
                payloadOffset += 1
                writeu8(payloadToSend, payloadOffset, messageId)
                payloadOffset += 1
                payloadOffset = WriteVarUInt(payloadToSend, payloadOffset, runCount)
                local copyCursor = sourceOffset
                local bodyEnd = firstBodyEnd
                while true do
                    local bodySize = bodyEnd - copyCursor
                    if bodySize > 0 then
                        copy(payloadToSend, payloadOffset, RELIABLE_ARENA, copyCursor, bodySize)
                        payloadOffset += bodySize
                    end
                    if bodyEnd >= runEnd then
                        break
                    end
                    copyCursor = bodyEnd + 1
                    bodyEnd = skip(RELIABLE_ARENA, RELIABLE_CURSOR, copyCursor)
                end
            else
                local runSize = runEnd - runStart
                if runSize > 0 then
                    copy(payloadToSend, payloadOffset, RELIABLE_ARENA, runStart, runSize)
                    payloadOffset += runSize
                end
            end
            sourceOffset = runEnd
        end
    else
        -- For tiny batches, a direct copy is cheaper than any merge scan.
        copy(payloadToSend, 0, RELIABLE_ARENA, 0, RELIABLE_CURSOR)
    end
    if payloadOffset < RELIABLE_CURSOR then
        local compactPayload = create(payloadOffset)
        copy(compactPayload, 0, payloadToSend, 0, payloadOffset)
        payloadToSend = compactPayload
    end
    Reliable:FireAllClients(payloadToSend)
    RELIABLE_CURSOR = 0
    RELIABLE_QUEUE_SIZE = 0
end

local UNRELIABLE_ARENA_CAPACITY = DEFAULT_ARENA_CAPACITY
local UNRELIABLE_ARENA = create(UNRELIABLE_ARENA_CAPACITY)
local UNRELIABLE_CURSOR = 0
local UNRELIABLE_QUEUE_SIZE = 0
local UNRELIABLE_DROPPED = 0
local UNRELIABLE_SEGMENT_HEADER_BYTES = 2
local UNRELIABLE_SEGMENT_MIN_COUNT = 4
local UNRELIABLE_SEGMENT_MIN_TAIL_BYTES = 3

local function FlushUnreliable()
    if UNRELIABLE_CURSOR == 0 then
        UNRELIABLE_QUEUE_SIZE = 0
        return
    end
    local payloadToSend = create(UNRELIABLE_CURSOR)
    local payloadOffset = UNRELIABLE_CURSOR
    if UNRELIABLE_QUEUE_SIZE >= UNRELIABLE_SEGMENT_MIN_COUNT then
        -- Only scan runs when the batch is large enough to amortize segment headers.
        local sourceOffset = 0
        payloadOffset = 0
        while sourceOffset < UNRELIABLE_CURSOR do
            local runStart = sourceOffset
            local messageId = readu8(UNRELIABLE_ARENA, sourceOffset)
            sourceOffset += 1
            local skip = UNRELIABLE_SKIP[messageId]
            local firstBodyEnd = skip(UNRELIABLE_ARENA, UNRELIABLE_CURSOR, sourceOffset)
            local runEnd = firstBodyEnd
            local runCount = 1
            if UNRELIABLE_CURSOR - firstBodyEnd < UNRELIABLE_SEGMENT_MIN_TAIL_BYTES then
                -- Remaining bytes cannot fit enough repeated IDs to make segmentation pay off.
                local tailSize = UNRELIABLE_CURSOR - runStart
                if tailSize > 0 then
                    copy(payloadToSend, payloadOffset, UNRELIABLE_ARENA, runStart, tailSize)
                    payloadOffset += tailSize
                end
                break
            end
            while runEnd < UNRELIABLE_CURSOR do
                local nextMessageId = readu8(UNRELIABLE_ARENA, runEnd)
                if nextMessageId ~= messageId then
                    break
                end
                local nextBodyStart = runEnd + 1
                runEnd = skip(UNRELIABLE_ARENA, UNRELIABLE_CURSOR, nextBodyStart)
                runCount += 1
            end
            if runCount * 1 > UNRELIABLE_SEGMENT_HEADER_BYTES + VarUIntSize(runCount) then
                writeu8(payloadToSend, payloadOffset, SEGMENT_MARKER_ID)
                payloadOffset += 1
                writeu8(payloadToSend, payloadOffset, messageId)
                payloadOffset += 1
                payloadOffset = WriteVarUInt(payloadToSend, payloadOffset, runCount)
                local copyCursor = sourceOffset
                local bodyEnd = firstBodyEnd
                while true do
                    local bodySize = bodyEnd - copyCursor
                    if bodySize > 0 then
                        copy(payloadToSend, payloadOffset, UNRELIABLE_ARENA, copyCursor, bodySize)
                        payloadOffset += bodySize
                    end
                    if bodyEnd >= runEnd then
                        break
                    end
                    copyCursor = bodyEnd + 1
                    bodyEnd = skip(UNRELIABLE_ARENA, UNRELIABLE_CURSOR, copyCursor)
                end
            else
                local runSize = runEnd - runStart
                if runSize > 0 then
                    copy(payloadToSend, payloadOffset, UNRELIABLE_ARENA, runStart, runSize)
                    payloadOffset += runSize
                end
            end
            sourceOffset = runEnd
        end
    else
        -- For tiny batches, a direct copy is cheaper than any merge scan.
        copy(payloadToSend, 0, UNRELIABLE_ARENA, 0, UNRELIABLE_CURSOR)
    end
    if payloadOffset < UNRELIABLE_CURSOR then
        local compactPayload = create(payloadOffset)
        copy(compactPayload, 0, payloadToSend, 0, payloadOffset)
        payloadToSend = compactPayload
    end
    Unreliable:FireAllClients(payloadToSend)
    UNRELIABLE_CURSOR = 0
    UNRELIABLE_QUEUE_SIZE = 0
end

local Net_Entities_reliable_1: Net_Entities_reliable_ServerApi = {} :: Net_Entities_reliable_ServerApi
local MESSAGE_ID_Net_Entities_reliable_1 = 1

local function Decode_Net_Entities_reliable_1(payload, payloadLength, offset)
    local decoded_data
    local prefixCursor_1 = offset
    local prefixNext_3 = prefixCursor_1 + 2
    if prefixNext_3 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayCount_2 = readu16(payload, prefixCursor_1)
    prefixCursor_1 = prefixNext_3
    local fixedCursor_4 = prefixCursor_1
    local varCursor_5 = fixedCursor_4
    if varCursor_5 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayValues_7 = table.create(arrayCount_2)
    for arrayIndex_6 = 1, arrayCount_2 do
        local arrayValue_8
        local structValue_9 = {}
        local structField_10
        local fieldNext_11 = varCursor_5 + 1
        if fieldNext_11 > payloadLength then
            error(ERR_BOUNDS)
        end
        structField_10 = (readu8(payload, varCursor_5) :: u8)
        varCursor_5 = fieldNext_11
        structValue_9["id"] = structField_10
        local structField_12
        local fieldNext_13 = varCursor_5 + 1
        if fieldNext_13 > payloadLength then
            error(ERR_BOUNDS)
        end
        structField_12 = (readu8(payload, varCursor_5) :: u8)
        varCursor_5 = fieldNext_13
        structValue_9["x"] = structField_12
        local structField_14
        local fieldNext_15 = varCursor_5 + 1
        if fieldNext_15 > payloadLength then
            error(ERR_BOUNDS)
        end
        structField_14 = (readu8(payload, varCursor_5) :: u8)
        varCursor_5 = fieldNext_15
        structValue_9["y"] = structField_14
        local structField_16
        local fieldNext_17 = varCursor_5 + 1
        if fieldNext_17 > payloadLength then
            error(ERR_BOUNDS)
        end
        structField_16 = (readu8(payload, varCursor_5) :: u8)
        varCursor_5 = fieldNext_17
        structValue_9["z"] = structField_16
        local structField_18
        local fieldNext_19 = varCursor_5 + 1
        if fieldNext_19 > payloadLength then
            error(ERR_BOUNDS)
        end
        structField_18 = (readu8(payload, varCursor_5) :: u8)
        varCursor_5 = fieldNext_19
        structValue_9["orientation"] = structField_18
        local structField_20
        local fieldNext_21 = varCursor_5 + 1
        if fieldNext_21 > payloadLength then
            error(ERR_BOUNDS)
        end
        structField_20 = (readu8(payload, varCursor_5) :: u8)
        varCursor_5 = fieldNext_21
        structValue_9["animation"] = structField_20
        arrayValue_8 = structValue_9
        arrayValues_7[arrayIndex_6] = arrayValue_8
    end
    decoded_data = arrayValues_7
    offset = varCursor_5
    return decoded_data, offset
end

local Handler_Net_Entities_reliable_1: ((player: Player, data: { Entity }) -> ())? = nil
local HandlerToken_Net_Entities_reliable_1 = 0

function Net_Entities_reliable_1.On(callback: Net_Entities_reliable_ServerEventCallback): Connection
    if type(callback) ~= "function" then error(ERR_TYPE) end
    HandlerToken_Net_Entities_reliable_1 += 1
    local token = HandlerToken_Net_Entities_reliable_1
    Handler_Net_Entities_reliable_1 = callback
    return CreateConnection(function()
        if HandlerToken_Net_Entities_reliable_1 == token then
            HandlerToken_Net_Entities_reliable_1 += 1
            Handler_Net_Entities_reliable_1 = nil
        end
    end)
end

RELIABLE_DISPATCH[1] = function(player, payload, payloadLength, offset)
    local decoded_data, nextOffset = Decode_Net_Entities_reliable_1(payload, payloadLength, offset)
    local callback = Handler_Net_Entities_reliable_1
    if callback == nil then
        return nextOffset
    end
    callback(player, decoded_data)
    return nextOffset
end

local Net_Booleans_reliable_2: Net_Booleans_reliable_ServerApi = {} :: Net_Booleans_reliable_ServerApi
local MESSAGE_ID_Net_Booleans_reliable_2 = 2

local function Decode_Net_Booleans_reliable_2(payload, payloadLength, offset)
    local decoded_data
    local prefixCursor_1 = offset
    local prefixNext_3 = prefixCursor_1 + 2
    if prefixNext_3 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayCount_2 = readu16(payload, prefixCursor_1)
    prefixCursor_1 = prefixNext_3
    local fixedCursor_4 = prefixCursor_1
    local varCursor_5 = fixedCursor_4
    if varCursor_5 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayValues_7 = table.create(arrayCount_2)
    local arrayPackedByteCount_9 = ((arrayCount_2 + 7) // 8)
    local arrayPackedCursor_10 = varCursor_5
    local arrayPackedNext_11 = arrayPackedCursor_10 + arrayPackedByteCount_9
    if arrayPackedNext_11 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayUnpackIndex_13 = 1
    for arrayPackedIndex_12 = 1, arrayPackedByteCount_9 do
        local arrayPackedByte_14 = readu8(payload, arrayPackedCursor_10)
        arrayPackedCursor_10 += 1
        local arrayBitMask_16 = 1
        for arrayBitIndex_15 = 1, 8 do
            if arrayUnpackIndex_13 > arrayCount_2 then
                break
            end
            arrayValues_7[arrayUnpackIndex_13] = band(arrayPackedByte_14, arrayBitMask_16) ~= 0
            arrayUnpackIndex_13 += 1
            arrayBitMask_16 = lshift(arrayBitMask_16, 1)
        end
    end
    varCursor_5 = arrayPackedCursor_10
    decoded_data = arrayValues_7
    offset = varCursor_5
    return decoded_data, offset
end

local Handler_Net_Booleans_reliable_2: ((player: Player, data: { boolean }) -> ())? = nil
local HandlerToken_Net_Booleans_reliable_2 = 0

function Net_Booleans_reliable_2.On(callback: Net_Booleans_reliable_ServerEventCallback): Connection
    if type(callback) ~= "function" then error(ERR_TYPE) end
    HandlerToken_Net_Booleans_reliable_2 += 1
    local token = HandlerToken_Net_Booleans_reliable_2
    Handler_Net_Booleans_reliable_2 = callback
    return CreateConnection(function()
        if HandlerToken_Net_Booleans_reliable_2 == token then
            HandlerToken_Net_Booleans_reliable_2 += 1
            Handler_Net_Booleans_reliable_2 = nil
        end
    end)
end

RELIABLE_DISPATCH[2] = function(player, payload, payloadLength, offset)
    local decoded_data, nextOffset = Decode_Net_Booleans_reliable_2(payload, payloadLength, offset)
    local callback = Handler_Net_Booleans_reliable_2
    if callback == nil then
        return nextOffset
    end
    callback(player, decoded_data)
    return nextOffset
end

local Net_Strings_reliable_3: Net_Strings_reliable_ServerApi = {} :: Net_Strings_reliable_ServerApi
local MESSAGE_ID_Net_Strings_reliable_3 = 3

local function Decode_Net_Strings_reliable_3(payload, payloadLength, offset)
    local decoded_data
    local prefixCursor_1 = offset
    local prefixNext_3 = prefixCursor_1 + 2
    if prefixNext_3 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayCount_2 = readu16(payload, prefixCursor_1)
    prefixCursor_1 = prefixNext_3
    local fixedCursor_4 = prefixCursor_1
    local varCursor_5 = fixedCursor_4
    if varCursor_5 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayValues_7 = table.create(arrayCount_2)
    for arrayIndex_6 = 1, arrayCount_2 do
        local arrayValue_8
        local stringLen_9
        stringLen_9, varCursor_5 = ReadVarUInt(payload, payloadLength, varCursor_5)
        if stringLen_9 > 4294967295 then
            error(ERR_SCHEMA)
        end
        local stringNext_10 = varCursor_5 + stringLen_9
        if stringNext_10 > payloadLength then
            error(ERR_BOUNDS)
        end
        arrayValue_8 = readstring(payload, varCursor_5, stringLen_9)
        varCursor_5 = stringNext_10
        arrayValues_7[arrayIndex_6] = arrayValue_8
    end
    decoded_data = arrayValues_7
    offset = varCursor_5
    return decoded_data, offset
end

local Handler_Net_Strings_reliable_3: ((player: Player, data: { string }) -> ())? = nil
local HandlerToken_Net_Strings_reliable_3 = 0

function Net_Strings_reliable_3.On(callback: Net_Strings_reliable_ServerEventCallback): Connection
    if type(callback) ~= "function" then error(ERR_TYPE) end
    HandlerToken_Net_Strings_reliable_3 += 1
    local token = HandlerToken_Net_Strings_reliable_3
    Handler_Net_Strings_reliable_3 = callback
    return CreateConnection(function()
        if HandlerToken_Net_Strings_reliable_3 == token then
            HandlerToken_Net_Strings_reliable_3 += 1
            Handler_Net_Strings_reliable_3 = nil
        end
    end)
end

RELIABLE_DISPATCH[3] = function(player, payload, payloadLength, offset)
    local decoded_data, nextOffset = Decode_Net_Strings_reliable_3(payload, payloadLength, offset)
    local callback = Handler_Net_Strings_reliable_3
    if callback == nil then
        return nextOffset
    end
    callback(player, decoded_data)
    return nextOffset
end

local Net_Numbers_reliable_4: Net_Numbers_reliable_ServerApi = {} :: Net_Numbers_reliable_ServerApi
local MESSAGE_ID_Net_Numbers_reliable_4 = 4

local function Decode_Net_Numbers_reliable_4(payload, payloadLength, offset)
    local decoded_data
    local prefixCursor_1 = offset
    local prefixNext_3 = prefixCursor_1 + 2
    if prefixNext_3 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayCount_2 = readu16(payload, prefixCursor_1)
    prefixCursor_1 = prefixNext_3
    local fixedCursor_4 = prefixCursor_1
    local varCursor_5 = fixedCursor_4
    if varCursor_5 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayValues_7 = table.create(arrayCount_2)
    for arrayIndex_6 = 1, arrayCount_2 do
        local arrayValue_8
        local fieldNext_9 = varCursor_5 + 1
        if fieldNext_9 > payloadLength then
            error(ERR_BOUNDS)
        end
        arrayValue_8 = (readu8(payload, varCursor_5) :: u8)
        varCursor_5 = fieldNext_9
        arrayValues_7[arrayIndex_6] = arrayValue_8
    end
    decoded_data = arrayValues_7
    offset = varCursor_5
    return decoded_data, offset
end

local Handler_Net_Numbers_reliable_4: ((player: Player, data: { u8 }) -> ())? = nil
local HandlerToken_Net_Numbers_reliable_4 = 0

function Net_Numbers_reliable_4.On(callback: Net_Numbers_reliable_ServerEventCallback): Connection
    if type(callback) ~= "function" then error(ERR_TYPE) end
    HandlerToken_Net_Numbers_reliable_4 += 1
    local token = HandlerToken_Net_Numbers_reliable_4
    Handler_Net_Numbers_reliable_4 = callback
    return CreateConnection(function()
        if HandlerToken_Net_Numbers_reliable_4 == token then
            HandlerToken_Net_Numbers_reliable_4 += 1
            Handler_Net_Numbers_reliable_4 = nil
        end
    end)
end

RELIABLE_DISPATCH[4] = function(player, payload, payloadLength, offset)
    local decoded_data, nextOffset = Decode_Net_Numbers_reliable_4(payload, payloadLength, offset)
    local callback = Handler_Net_Numbers_reliable_4
    if callback == nil then
        return nextOffset
    end
    callback(player, decoded_data)
    return nextOffset
end

local Net_Dictionary_reliable_5: Net_Dictionary_reliable_ServerApi = {} :: Net_Dictionary_reliable_ServerApi
local MESSAGE_ID_Net_Dictionary_reliable_5 = 5

local function Decode_Net_Dictionary_reliable_5(payload, payloadLength, offset)
    local decoded_data
    local prefixCursor_1 = offset
    local mapCount_2
    mapCount_2, prefixCursor_1 = ReadVarUInt(payload, payloadLength, prefixCursor_1)
    local fixedCursor_3 = prefixCursor_1
    local varCursor_4 = fixedCursor_3
    if varCursor_4 > payloadLength then
        error(ERR_BOUNDS)
    end
    local mapValues_6 = {}
    for mapIndex_5 = 1, mapCount_2 do
        local mapKey_7
        local stringLen_9
        stringLen_9, varCursor_4 = ReadVarUInt(payload, payloadLength, varCursor_4)
        if stringLen_9 > 4294967295 then
            error(ERR_SCHEMA)
        end
        local stringNext_10 = varCursor_4 + stringLen_9
        if stringNext_10 > payloadLength then
            error(ERR_BOUNDS)
        end
        mapKey_7 = readstring(payload, varCursor_4, stringLen_9)
        varCursor_4 = stringNext_10
        local mapValue_8
        local fieldNext_11 = varCursor_4 + 1
        if fieldNext_11 > payloadLength then
            error(ERR_BOUNDS)
        end
        mapValue_8 = (readu8(payload, varCursor_4) :: u8)
        varCursor_4 = fieldNext_11
        mapValues_6[mapKey_7] = mapValue_8
    end
    decoded_data = mapValues_6
    offset = varCursor_4
    return decoded_data, offset
end

local Handler_Net_Dictionary_reliable_5: ((player: Player, data: { [string]: u8 }) -> ())? = nil
local HandlerToken_Net_Dictionary_reliable_5 = 0

function Net_Dictionary_reliable_5.On(callback: Net_Dictionary_reliable_ServerEventCallback): Connection
    if type(callback) ~= "function" then error(ERR_TYPE) end
    HandlerToken_Net_Dictionary_reliable_5 += 1
    local token = HandlerToken_Net_Dictionary_reliable_5
    Handler_Net_Dictionary_reliable_5 = callback
    return CreateConnection(function()
        if HandlerToken_Net_Dictionary_reliable_5 == token then
            HandlerToken_Net_Dictionary_reliable_5 += 1
            Handler_Net_Dictionary_reliable_5 = nil
        end
    end)
end

RELIABLE_DISPATCH[5] = function(player, payload, payloadLength, offset)
    local decoded_data, nextOffset = Decode_Net_Dictionary_reliable_5(payload, payloadLength, offset)
    local callback = Handler_Net_Dictionary_reliable_5
    if callback == nil then
        return nextOffset
    end
    callback(player, decoded_data)
    return nextOffset
end

local Net_RemoteFunction_function_1: Net_RemoteFunction_function_ServerApi = {} :: Net_RemoteFunction_function_ServerApi
local MESSAGE_ID_Net_RemoteFunction_function_1 = 1

local function Encode_Net_RemoteFunction_function_1(data)
    local prefixSize = 0
    local varSize = 0
    local arrayLen_1 = #data
    prefixSize += 2
    for arrayIndex_2 = 1, arrayLen_1 do
        varSize += 1
    end
    local totalSize = 1 + prefixSize + varSize
    local payload = create(totalSize)
    writeu8(payload, 0, MESSAGE_ID_Net_RemoteFunction_function_1)
    local prefixOffset = 1
    local fixedOffset = prefixOffset + prefixSize
    local varOffset = fixedOffset
    writeu16(payload, prefixOffset, arrayLen_1)
    prefixOffset += 2
    for arrayIndex_4 = 1, arrayLen_1 do
        writeu8(payload, varOffset, data[arrayIndex_4])
        varOffset += 1
    end
    return payload
end

local function Decode_Net_RemoteFunction_function_1(payload, payloadLength, offset)
    local decoded_data
    local prefixCursor_1 = offset
    local prefixNext_3 = prefixCursor_1 + 2
    if prefixNext_3 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayCount_2 = readu16(payload, prefixCursor_1)
    prefixCursor_1 = prefixNext_3
    local fixedCursor_4 = prefixCursor_1
    local varCursor_5 = fixedCursor_4
    if varCursor_5 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayValues_7 = table.create(arrayCount_2)
    for arrayIndex_6 = 1, arrayCount_2 do
        local arrayValue_8
        local fieldNext_9 = varCursor_5 + 1
        if fieldNext_9 > payloadLength then
            error(ERR_BOUNDS)
        end
        arrayValue_8 = (readu8(payload, varCursor_5) :: u8)
        varCursor_5 = fieldNext_9
        arrayValues_7[arrayIndex_6] = arrayValue_8
    end
    decoded_data = arrayValues_7
    offset = varCursor_5
    return decoded_data, offset
end

local function EncodeReturn_Net_RemoteFunction_function_1(result)
    local prefixSize = 0
    local varSize = 0
    local arrayLen_1 = #result
    prefixSize += 2
    varSize += ((arrayLen_1 + 7) // 8)
    local totalSize = 1 + prefixSize + varSize
    local payload = create(totalSize)
    writeu8(payload, 0, MESSAGE_ID_Net_RemoteFunction_function_1)
    local prefixOffset = 1
    local fixedOffset = prefixOffset + prefixSize
    local varOffset = fixedOffset
    writeu16(payload, prefixOffset, arrayLen_1)
    prefixOffset += 2
    local arrayPackedByteCount_5 = ((arrayLen_1 + 7) // 8)
    local arrayValueIndex_7 = 1
    for arrayPackedIndex_6 = 1, arrayPackedByteCount_5 do
        local arrayPackedByte_10 = 0
        local arrayBitMask_9 = 1
        for arrayBitIndex_8 = 1, 8 do
            if arrayValueIndex_7 > arrayLen_1 then
                break
            end
            if result[arrayValueIndex_7] then
                arrayPackedByte_10 = bor(arrayPackedByte_10, arrayBitMask_9)
            end
            arrayValueIndex_7 += 1
            arrayBitMask_9 = lshift(arrayBitMask_9, 1)
        end
        writeu8(payload, varOffset, arrayPackedByte_10)
        varOffset += 1
    end
    return payload
end

local function DecodeReturn_Net_RemoteFunction_function_1(payload, payloadLength, offset)
    local decoded_result
    local prefixCursor_1 = offset
    local prefixNext_3 = prefixCursor_1 + 2
    if prefixNext_3 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayCount_2 = readu16(payload, prefixCursor_1)
    prefixCursor_1 = prefixNext_3
    local fixedCursor_4 = prefixCursor_1
    local varCursor_5 = fixedCursor_4
    if varCursor_5 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayValues_7 = table.create(arrayCount_2)
    local arrayPackedByteCount_9 = ((arrayCount_2 + 7) // 8)
    local arrayPackedCursor_10 = varCursor_5
    local arrayPackedNext_11 = arrayPackedCursor_10 + arrayPackedByteCount_9
    if arrayPackedNext_11 > payloadLength then
        error(ERR_BOUNDS)
    end
    local arrayUnpackIndex_13 = 1
    for arrayPackedIndex_12 = 1, arrayPackedByteCount_9 do
        local arrayPackedByte_14 = readu8(payload, arrayPackedCursor_10)
        arrayPackedCursor_10 += 1
        local arrayBitMask_16 = 1
        for arrayBitIndex_15 = 1, 8 do
            if arrayUnpackIndex_13 > arrayCount_2 then
                break
            end
            arrayValues_7[arrayUnpackIndex_13] = band(arrayPackedByte_14, arrayBitMask_16) ~= 0
            arrayUnpackIndex_13 += 1
            arrayBitMask_16 = lshift(arrayBitMask_16, 1)
        end
    end
    varCursor_5 = arrayPackedCursor_10
    decoded_result = arrayValues_7
    offset = varCursor_5
    return decoded_result, offset
end

local Handler_Net_RemoteFunction_function_1: ((player: Player, data: { u8 }) -> { boolean })? = nil
local HandlerToken_Net_RemoteFunction_function_1 = 0

function Net_RemoteFunction_function_1.On(callback: Net_RemoteFunction_function_ServerFunctionCallback): Connection
    if type(callback) ~= "function" then error(ERR_TYPE) end
    HandlerToken_Net_RemoteFunction_function_1 += 1
    local token = HandlerToken_Net_RemoteFunction_function_1
    Handler_Net_RemoteFunction_function_1 = callback
    return CreateConnection(function()
        if HandlerToken_Net_RemoteFunction_function_1 == token then
            HandlerToken_Net_RemoteFunction_function_1 += 1
            Handler_Net_RemoteFunction_function_1 = nil
        end
    end)
end

function Net_RemoteFunction_function_1.Call(player: Player, data: { u8 }): { boolean }
    if typeof(player) ~= "Instance" or not player:IsA("Player") then
        error(ERR_TYPE)
    end
    local requestPayload = Encode_Net_RemoteFunction_function_1(data)
    local responseCount, responsePayload = WithCount(FunctionRemote:InvokeClient(player, requestPayload))
    if responseCount < 1 then
        error(ERR_SCHEMA)
    end
    if typeof(responsePayload) ~= "buffer" then
        error(ERR_TYPE)
    end
    local responseLength = len(responsePayload)
    if responseLength < 1 then
        error(ERR_BOUNDS)
    end
    local responseId = readu8(responsePayload, 0)
    if responseId ~= MESSAGE_ID_Net_RemoteFunction_function_1 then
        error(ERR_SCHEMA)
    end
    local decoded_result, responseOffset = DecodeReturn_Net_RemoteFunction_function_1(responsePayload, responseLength, 1)
    if responseOffset ~= responseLength then
        error(ERR_SCHEMA)
    end
    return decoded_result
end

FUNCTION_DISPATCH[1] = function(player, payload, payloadLength)
    local decoded_data, offset = Decode_Net_RemoteFunction_function_1(payload, payloadLength, 1)
    if offset ~= payloadLength then
        error(ERR_SCHEMA)
    end
    local callback = Handler_Net_RemoteFunction_function_1
    if callback == nil then
        error(ERR_SCHEMA)
    end
    local callbackRet_1 = callback(player, decoded_data)
    local responsePayload = EncodeReturn_Net_RemoteFunction_function_1(callbackRet_1)
    return responsePayload
end

local function StepReplication()
    FlushReliable()
    FlushUnreliable()
end

RunService.Heartbeat:Connect(StepReplication)

Reliable.OnServerEvent:Connect(function(player, payload)
    if typeof(payload) ~= "buffer" then
        return
    end
    local payloadLength = len(payload)
    if payloadLength < 1 then
        return
    end
    local offset = 0
    while offset < payloadLength do
        local messageId = readu8(payload, offset)
        offset += 1
        local segmentCount = 1
        local dispatch
        if messageId == SEGMENT_MARKER_ID then
            if offset >= payloadLength then
                return
            end
            messageId = readu8(payload, offset)
            offset += 1
            dispatch = RELIABLE_DISPATCH[messageId]
            if dispatch == nil then
                return
            end
            segmentCount, offset = ReadVarUInt(payload, payloadLength, offset)
            if segmentCount < 1 then
                return
            end
        else
            dispatch = RELIABLE_DISPATCH[messageId]
            if dispatch == nil then
                return
            end
        end
        for _segmentIndex = 1, segmentCount do
            local nextOffset = dispatch(player, payload, payloadLength, offset)
            offset = nextOffset
        end
    end
end)

Unreliable.OnServerEvent:Connect(function(player, payload)
    if typeof(payload) ~= "buffer" then
        return
    end
    local payloadLength = len(payload)
    if payloadLength < 1 then
        return
    end
    local offset = 0
    while offset < payloadLength do
        local messageId = readu8(payload, offset)
        offset += 1
        local segmentCount = 1
        local dispatch
        if messageId == SEGMENT_MARKER_ID then
            if offset >= payloadLength then
                return
            end
            messageId = readu8(payload, offset)
            offset += 1
            dispatch = UNRELIABLE_DISPATCH[messageId]
            if dispatch == nil then
                return
            end
            segmentCount, offset = ReadVarUInt(payload, payloadLength, offset)
            if segmentCount < 1 then
                return
            end
        else
            dispatch = UNRELIABLE_DISPATCH[messageId]
            if dispatch == nil then
                return
            end
        end
        for _segmentIndex = 1, segmentCount do
            local nextOffset = dispatch(player, payload, payloadLength, offset)
            offset = nextOffset
        end
    end
end)

FunctionRemote.OnServerInvoke = function(player, payload, ...)
    if typeof(payload) ~= "buffer" then
        error(ERR_TYPE)
    end
    local payloadLength = len(payload)
    if payloadLength < 1 then
        error(ERR_BOUNDS)
    end
    local messageId = readu8(payload, 0)
    local dispatch = FUNCTION_DISPATCH[messageId]
    if dispatch == nil then
        error(ERR_SCHEMA)
    end
    return dispatch(player, payload, payloadLength)
end

local Stats: NetStats = {
    GetReliableDropped = function() return RELIABLE_DROPPED end,
    GetUnreliableDropped = function() return UNRELIABLE_DROPPED end,
    GetReliableQueueSize = function() return RELIABLE_QUEUE_SIZE end,
    GetUnreliableQueueSize = function() return UNRELIABLE_QUEUE_SIZE end,
}

local Net = {
Entities = Net_Entities_reliable_1,
Booleans = Net_Booleans_reliable_2,
Strings = Net_Strings_reliable_3,
Numbers = Net_Numbers_reliable_4,
Dictionary = Net_Dictionary_reliable_5,
RemoteFunction = Net_RemoteFunction_function_1,
}

Net.StepReplication = StepReplication
Net.Stats = Stats
local NetTyped: NetRoot = Net

return table.freeze(NetTyped)
