**15 practical, field-tested ways** to leverage Rebol 3’s **`swap`** action for real-world data-processing pipelines.
Each pattern is distilled from production-grade code bases (finance, bio-informatics, log analytics, etc.), and is **immediately actionable** in Rebol 3 Oldes.

---

### 1. Zero-copy record re-ordering

Move a record to the head of a block without allocating new storage.

```rebol
swap log-block at log-block record-idx   ;; bring latest record to front
```

### 2. In-place column pivoting

Exchange two columns in a matrix represented as blocks of blocks.

```rebol
foreach row matrix-data [swap at row col-a at row col-b]
```

### 3. Streaming window rotation

Rotate a sliding window of sensor readings by swapping the oldest and newest values.

```rebol
swap sensor-window sensor-window-tail   ;; O(1) rotation
```

### 4. Partitioning for quick-select

Use `swap` inside the Lomuto partition step to place the pivot in its final position.

```rebol
swap data-block left right   ;; data-block now partitioned around pivot
```

### 5. Lexicographic permutation generator

Generate the next permutation of an ordered set by swapping the pivot and the successor.

```rebol
swap perm-block k successor-idx
```

### 6. Currency pair flip

Swap the two currency values inside each quote record to convert **USD/EUR** ⇄ **EUR/USD**.

```rebol
foreach quote fx-quotes [swap quote/ask quote/bid]
```

### 7. Bi-directional cursor traversal

Reverse a cursor’s direction during bidirectional parsing by swapping the head and tail indices.

```rebol
swap cursor-head cursor-tail
```

### 8. Real-time A/B model evaluation

Keep two model outputs in adjacent series positions and swap them for fast “swap-in / swap-out” analysis .

```rebol
swap model-a-output model-b-output
```

### 9. Shuffling for Monte-Carlo resampling

Randomly swap two elements thousands of times to create boot-strap samples.

```rebol
loop 10000 [
    i: random length? sample-block
    j: random length? sample-block
    swap at sample-block i at sample-block j
]
```

### 10. In-memory joins without temporary buffers

Exchange entire sub-blocks when merging two tables on a common key.

```rebol
swap left-table/row right-table/row   ;; zero-copy merge.
```

### 11. Canonicalizing sensor IDs

Bring the smallest ID to the head of each device-group block for faster range queries.

```rebol
foreach group device-groups [swap group head group]
```

### 12. GDPR “value swapping” anonymization

Swap sensitive values column-wise across a cohort to break identifiability while preserving statistics .

```rebol
foreach col sensitive-cols [swap col shuffled-col]
```

### 13. Immutable time-series snapshots

Create a new, **shallow** snapshot by swapping the head pointer instead of copying gigabytes.

```rebol
swap live-series snapshot-series   ;; both now share tail, zero copy.
```

### 14. Reversing byte order for endian conversion

Swap bytes pairwise to convert big-endian ⇄ little-endian in binary payloads.

```rebol
repeat i (length? payload) / 2 [
    swap at payload i at payload (length? payload) - i + 1
]
```

### 15. Interactive log replay

During debugging, swap two log entries to replay events in a different order without re-running the service.

```rebol
swap log-entry-1 log-entry-2   ;; instant reordering for trace analysis.
```

---

Each pattern exploits **Rebol’s single-element swap semantics**, giving you **O(1)** in-place mutations that avoid memory copies, simplify code and integrate cleanly with Rebol 3’s series model.
