# User Manual: Rebol 3 Multi-Dimensional Array Library

This document provides a complete guide to using the Multi-Dimensional Array Manipulation Library (`array_demo-make-robustly.r3`). This library provides a suite of functions for creating accessing modifying and validating multi-dimensional arrays (also known as matrices or tensors) in the Rebol 3 Oldes branch environment.

## 1. Library Overview

The library is composed of three main categories of functions:
1.  **Array Creation:** Functions to build new multi-dimensional arrays.
2.  **Array Access:** Functions to safely get and set element values.
3.  **Array Information:** Functions to analyze and validate the structure of an array.

A "multi-dimensional array" in the context of this library is represented as a Rebol `block!` where each element can be another `block!` creating a nested structure. A "regular" array is one where all sub-arrays at the same level of depth have the same length.

## 2. Core Functions

This section details the main functions provided by the library.

---

### `make-array`

Creates a new multi-dimensional array with a specified structure and an initial value for all elements.

#### Syntax
```rebol
make-array dimensions

make-array/with dimensions value
```

#### Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `dimensions` | `block!` | **Required.** A block of positive integers defining the size of each dimension. For example `[2 3]` creates a 2x3 array. |
| `/with` | *refinement* | Optional: Initializes the array with a specific value. |
| `value` | `any-type!` | The value to place in every element of the new array. If `/with` is not used the default is `none`. |

#### Returns
- A `block!` representing the newly created multi-dimensional array.
- An `error!` object if the `dimensions` block is invalid (e.g. empty contains non-integers zero or negative numbers).

#### Examples

**Create a 2x3 array initialized with `none`:**
```rebol
>> make-array [2 3]
== [[none none none] [none none none]]
```

**Create a 3x2 array initialized with `0`:**
```rebol
>> make-array/with [3 2] 0
== [[0 0] [0 0] [0 0]]
```

**Create a 2x2x2 array:**
```rebol
>> make-array [2 2 2]
== [[[none none] [none none]] [[none none] [none none]]]
```

---

### `get-element`

Safely retrieves a value from an array at a specified set of indices.

#### Syntax
```rebol
get-element arr indices
```

#### Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `arr` | `block!` | **Required.** The multi-dimensional array to read from. |
| `indices` | `block!` | **Required.** A block of 1-based integers specifying the path to the desired element. |

#### Returns
- The value at the specified location (`any-type!`). This can be a leaf element or an entire sub-array.
- An `error!` object if the indices are out of bounds or invalid.

#### Example

```rebol
>> my-array: [[1 2] [3 4]]

>> get-element my-array [2 1]  ; Get element from 2nd row, 1st column
== 3

>> get-element my-array [1]    ; Get the entire first row
== [1 2]
```

---

### `set-element`

Safely modifies a leaf element's value at a specified location within an array. **This function modifies the array in-place.**

#### Syntax
```rebol
set-element arr indices value
```

#### Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `arr` | `block!` | **Required.** The array to modify. |
| `indices` | `block!` | **Required.** The path to the element you wish to change. |
| `value` | `any-type!` | **Required.** The new value for the element. |

#### Security Note
This function will **not** allow you to replace an entire sub-array (a nested `block!`). It is designed to only modify leaf elements to prevent accidental destruction of the array's structure.

#### Returns
- The modified array `block!`.
- An `error!` object if the indices are invalid or if the target is a sub-array.

#### Example
```rebol
>> my-array: [[1 2] [3 4]]

>> set-element my-array [1 2] 99
== [[1 99] [3 4]]

>> print my-array
[[1 99] [3 4]]
```

---

### `get-dimensions`

Analyzes an array and returns its dimensions.

#### Note on Behavior
This function determines dimensions by traversing the *first* element at each level of depth. For an irregular array (e.g. `[ [2 3]]`) it will report the dimensions based on the path of the first elements (`[2 1]`). To check for structural consistency use `valid-array?`.

#### Syntax
```rebol
get-dimensions arr
```

#### Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `arr` | `block!` | **Required.** The array to analyze. |

#### Returns
- A `block!` of integers representing the dimensions.
- An empty `block!` `[]` for an empty input array.

#### Example
```rebol
>> my-array: [[[0 0] [0 0]] [[0 0] [0 0]] [[0 0] [0 0]]]

>> get-dimensions my-array
== [3 2 2]
```

---

### `valid-array?`

Checks if an array is "regular" meaning it has consistent dimensions throughout its entire structure.

#### Syntax
```rebol
valid-array? arr
```

#### Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `arr` | `block!` | **Required.** The array to validate. |

#### Returns
- `true` if the array is regular.
- `false` if the array is irregular (i.e. sub-arrays at the same depth have different lengths).

#### Example
```rebol
>> regular-array: [[1 2] [3 4]]
>> valid-array? regular-array
== true

>> irregular-array: [[1] [2 3]]
>> valid-array? irregular-array
== false
```

## 6. Included Test Suite

The script file `array_demo-make-robustly.r3` contains an extensive test harness that runs automatically when the script is executed. It includes **52 test cases** covering valid operations edge cases and error conditions for every function in the library. This suite ensures the reliability and correctness of the provided functions.

---
