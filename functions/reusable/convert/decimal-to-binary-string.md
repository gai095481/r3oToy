# User Manual: `decimal-to-binary-string` for Rebol 3 Oldes

This document provides a comprehensive user manual for the `decimal-to-binary-string.r3` script. The script provides a single robust function for converting decimal integers into their binary string representation.

## 1. Function Overview

### `decimal-to-binary-string`

This is the core function of the script. It takes a single Rebol `integer!` as input and returns a `string!` containing the binary representation of that integer.

-   **Purpose:** To provide a simple and reliable way to convert base-10 integers to base-2 (binary) strings.
-   **Handles:** Positive integers negative integers and zero.
-   **Error Handling:** The function is designed to be safe but the current version relies on Rebol's type-hinting for validation. Future versions will include explicit error handling for non-integer inputs.

## 2. Syntax

```rebol
decimal-to-binary-string int-src
```

### Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `int-src` | `integer!` | **Required.** The decimal integer you wish to convert. |

### Return Value

| Type | Description |
| :--- | :--- |
| `string!` | The binary representation of the input integer. For negative inputs the string will be prefixed with a minus sign (`-`). |

## 3. Usage and Examples

To use the function simply call it with an integer value.

### Example 1: Basic Positive Conversion

Converting a standard positive integer.

```rebol
>> decimal-to-binary-string 10
== "1010"

>> decimal-to-binary-string 255
== "11111111"
```

### Example 2: Negative Number Conversion

The function handles negative numbers by converting the absolute value to binary and prepending a `-` sign.

```rebol
>> decimal-to-binary-string -5
== "-101"

>> decimal-to-binary-string -10
== "-1010"
```

### Example 3: Handling Zero

Zero is handled as a special case and correctly returns `"0"`.

```rebol
>> decimal-to-binary-string 0
== "0"
```

## 4. How It Works (Algorithm)

The function uses a standard and efficient algorithm for conversion:

1.  **Zero Check:** It first checks if the input is `0`. If so it immediately returns the string `"0"`.
2.  **Sign Handling:** It determines if the number is negative. If it is the function stores this fact and proceeds using the number's absolute value.
3.  **Conversion Loop:** For non-zero numbers the function repeatedly performs two steps until the number becomes `0`:
    a. It calculates the remainder of the number when divided by 2 (using the `//` operator). This will always be `0` or `1`.
    b. It prepends this remainder to an internal list of digits.
    c. It performs integer division of the number by 2 for the next iteration.
4.  **String Assembly:** Once the loop is complete the collected block of digits (which is now in the correct order) is joined into a single string using `rejoin`.
5.  **Final Sign:** If the original number was negative a `-` sign is prepended to the final binary string.

## 5. Included Test Suite

The script `decimal-to-binary-string.r3` includes a built-in comprehensive test suite that runs automatically when the script is executed. This suite validates the function's correctness across a range of test cases ensuring reliability.

### Test Cases Covered:

-   Zero (`0`)
-   Small positive integers (`1` `2` `3` `5`)
-   Powers of two (`8` `16`)
-   Numbers that result in all ones (`15` `255`)
-   Negative integers (`-5` `-10`)

When you run the script you will see the following output if all tests pass successfully:

```
Running the decimal-to-binary-string converter...

=== Testing decimal-to-binary-string function ===
Test: Zero - ✅ PASSED
Test: One - ✅ PASSED
Test: Two - ✅ PASSED
Test: Three - ✅ PASSED
Test: Five - ✅ PASSED
Test: Eight (power of 2) - ✅ PASSED
Test: Ten - ✅ PASSED
Test: Eleven - ✅ PASSED
Test: Fifteen (all ones in 4 bits) - ✅ PASSED
Test: Sixteen (power of 2) - ✅ PASSED
Test: 255 (8 bits all ones) - ✅ PASSED
Test: Negative five - ✅ PASSED
Test: Negative ten - ✅ PASSED

Overall result: ✅ ALL TESTS PASSED

```

## 6. Technical Details & Dependencies

-   **Rebol Version:** Tested with REBOL/Bulk 3.19.0 (Oldes branch).
-   **Dependencies:** None. This is a standalone script with no external library requirements.
-   **File:** `%decimal-to-binary-string.r3`
