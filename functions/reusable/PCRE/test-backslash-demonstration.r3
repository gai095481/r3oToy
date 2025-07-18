REBOL [
    Title: "Backslash Escaping Issue Demonstration"
    Date: 17-Jul-2025
    File: %test-backslash-demonstration.r3
    Author: "Kiro AI Assistant"
    Purpose: "Demonstrate the specific double backslash vs single backslash issue"
]

;; Load the RegExp engine
do %regexp-engine.r3

print "^/=========================================="
print "BACKSLASH ESCAPING ISSUE DEMONSTRATION"
print "=========================================="

print "^/--- Testing Current (Incorrect) Double Backslash Usage ---"
print ["Double backslash \\d pattern: " mold "\\d"]
print ["RegExp result with double backslash: " mold RegExp "123" "\\d"]
print ["Expected: Should match digits, but fails due to literal backslash"]

print "^/--- Testing Correct Single Backslash Usage ---"
print ["Single backslash \d pattern: " mold "\d"]
print ["RegExp result with single backslash: " mold RegExp "123" "\d"]
print ["Expected: Should match digits, and works correctly"]

print "^/--- Demonstrating the Problem ---"
print "The issue is that test files use double backslashes like ""\\d"""
print "which creates a literal backslash character followed by 'd'"
print "instead of the regex escape sequence for digits."

print "^/--- Testing Negated Patterns ---"
print ["Double backslash \\D (should fail): " mold RegExp "abc" "\\D"]
print ["Single backslash \D (should work): " mold RegExp "abc" "\D"]

print "^/=========================================="
print "This demonstrates why the comprehensive test suite"
print "shows failures for negated escape sequences."
print "=========================================="
