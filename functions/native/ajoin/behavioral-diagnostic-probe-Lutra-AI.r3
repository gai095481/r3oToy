REBOL [
    Title: "AJOIN Behavior Probe - Working Version"
    Author: "Expert Rebol 3 Engineer"
    Version: 2.2.0
    Date: 03-Jul-2025
    Purpose: "Simple working test suite for ajoin function"
    Note: "Simplified to avoid Rebol 3 scoping issues"
]

;; Simple assertion function that doesn't rely on external state
assert-equal: func [expected actual description] [
    result: equal? expected actual
    either result [
        print ["✅ PASSED:" description]
    ][
        print ["❌ FAILED:" description]
        print ["   Expected:" mold expected]
        print ["   Actual:  " mold actual]
    ]
    result
]

print "=== WORKING AJOIN BEHAVIOR PROBE - V2.2 ==="
print "Simplified to avoid scoping issues^/"

passed: 0
failed: 0

;; Test helper that counts results
test: func [expected actual description] [
    result: assert-equal expected actual description
    either result [passed: passed + 1][failed: failed + 1]
    result
]

print "=== Basic Behavior Tests ==="

;; Basic concatenation
test "ABCDEF" ajoin ["ABC" "DEF"] "Basic string concatenation"
test "1apple3.14" ajoin [1 "apple" none "3.14"] "Mixed types with none ignored"
test "Hellotrue" ajoin ["Hello" true] "String and logic concatenation"

;; Type verification
test string! type? ajoin [<ABC> 123] "Return type is string!"
test "<ABC>123" ajoin [<ABC> 123] "Tag and integer content"
test "100value" ajoin [100 "value"] "Number and string"

print "^/=== /with Refinement Tests ==="

;; Delimiter tests
test "1,2,3" ajoin/with [1 2 3] "," "Basic delimiter"
test "apple|banana" ajoin/with ["apple" "banana"] "|" "Pipe delimiter"
test "1,apple,3.14" ajoin/with [1 "apple" none 3.14] "," "None ignored with delimiter"

print "^/=== /all Refinement Tests ==="

;; Include none tests
test "1applenone3.14" ajoin/all [1 "apple" none 3.14] "Include none values"
test "nonenonenone" ajoin/all [none none none] "All none values with /all"

print "^/=== Combined Refinements ==="

;; Combined refinements
test "1,apple,none,3.14" ajoin/all/with [1 "apple" none 3.14] "," "All and with combined"

print "^/=== Edge Cases ==="

;; Edge cases
test "" ajoin [] "Empty block"
test "" ajoin [none none] "All none values (ignored)"
test "123456" ajoin [123 456] "Two integers"

print "^/=== Results ==="
total: passed + failed
print ["Total tests:" total]
print ["Passed:" passed]
print ["Failed:" failed]

if total > 0 [
    print ["Success rate:" to-integer (passed * 100 / total) "%"]
]

either failed = 0 [
    print "^/✅ ALL TESTS PASSED"
    true
][
    print "^/❌ SOME TESTS FAILED"
    false
]
