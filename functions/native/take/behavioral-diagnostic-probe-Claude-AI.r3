; Diagnostic Probe Script for TAKE function with pass/fail indicators

print "=== Probing TAKE with Blocks ==="

print "Basic take on block:"
data: [a b c d]
probe result: take data  ; Expect: a
probe data               ; Expect: [b c d]
either (result = 'a) and (data = [b c d]) [
    print "✅ PASSED"
] [
    print "❌ FAILED: Basic take on block"
    print ["Expected result: a, Got:" result]
    print ["Expected data: [b c d], Got:" data]
]

print "take/last on block:"
data: [a b c d]
probe result: take/last data  ; Expect: d
probe data                    ; Expect: [a b c]
either (result = 'd) and (data = [a b c]) [
    print "✅ PASSED"
] [
    print "❌ FAILED: take/last on block"
    print ["Expected result: d, Got:" result]
    print ["Expected data: [a b c], Got:" data]
]

print "take/part with number on block:"
data: [a b c d]
probe result: take/part data 2  ; Expect: [a b]
probe data                      ; Expect: [c d]
either (result = [a b]) and (data = [c d]) [
    print "✅ PASSED"
] [
    print "❌ FAILED: take/part with number on block"
    print ["Expected result: [a b], Got:" result]
    print ["Expected data: [c d], Got:" data]
]

print "take/part with series position on block:"
data: [a b c d e]
pos: at data 3  ; [c d e]
probe result: take/part data pos  ; Expect: [a b]
probe data                        ; Expect: [c d e]
either (result = [a b]) and (data = [c d e]) [
    print "✅ PASSED"
] [
    print "❌ FAILED: take/part with series position on block"
    print ["Expected result: [a b], Got:" result]
    print ["Expected data: [c d e], Got:" data]
]

print "take/part/deep on block - checking deep copy:"
data: [a [b c] d]
original-sub: data/2  ; [b c]
taken: take/part/deep data 2  ; Expect: [a [b c]], with [b c] copied
taken/2/1: 99  ; Modify the copy
probe taken  ; Expect: [a [99 c]]
probe original-sub  ; Expect: [b c]
probe data  ; Expect: [d]
either (taken = [a [99 c]]) and (original-sub = [b c]) and (data = [d]) [
    print "✅ PASSED"
] [
    print "❌ FAILED: take/part/deep on block"
    print ["Expected taken: [a [99 c]], Got:" taken]
    print ["Expected original-sub: [b c], Got:" original-sub]
    print ["Expected data: [d], Got:" data]
]

print "take/all on block:"
data: [a b c]
taken: take/all data  ; Expect: [a b c]
probe taken
probe data  ; Expect: []
either (taken = [a b c]) and (data = []) [
    print "✅ PASSED"
] [
    print "❌ FAILED: take/all on block"
    print ["Expected taken: [a b c], Got:" taken]
    print ["Expected data: [], Got:" data]
]

print "take on empty block:"
data: []
probe result: take data  ; Expect: none
either none? result [
    print "✅ PASSED"
] [
    print "❌ FAILED: take on empty block"
    print ["Expected: none, Got:" result]
]

print "take/part on empty block:"
data: []
probe result: take/part data 2  ; Expect: []
either result = [] [
    print "✅ PASSED"
] [
    print "❌ FAILED: take/part on empty block"
    print ["Expected: [], Got:" result]
]

print "take/part with number larger than block length:"
data: [a b]
probe result: take/part data 5  ; Expect: [a b]
probe data                      ; Expect: []
either (result = [a b]) and (data = []) [
    print "✅ PASSED"
] [
    print "❌ FAILED: take/part with number larger than block length"
    print ["Expected result: [a b], Got:" result]
    print ["Expected data: [], Got:" data]
]

print "=== Probing TAKE with Strings ==="

print "Basic take on string:"
str: "abcd"
probe result: take str  ; Expect: #"a"
probe str               ; Expect: "bcd"
either (result = #"a") and (str = "bcd") [
    print "✅ PASSED"
] [
    print "❌ FAILED: Basic take on string"
    print ["Expected result: #""a"", Got:" result]
    print ["Expected str: ""bcd"", Got:" str]
]

print "take/last on string:"
str: "abcd"
probe result: take/last str  ; Expect: #"d"
probe str                    ; Expect: "abc"
either (result = #"d") and (str = "abc") [
    print "✅ PASSED"
] [
    print "❌ FAILED: take/last on string"
    print ["Expected result: #""d"", Got:" result]
    print ["Expected str: ""abc"", Got:" str]
]

print "take/part with number on string:"
str: "abcd"
probe result: take/part str 2  ; Expect: "ab"
probe str                      ; Expect: "cd"
either (result = "ab") and (str = "cd") [
    print "✅ PASSED"
] [
    print "❌ FAILED: take/part with number on string"
    print ["Expected result: ""ab"", Got:" result]
    print ["Expected str: ""cd"", Got:" str]
]

print "take/part with series position on string:"
str: "abcde"
pos: at str 3  ; "cde"
probe result: take/part str pos  ; Expect: "ab"
probe str                        ; Expect: "cde"
either (result = "ab") and (str = "cde") [
    print "✅ PASSED"
] [
    print "❌ FAILED: take/part with series position on string"
    print ["Expected result: ""ab"", Got:" result]
    print ["Expected str: ""cde"", Got:" str]
]

print "take/part/deep on string:"
str: "abcd"
taken: take/part/deep str 2  ; Expect: "ab"
probe taken
probe str  ; Expect: "cd"
either (taken = "ab") and (str = "cd") [
    print "✅ PASSED"
] [
    print "❌ FAILED: take/part/deep on string"
    print ["Expected taken: ""ab"", Got:" taken]
    print ["Expected str: ""cd"", Got:" str]
]

print "take on empty string:"
str: ""
probe result: take str  ; Expect: none
either none? result [
    print "✅ PASSED"
] [
    print "❌ FAILED: take on empty string"
    print ["Expected: none, Got:" result]
]

print "=== Probing TAKE with Binary ==="

print "Basic take on binary:"
bin: #{123456}
probe result: take bin  ; Expect: 18
probe bin               ; Expect: #{3456}
either (result = 18) and (bin = #{3456}) [
    print "✅ PASSED"
] [
    print "❌ FAILED: Basic take on binary"
    print ["Expected result: 18, Got:" result]
    print ["Expected bin: #{3456}, Got:" bin]
]

print "take/last on binary:"
bin: #{123456}
probe result: take/last bin  ; Expect: 86
probe bin                    ; Expect: #{1234}
either (result = 86) and (bin = #{1234}) [
    print "✅ PASSED"
] [
    print "❌ FAILED: take/last on binary"
    print ["Expected result: 86, Got:" result]
    print ["Expected bin: #{1234}, Got:" bin]
]

print "take/part with number on binary:"
bin: #{123456}
probe result: take/part bin 2  ; Expect: #{1234}
probe bin                      ; Expect: #{56}
either (result = #{1234}) and (bin = #{56}) [
    print "✅ PASSED"
] [
    print "❌ FAILED: take/part with number on binary"
    print ["Expected result: #{1234}, Got:" result]
    print ["Expected bin: #{56}, Got:" bin]
]

print "take on empty binary:"
bin: #{}
probe result: take bin  ; Expect: none
either none? result [
    print "✅ PASSED"
] [
    print "❌ FAILED: take on empty binary"
    print ["Expected: none, Got:" result]
]

print "=== Probing TAKE with None ==="

print "take on none:"
probe result: take none  ; Expect: none
either none? result [
    print "✅ PASSED"
] [
    print "❌ FAILED: take on none"
    print ["Expected: none, Got:" result]
]
