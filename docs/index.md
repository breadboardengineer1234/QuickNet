---
layout: docs
title: Home
---

# QuickNet
High performance networking solution for Roblox.

## Performance
QuickNet uses dozens of clever optimization techniques under the hood to reduce allocations and minimize CPU usage. As a result, QuickNet is typically able to deliver **higher FPS** compared to default RemoteEvents. In addition, its buffer implementation allows data to be compressed when sent over the network, resulting in **lower network latency**.

## Protection
QuickNet performs sanity checks on incoming data from clients to protect the server from invalid data and DDoS. In addition, the developer can set custom rate limits for each network event to protect the server from spammers.

## Accessibility
QuickNet's high performance does not come at the cost of accessibility. QuickNet requires no plugins or specific installations. Furthermore, QuickNet has very similar syntax to default Remotes, meaning it can be seamlessly integrated into existing games that already use RemoteEvents, and requires minimal learning by the user.

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
