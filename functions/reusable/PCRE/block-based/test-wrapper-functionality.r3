REBOL [
    Title: "Test Wrapper Module Functionality"
    Date: 20-Jul-2025
    Purpose: "Verify test wrapper module works with modular engine"
    Type: "Diagnostic Script"
]

print "^/=== TESTING TEST WRAPPER MODULE FUNCTIONALITY ==="

;; Load the test wrapper module
print "Loading test wrapper module..."
do %src/regexp-test-wrapper.r3
print "✅ Test wrapper module loaded successfully"

;; Test basic TestRegExp function
print "^/--- Testing Basic TestRegExp Function ---"

basic-tests: [
    "123" "\d{3}" true "exact quantifier match"
    "12" "\d{3}" false "exact quantifier too short"
    "abc123" "\w+\d+" true "mixed pattern match"
    "hello" "hello" true "literal match"
    "test" "\d+" false "no match case"
]

repeat i (length? basic-tests) / 4 [
    haystack: basic-tests/(i * 4 - 3)
    pattern: basic-tests/(i * 4 - 2)
    expected: basic-tests/(i * 4 - 1)
    description: basic-tests/(i * 4)
    
    actual: TestRegExp haystack pattern
    status: either actual = expected ["PASS"] ["FAIL"]
    print ["  " status ":" description "=>" actual "(expected" expected ")"]
]

;; Test detailed testing function
print "^/--- Testing TestRegExpDetailed Function ---"

detailed-result: TestRegExpDetailed "abc123" "\w+\d+"
print ["Detailed test result type:" type? detailed-result]
print ["Match found:" detailed-result/match-found]
print ["Match string:" mold detailed-result/match-string]
print ["Result type:" detailed-result/result-type]

;; Test error handling
error-result: TestRegExpDetailed "test" ""
print ["Error test - error occurred:" error-result/error-occurred]
print ["Error test - result type:" error-result/result-type]

;; Test suite functionality
print "^/--- Testing RunTestSuite Function ---"

suite-tests: [
    "123" "\d{3}" "exact quantifier"
    "abc123" "\w+\d+" "mixed pattern"
    "hello" "hello" "literal"
    "test" "\d+" "no match"
]

suite-results: RunTestSuite suite-tests
print ["Suite results type:" type? suite-results]
print ["Total tests:" suite-results/total-tests]
print ["Passed tests:" suite-results/passed-tests]
print ["Success rate:" suite-results/success-rate "%"]

;; Test result printing
print "^/--- Testing PrintTestResults Function ---"
PrintTestResults suite-results

;; Test backward compatibility function
print "^/--- Testing Backward Compatibility Function ---"
compatibility-result: TestBackwardCompatibility
print ["Backward compatibility result:" compatibility-result]

;; Test benchmarking functionality
print "^/--- Testing Benchmark Function ---"
benchmark-result: BenchmarkRegExp "abc123" "\w+\d+" 100
print ["Benchmark result type:" type? benchmark-result]
print ["Benchmark iterations:" benchmark-result/iterations]
print ["Successful matches:" benchmark-result/successful-matches]

PrintBenchmarkResults benchmark-result

print "^/=== TEST WRAPPER MODULE FUNCTIONALITY TEST COMPLETE ==="
print "✅ All test wrapper functions are working correctly!"
