# Unofficial Guide to Rebol's `sort` Function

The `sort` function in Rebol is a powerful tool for ordering data within a series. While its basic usage is straightforward, its various refinements offer sophisticated control over the sorting process. This guide provides a comprehensive overview of `sort`, from basic usage to advanced techniques, with practical advice for overcoming its nuances.

## Basic Sorting

By default, `sort` operates directly on a series, modifying it in place, and sorts the data in ascending order. It can handle various data types, including numbers, strings, and characters.

```rebol
>> test-block: [3 1 4 1 5 9 2 6]
>> sort test-block
== [1 1 2 3 4 5 6 9]
>> test-block
== [1 1 2 3 4 5 6 9]
```

**Note:** `sort` modifies the original series. If you need to preserve the original order, remember to `copy` the series before sorting.

### Sorting Different Data Types

- **Strings:** Sorted alphabetically.
- **Characters:** Sorted by their character code.
- **Decimals and Integers:** Sorted by their numeric value.

## Refinements for Advanced Control

`sort` offers several refinements to customize its behavior.

### `/case`: Case-Sensitive Sorting

By default, `sort` is case-insensitive. The `/case` refinement makes the sort case-sensitive, with uppercase letters coming before lowercase letters.

```rebol
>> test-strings: ["Apple" "banana" "Cherry" "apple"]
>> sort/case test-strings
== ["Apple" "Cherry" "apple" "banana"]
```

### `/reverse`: Descending Order

The `/reverse` refinement sorts the series in descending order.

```rebol
>> test-numbers: [1 3 2 5 4]
>> sort/reverse test-numbers
== [5 4 3 2 1]
```

### `/skip`: Sorting Records

The `/skip` refinement is used to sort a series that is structured as a sequence of records of a fixed size. `sort` will only consider the first element of each record for comparison.

```rebol
>> test-records: [3 "three" 1 "one" 2 "two"]
>> sort/skip test-records 2
== [1 "one" 2 "two" 3 "three"]
```

**Nuance:** The `/skip` refinement is not compatible with the `/all` refinement. Attempting to use them together will result in an error.

### `/part`: Partial Sorting

The `/part` refinement limits the sort to a specified number of elements from the beginning of the series.

```rebol
>> test-data: [5 3 8 1 9 2 7]
>> sort/part test-data 4
== [1 3 5 8 9 2 7]
```

**Nuance:** Providing a negative value to `/part` will not cause an error; it will simply do nothing.

### `/compare`: Custom Comparison

The `/compare` refinement allows you to specify a custom comparison logic. You can provide either an integer to specify which element in a sub-series to use for comparison, or a function for more complex comparisons.

#### Integer Comparator

When you provide an integer, `sort` will use the element at that index within each sub-series for comparison.

```rebol
>> test-data: [["Alice" 25] ["Bob" 30] ["Charlie" 20]]
>> sort/compare test-data 2
== [["Charlie" 20] ["Alice" 25] ["Bob" 30]]
```

#### Function Comparator

You can provide a function that takes two arguments and returns `true` if the first argument should come before the second. This allows for highly customized sorting logic.

```rebol
>> test-data: [4 2 6 1 5]
>> compare-func: function [a b] [
    abs (a - 3) < abs (b - 3)
]
>> sort/compare test-data :compare-func
== [2 4 1 5 6]
```

**Nuance:** If your comparison function can result in ties, the sort may not be stable. To ensure a stable sort, add a secondary comparison to handle ties.

### `/all`: Sorting on All Fields

The `/all` refinement is used to compare all fields in a series of records (sub-series). This is useful when you want to sort based on multiple criteria.

```rebol
>> test-data: [[1 "zebra"] [1 "apple"] [2 "banana"]]
>> sort/all test-data
== [[1 "apple"] [1 "zebra"] [2 "banana"]]
```

## Error Handling

When using `sort`, it's important to be aware of potential errors. The most common errors occur when using incompatible refinements (like `/skip` and `/all`) or when providing invalid arguments. You can use the `try` function to catch these errors gracefully.

```rebol
>> set/any 'result try [sort/skip/all [1 2 3 4] 2]
>> error? result
== true
```

## Sorting Mixed Data Types

Rebol has a defined order for sorting mixed data types. While it may seem counterintuitive, `sort` will not error on a series of mixed types. The general order is:

`none` < `logic` < `integer` < `decimal` < `char` < `string` < `word` < `block`

```rebol
>> test-mixed: [1 "apple" 2.5 #"b"]
>> sort test-mixed
== [1 2.5 "apple" #"b"]
```

By understanding these principles and nuances, you can effectively use the `sort` function to manage and order your data in Rebol.
