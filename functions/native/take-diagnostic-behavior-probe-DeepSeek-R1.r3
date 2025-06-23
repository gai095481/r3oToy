REBOL [
    Title: "TAKE Function Validation Probe"
    Purpose: {Validates TAKE behavior with robust state capture}
]

; === IMPROVED VALIDATION FRAMEWORK ===
fail-count: 0
pass-count: 0

test: func [
    "Run a test case with validation"
    name [string!]
    setup [block!]
    operation [block!]
    expected-return
    expected-state
][
    ; Setup test environment
    do setup

    ; Execute operation and capture return value
    actual-return: do operation

    ; Capture state based on test context
    actual-state: switch name [
        "Take first from block" [copy blk]
        "Take first char from string" [copy str]
        "Take from empty block" [copy empty-blk]
        "/LAST with block" [copy blk]
        "/LAST with string" [copy str]
        "/PART with count (block)" [copy blk]
        "/PART with position marker" [copy str]
        "/PART with /LAST" [copy blk]
        "/DEEP nested block" [copy blk]  ; State is the modified blk
        "/ALL with block" [copy blk]
        "/ALL with string" [copy str]
        "Take from none" [none]
        "Over-length take" [copy blk]
        "Modified series view" [copy orig]
    ]

    ; Report results
    print rejoin ["^/=== TEST: " name " ==="]
    print ["Operation:" mold operation]
    print ["Return:   " mold actual-return]
    print ["Expected:" mold expected-return]
    print ["State:    " mold actual-state]
    print ["Expected:" mold expected-state]

    ; Validate and print status
    return-pass?: actual-return == expected-return
    state-pass?: actual-state == expected-state

    either all [return-pass? state-pass?][
        print "✅ PASSED"
        pass-count: pass-count + 1
    ][
        print "❌ FAILED"
        fail-count: fail-count + 1
        unless return-pass? [print "    Return value mismatch!"]
        unless state-pass? [print "    State mismatch!"]
    ]
]

; === TEST CASES ===
print "===== STARTING TAKE VALIDATION ====="

; 1. BASIC BEHAVIOR
test "Take first from block" [
    blk: [apple banana cherry]
] [take blk] 'apple [banana cherry]

test "Take first char from string" [
    str: "Rebol"
] [take str] #"R" "ebol"

test "Take from empty block" [
    empty-blk: copy []
] [take empty-blk] none []

; 2. /LAST REFINEMENT
test "/LAST with block" [
    blk: [x y z]
] [take/last blk] 'z [x y]

test "/LAST with string" [
    str: "Hello"
] [take/last str] #"o" "Hell"

; 3. /PART REFINEMENT
test "/PART with count (block)" [
    blk: [1 2 3 4 5]
] [take/part blk 2] [1 2] [3 4 5]

test "/PART with position marker" [
    str: "documentation"
    mark: find str "c"  ; Position at "cumentation"
] [take/part str mark] "do" "cumentation"

test "/PART with /LAST" [
    blk: [a b c d e]
] [take/part/last blk 2] [d e] [a b c]

; 4. /DEEP REFINEMENT (Fixed)
test "/DEEP nested block" [
    blk: [outer [inner value] end]
] [take/deep next blk] [inner value] [outer end]

; 5. /ALL REFINEMENT
test "/ALL with block" [
    blk: [alpha beta gamma]
] [take/all blk] [alpha beta gamma] []

test "/ALL with string" [
    str: "text"
] [take/all str] "text" ""

; 6. EDGE CASES
test "Take from none" [
    ; No setup needed
] [take none] none none

test "Over-length take" [
    blk: [single]
] [take/part blk 3] [single] []

test "Modified series view" [
    orig: [1 2 3 4]
    view: next orig  ; [2 3 4]
] [take view] 2 [1 3 4]

; === SUMMARY REPORT ===
print rejoin [
    "^/===== VALIDATION SUMMARY ====="
    "^/TOTAL TESTS: " pass-count + fail-count
    "^/PASSED: " pass-count
    "^/FAILED: " fail-count
]

either fail-count > 0 [
    print "^/!!! INVESTIGATION REQUIRED !!!"
][
    print "^/ALL BEHAVIORS VALIDATED"
]
