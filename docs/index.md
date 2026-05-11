---
layout: docs
title: Home
---

# QuickNet
### High performance networking solution for Roblox.

* Aggressive CPU optimizations under the hood
* Data serialization and buffer based networking
* Batched packets with action routing
* Protection against invalid data and DDoS
* Custom rate limiting
* Type-safe network events
* Simple API with no performance compromise

## Getting Started

- [Benchmarks](benchmarks.md)
- [Installation](installation.md)
- [Quickstart](quickstart.md)

## Updates
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
