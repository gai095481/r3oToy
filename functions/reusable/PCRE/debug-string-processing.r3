REBOL [
    Title: "Debug String Processing"
    Date: 17-Jul-2025
    File: %debug-string-processing.r3
    Author: "Kiro AI Assistant"
]

print "^/=== DEBUGGING STRING PROCESSING ==="

;; Test what's actually in the strings
print "^/--- String Content Analysis ---"
d-string: "\d"
D-string: "\D"

print ["\d string: " mold d-string]
print ["\D string: " mold D-string]
print ["\d length: " length? d-string]
print ["\D length: " length? D-string]
print ["\d as block: " mold to-block d-string]
print ["\D as block: " mold to-block D-string]

;; Test character by character
print "^/--- Character by Character Analysis ---"
print ["\d first char: " mold d-string/1]
print ["\d second char: " mold d-string/2]
print ["\D first char: " mold D-string/1]
print ["\D second char: " mold D-string/2]

;; Test ASCII values
print ["\d second char ASCII: " to-integer d-string/2]
print ["\D second char ASCII: " to-integer D-string/2]

;; Test equality
print "^/--- Equality Tests ---"
print ["\d = \D: " d-string = D-string]
print ["\d/2 = \D/2: " d-string/2 = D-string/2]
print ["'d' = 'D': " #"d" = #"D"]

;; Test parse behavior
print "^/--- Parse Behavior Tests ---"
print "Testing \d string:"
parse d-string [
    "\" [
        "d" (print "  Matched lowercase d")
        |
        "D" (print "  Matched uppercase D")
        |
        skip (print "  Matched other character")
    ]
]

print "Testing \D string:"
parse D-string [
    "\" [
        "d" (print "  Matched lowercase d")
        |
        "D" (print "  Matched uppercase D")
        |
        skip (print "  Matched other character")
    ]
]

;; Test case sensitivity
print "^/--- Case Sensitivity Tests ---"
print "Testing with case-sensitive parse:"
parse/case D-string [
    "\" [
        "d" (print "  Matched lowercase d (case-sensitive)")
        |
        "D" (print "  Matched uppercase D (case-sensitive)")
        |
        skip (print "  Matched other character (case-sensitive)")
    ]
]
