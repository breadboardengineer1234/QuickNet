---
layout: docs
title: Home
---

# QuickNet
High performance networking solution for Roblox.

## Performance
QuickNet uses clever optimization techniques under the hood to reduce allocations and minimize CPU usage. As a result, QuickNet is typically able to deliver **higher FPS** compared to default RemoteEvents. In addition, its buffer implementation allows data to be compressed when sent over the network, resulting in much **lower network bandwidth usage**.

## Protection
QuickNet performs sanity checks on incoming data from clients to protect the server from invalid data and DDoS. In addition, the developer can set custom rate limits for each network event to protect the server from spammers.

## Accessibility
QuickNet's high performance does not come at the cost of accessibility. QuickNet requires no plugins or specific installations. Furthermore, QuickNet has very similar syntax to default Remotes, meaning it can be seamlessly integrated into existing games that already use RemoteEvents, and requires minimal learning by the user.

## Getting Started

- [Benchmarks](benchmarks.md)
- [Installation](installation.md)
- [Quickstart](quickstart.md)

## Updates
### v0.3.1 (6/5/26)
* Fixed instance pointer bug for nil instances on receiving end
* Improved debug message for response events
* Removed some unnecessary code

### v0.3.0 (5/16/26)
* Added optional types via the data.optional method. Optional types have significantly better performance than Any types
* Added union types via the data.union and data.unionMany methods. Union types have slightly better performance than Any types for primitives, but significantly better performance for table types
* Added literal types via the data.literal method. Literal types typically use much less bandwidth than normal types but do not have better performance (a little worse in most cases)
* Added 13 new serialized types: NumberU4, CFrameI16FX16, Vector3I16, Vector2I16, Player, ColorSequence, NumberSequence, NumberRange, UDim, UDim2, Region3, PhysicalProperties, Rect. Check [here](https://breadboardengineer1234.github.io/QuickNet/types) for more info
* Changed the way NumberU8s are encoded when passed in a table. Values that do not follow NumberU8 rules no longer corrupt other NumberU8 values. In addition, the serialization has been slightly optimized.
* Slight adjustments to internal parameters

### v0.2.0 (5/10/26)
* Added unreliable support, simply call :Unreliable when registering an event
* Fixed a bug where sending a table throws an error when using the Any type
* Added new serialized types: BrickColor, DateTime32, DateTime64, CFrameF32Aligned, TweenInfo
* Added :Once method
* Fixed an issue where calling :Wait doesn’t return the arguments
* Optimized connection objects: no longer creates new closures for each connection
* FX16 scale factor changed from 128 → 100
* Adjusted some other internal parameters

### v0.1.0 (5/7/26)
* Release
