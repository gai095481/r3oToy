REBOL []

;;=============================================================================
;; WORD BINDING DIAGNOSTIC TESTS
;;=============================================================================
;; Purpose: Understand exactly how word binding works in Rebol 3 Oldes branch
;; Goal: Test our assumptions about contexts, binding, and word resolution
;;=============================================================================

print "=== WORD BINDING DIAGNOSTIC TESTS ==="
print "=== Understanding Context and Binding Behavior ==="

;; Set up some test variables in the global context
test-variable: "I exist in global context"
another-test: 42

print "^/=== TEST 1: Basic Word Creation and Types ==="
;; Let's see what we get when we create words from strings
word-from-string: to-word "test-variable"
print ["Original variable exists:" (get 'test-variable)]
print ["Word created from string:" mold word-from-string]
print ["Type of created word:" type? word-from-string]


print "^/=== TEST 2: What happens with direct GET? ==="
;; Test what happens when we try to GET the word directly
print "Attempting direct GET on word created from string..."
set/any 'direct-result try [get word-from-string]
either error? direct-result [
    print ["Direct GET failed with error:" mold direct-result]
][
    print ["Direct GET succeeded with value:" mold direct-result]
]

print "^/=== TEST 3: Understanding System Contexts ==="
;; Let's explore what contexts are available
print "Available system contexts:"
print ["system/contexts/user exists:" not none? system/contexts/user]

;; Let's see what's actually in the user context
print "^/Probing the user context:"
set/any 'user-context-probe try [system/contexts/user]
either error? user-context-probe [
    print ["Cannot access user context:" mold user-context-probe]
][
    print ["User context type:" type? user-context-probe]
    print ["User context exists and is accessible"]
]

print "^/=== TEST 4: Different Binding Approaches ==="
;; Test different ways to bind words
word-to-bind: to-word "test-variable"

print "Approach 1: Binding to system/contexts/user"
set/any 'bind-result-1 try [bind word-to-bind system/contexts/user]
either error? bind-result-1 [
    print ["Bind to user context failed:" mold bind-result-1]
][
    print ["Bind to user context succeeded"]
    ;; Now try to get the value
    set/any 'get-result-1 try [get bind-result-1]
    either error? get-result-1 [
        print ["GET after binding failed:" mold get-result-1]
    ][
        print ["GET after binding succeeded:" mold get-result-1]
    ]
]

print "^/Approach 2: Using 'in' function instead of 'bind'"
set/any 'in-result try [in system/contexts/user word-to-bind]
either error? in-result [
    print ["Using 'in' function failed:" mold in-result]
][
    print ["Using 'in' function succeeded"]
    set/any 'get-result-2 try [get in-result]
    either error? get-result-2 [
        print ["GET after 'in' failed:" mold get-result-2]
    ][
        print ["GET after 'in' succeeded:" mold get-result-2]
    ]
]

print "^/=== SUMMARY ==="
print "These tests will help us understand:"
print "1. How word creation from strings actually works"
print "2. What contexts are available and accessible"
print "3. Which binding method works in Rebol 3 Oldes"
print "4. The correct pattern for dynamic word resolution"
