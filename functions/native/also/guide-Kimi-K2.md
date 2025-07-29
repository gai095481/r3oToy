# Unofficial User's Guide for `also` Function

## Introduction

The `also` function in Rebol 3 Oldes branch is a versatile utility that allows you to evaluate two expressions, returning the result of the first while ensuring the second is evaluated for its side effects. This guide provides a comprehensive overview of how to use the `also` function effectively, based on the diagnostic probe script results.

The `also` function is a powerful tool in Rebol 3 Oldes branch, allowing for flexible expression evaluation and side effect management. By understanding its behavior and nuances, you can leverage it effectively in your programs. This guide, based on the diagnostic probe script results, provides a comprehensive overview to help you get started.

## Tips for Novice Programmers

1. **Understand the Purpose**: Use `also` when you need to evaluate an expression for its side effects but want to return a different value.
2. **Avoid Unnecessary Complexity**: Keep the second argument simple if possible to avoid confusion.
3. **Handle Errors Gracefully**: Be aware that errors in the second argument can propagate, so handle them appropriately.
4. **Test Thoroughly**: Always test your use of `also` to ensure it behaves as expected, especially in nested scenarios.

## Basic Usage

The `also` function takes two arguments and returns the first one, while evaluating the second for any side effects. The syntax is straightforward:

> also <value1> <value2>

### Example:



```rebol
result: also 42 (print "Side effect")
print result

;; Output:
Side effect
42
```

## Key Features and Behavior

### 1. Basic Return Value Behavior

The `also` function always returns the first value, regardless of the second value's type or evaluation result.

- **Integer and String**: The first value is returned unchanged.
  
  ```rebol
  test-result: also 42 "ignored"
  assert-equal 42 test-result "Integer return"
  ```
- **Block and None**: The first value is returned unchanged.
  
  ```rebol
  test-result: also [1 2 3] none
  assert-equal [1 2 3] test-result "Block return"
  ```
- **Logic Values**: The first logic value is returned unchanged.
  
  ```rebol
  test-result: also true false
  assert-equal true test-result "Logic return"
  ```

### 2. Second Value Evaluation

The second value is evaluated for its side effects, even if its result is discarded.

- **Variable Assignment**: The second value can include variable assignments.
  
  ```rebol
  side-effect-var: none
  test-result: also "returned" (side-effect-var: "assigned")
  assert-equal "returned" test-result "Return value should be first argument"
  assert-equal "assigned" side-effect-var "Side effect should execute"
  ```
- **Function Calls**: The second value can include function calls.
  
  ```rebol
  side-effect-executed?: false
  side-effect-func: does [
      set 'side-effect-executed? true
      "side-effect-result"
  ]
  test-result: also "main-result" side-effect-func
  assert-equal "main-result" test-result "Should return first value"
  assert-equal true side-effect-executed? "Function call should execute"
  ```

### 3. Expression Evaluation

Both arguments can be complex expressions, evaluated normally.

- **Mathematical Expressions**: The first expression's result is returned.
  
  ```rebol
  test-result: also (5 + 3) (10 * 2)
  assert-equal 8 test-result "Should return result of first expression"
  ```
- **String Operations**: The first string operation's result is returned.
  
  ```rebol
  test-str1: "Hello"
  test-str2: "World"
  test-result: also (append copy test-str1 " there") (append copy test-str2 " peace")
  assert-equal "Hello there" test-result "Should return result of first string operation"
  ```

### 4. Type Diversity

The `also` function works with any combination of datatypes for both arguments.

- **Mixed Numeric Types**: The first value's type is preserved.
  
  ```rebol
  test-result: also 42 3.14
  assert-equal 42 test-result "Integer and decimal - should return integer"
  ```
- **String and Block**: The first value's type is preserved.
  
  ```rebol
  test-result: also "text" [1 2 3]
  assert-equal "text" test-result "String and block - should return string"
  ```

### 5. Edge Cases and Error Conditions

The `also` function handles various edge cases gracefully.

- **Empty Values**: Empty values are handled correctly.
  
  ```rebol
  test-result: also [] [1 2 3]
  assert-equal [] test-result "Empty block as first argument should return empty block"
  ```
- **Error in Second Argument**: Errors in the second argument do not affect the first.
  
  ```rebol
  error-happened?: false
  test-result: none
  set/any 'test-result try [
      also "success" (1 / 0)  ;; Division by zero in second argument
  ]
  assert-equal "success" test-result "Error in second argument should not affect first"
  ```

### 6. Nested `also` Calls

`also` calls can be nested, with each call returning its first argument while evaluating its second.

- **Simple Nesting**: Nested `also` calls are evaluated from inside out.
  ```rebol
  nested-counter: 0
  test-result: also "outer" (also "inner" (nested-counter: nested-counter + 1))
  assert-equal "outer" test-result "Nested ALSO should return outermost first value"
  assert-equal 1 nested-counter "Nested side effect should execute"
  ```

### 7. Performance and Evaluation Order

Arguments are evaluated in left-to-right order.

- **Evaluation Order**: The first argument is evaluated before the second.
  ```rebol
  eval-order: []
  first-expr: (append eval-order "first" "first-result")
  second-expr: (append eval-order "second" "second-result")
  test-result: also first-expr second-expr
  assert-equal "first-result" test-result "Should return result of first expression"
  assert-equal ["first" "second"] eval-order "Should evaluate arguments left-to-right"
  ```
