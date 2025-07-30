REBOL []

;;=============================================================================
;; Purpose:
;;     Retrieve a specific data field from a haystack string based on a single or
;;     multi-character delimiter.
;;
;; Arguments:
;;     - haystack [string!] "The input string to parse."
;;     - delimiter [string!] "The single or multi-character field delimiter."
;;     - field-number [integer!] "The 1-based index of the field to retrieve."
;;
;; Returns:
;;     - [string!] The value of the specified field.
;;     - [none!] An error object if the field cannot be found.
;;     - [error!] An error object if the input is invalid.
;;
;; Notes:
;;     - This function provides robust error handling for common issues.
;;=============================================================================
getstrfld: funct [
    haystack [string! none!]
    delimiter [string! none!]
    field-number [integer!]
] [
    ;; Input validation:
    if none? haystack [return make error! "getstrfld: arg `haystack` cannot be `none`."]
    if none? delimiter [return make error! "getstrfld: arg `delimiter` cannot be `none`."]

    if not empty? haystack [
        if (field-number < 1) [return make error! "Field number must be a positive integer."]
        if empty? delimiter [return make error! "getstrfld: arg `delimiter` cannot be empty."]

        ;;; Split the string into a block and retrieve the field:
        blk-fields: split haystack delimiter

        if field-number > length? blk-fields [
            return make error! "getstrfld: arg `field-number` is out of bounds."
        ]

        ;; Retrieve the specified field:
        return pick blk-fields field-number
    ]

    return none
]

;;=============================================================================
;; Test Harness
;;=============================================================================
assert-equal: funct [
    expected
    actual
    description
] [
    either expected = actual [
        print ["✅ PASS:" description]
    ] [
        print ["❌ FAIL:" description]
        print ["    Expected:" mold expected]
        print ["    Actual:  " mold actual]
    ]
]

assert-error: funct [
    block-to-try
    description
] [
    set/any 'result try block-to-try
    either error? result [
        print ["✅ PASS:" description]
    ] [
        print ["❌ FAIL:" description]
        print ["    Expected: ERROR!"]
        print ["    Actual:  " mold result]
    ]
]

print "^/--- QA Testing `getstrfld` ---"

;;--- Success Test Cases ---
assert-equal "one" getstrfld "one" "<|>" 1 "Retrieve the first populated data field, no delimiter in haystack."

assert-equal "one" getstrfld "one<|>two<|>three" "<|>" 1 "Retrieve the first populated data field."
assert-equal "" getstrfld "<|>two<|>three" "<|>" 1 "Retrieve the first empty data field."

assert-equal "two" getstrfld "one<|>two<|>three" "<|>" 2 "Retrieve the middle populated data field."
assert-equal "" getstrfld "a<|><|>c" "<|>" 2 "Retrieve the empty middle data field."

assert-equal "three" getstrfld "one<|>two<|>three" "<|>" 3 "Retrieve the last populated data field."
assert-equal "trailing" getstrfld "field-1<|>trailing" "<|>" 2 "Retrieve the trailing populated data field."
assert-equal "" getstrfld "one<|>two<|>" "<|>" 3 "Retrieve the last empty data field."

assert-equal none getstrfld "" "<|>" 1 "Empty haystack condition."

assert-equal "apple" getstrfld "apple,banana,cherry" "," 1 "Use a single character delimiter."
assert-equal "banana" getstrfld "apple,banana,cherry" "," 2 "Use a single character delimiter."
assert-equal "cherry" getstrfld "apple,banana,cherry" "," 3 "Use a single character delimiter."

;;--- Error Test Cases ---
assert-error [getstrfld "a<|>b" "<|>" 3] "Field number out of bounds."
assert-error [getstrfld "a<|>b" "<|>" 0] "Field number is zero."
assert-error [getstrfld "a<|>b" "<|>" -1] "Field number is negative."
assert-error [getstrfld "a<|>b" "" 1] "Empty delimiter."
