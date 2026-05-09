# Benchmarks
These benchmarks are conducted by firing the network event 1000 times per frame with the same data for 10 seconds, at the end of which the average FPS and Kbps are recorded. Each data contains 500-2000 individual elements, depending on the test. All benchmarks are conducted in studio. See the benchmarks [source code](https://github.com/breadboardengineer1234/QuickNet/tree/main/benchmarks) for more details.

### Entities Test

| Networking Tool | FPS | FPS Scale | Kbps |
|--------------------|------------------------|--------------------|---------------|
| RemoteEvent | 3.91 | 1x | 1853031.17
| Jolt | 3.62 | 0.96x |  95.11
| Packet | 10.26 | 2.62x |  41.33 
| ByteNet | 14.66 | 3.75x | 38.66
| QuickNet | 34.86 | 8.92x | 40.78 

### Booleans Test

| Networking Tool | FPS | FPS Scale | Kbps |
|--------------------|------------------------|--------------------|----------------|
| RemoteEvent | 7.36 | 1x |  523520.05 |
| Jolt | 3.39 | 0.46x |  124.53
| Packet | 11.19 | 1.52x | 9.83 |
| ByteNet | 12.98 | 1.76x | 9.25 |
| QuickNet | 141.23 | 19.19x | 2.89 |

### Strings Test

| Networking Tool | FPS | FPS Scale | Kbps |
|--------------------|------------------------|--------------------|---------------|
| RemoteEvent | 10.82 | 1x | 814948.14 |
| Jolt | 5.19 | 0.48x | 56.22 |
| Packet | 10.53 | 0.97x | 21.38 |
| ByteNet | 0.21 | 0.02x | 39.83 |
| QuickNet | 44.15 | 4.08x | 18.63 |

### Numbers Test

| Networking Tool | FPS | FPS Scale | Kbps |
|--------------------|------------------------|--------------------|------------|
| RemoteEvent | 5.45 | 1x | 2115972.12 |
| Jolt | 2.01 | 0.39x | 332.85 |
| Packet | 6.20 | 1.14x | 129.53 |
| ByteNet | 6.84 | 1.26x | 120.27 |
| QuickNet | 60.23 | 11.05x | 125.42 |

### Dictionary Test

| Networking Tool | FPS | FPS Scale | Kbps |
|--------------------|------------------------|--------------------|------------|
| RemoteEvent | 6.12 | 1x | 1923782.58 |
| Jolt | 4.58 | 0.75x | 128.16 |
| Packet | 4.72 | 0.77x | 145.78 |
| ByteNet | 0.10 | 0.02x | 246.81 |
| QuickNet | 22.52 | 3.68x | 142.24 |

### RemoteFunction Test
Unlike the other tests, the RemoteFunction test is conducted by sending a table of 500 numbers 1000 times per frame with a response of a table of 500 booleans for every send. The metrics are recorded at the end of a 5 minute period. This test helps us observe performance degradation over an extended period of heavy load.

| Networking Tool | FPS | FPS Scale | Kbps 
|--------------------|------------------------|--------------------|----------------|
| RemoteFunction | 3.28 | 1x | 1435503.71 |
| Jolt | 3.24 | 0.99x | 307.97
| Packet | Crash |  |
| ByteNet | N/A | |
| QuickNet | 58.29 | 17.77x |  159.12 |
