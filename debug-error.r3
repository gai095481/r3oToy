REBOL [Title: "Debug Error Object"]

test-err: make error! [type: 'script id: 'my-test-id arg1: "Testing"]

probe test-err

probe test-err/id
