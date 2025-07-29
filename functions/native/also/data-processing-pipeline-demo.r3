Rebol [
    Title: "Data Stream Processing with Logging using `also` - Oldes Branch Demo"
    Description: {
        Demonstrates using the `also` function to log intermediate
        steps in a data processing pipeline without disrupting the flow.
        It adheres to the coding standards of the Oldes branch of Rebol 3.
    }
    Version: 1.5.0
    Date: 30-Jul-2025
    Author: "DeepSeek R1"
]

; --- Helper Functions ---

log-message: function [
    {Logs a timestamped message to console.}
    message [string!]
][
    print [now/precise "-" message]
]

log-data: function [
    {Logs timestamped data with descriptive label.}
    label [string!]
    data [any-type!]
][
    print [now/precise "-" label ":" mold data]
]

; --- Core Data Processing Functions ---
fetch-data: does [
    log-message "Fetching raw data..."
    [
        [name "Alice" score 85]
        [name "Bob" score 92]
        [name "Charlie" score 78]
        [name "Diana" score 96]
    ]
]

filter-high-scores: function [
    {Filters data to records with scores > 80.}
    data [block!]
][
    log-message "Filtering data for high scores (score > 80)..."
    also
        collect [
            foreach item data [
                all [
                    block? item
                    score: select item 'score
                    integer? score
                    score > 80
                    keep/only item
                ]
            ]
        ]
        log-message "Filtering complete."
]

add-grades: function [
    {Adds grade field to each record.}
    data [block!]
][
    log-message "Adding grades to filtered data..."
    also
        collect [
            foreach item data [
                if block? item [
                    score: select item 'score
                    grade: case [
                        score >= 90 ["A"]
                        score >= 80 ["B"]
                        score >= 70 ["C"]
                        true ["F"]
                    ]
                    new-item: copy item
                    append new-item reduce ['grade grade]
                    keep/only new-item
                ]
            ]
        ]
        log-message "Grades added."
]

calculate-average: function [
    {Calculates average score.}
    data [block!]
][
    log-message "Calculating average score..."
    if (length? data) = 0 [
        log-message "No data to calculate average."
        return 0.0
    ]

    total: 0
    count: 0
    foreach item data [
        all [
            block? item
            score: select item 'score
            integer? score
            total: total + score
            count: count + 1
        ]
    ]

    either count > 0 [
        average: to decimal! total / count
        also
            average
            log-message rejoin ["Average score calculated: " mold average]
    ][
        log-message "No valid scores found for average calculation."
        0.0
    ]
]

; --- Main Execution ---
main: does [
    print "=== Data Processing Pipeline Demo ===^/"

    ; Single call to fetch-data with efficient logging
    processed-data: do [
        temp: fetch-data
        also temp log-data "Raw data" temp
    ]

    processed-data: do [
        temp: filter-high-scores processed-data
        also temp log-data "Filtered data" temp
    ]

    processed-data: do [
        temp: add-grades processed-data
        also temp log-data "Graded data" temp
    ]

    avg: calculate-average processed-data

    print "^/=== Final Results ==="
    print ["Processed Data:" mold processed-data]
    print ["Average Score:" avg]
    print "^/Demo finished."
]

main
