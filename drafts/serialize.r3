my-map: make map! [name: "Ford" towels: 1]

;; Serialize the map to a file
set/any 'result try [ save %my-map.dat my-map ]

either error? result [
    print ["Error saving file:" result/id]
][
    ;; Now, load it back
    loaded-map: load %my-map.dat
    print ["Loaded successfully:" loaded-map/name]
]
