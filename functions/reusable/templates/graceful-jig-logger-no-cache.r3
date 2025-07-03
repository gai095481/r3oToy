REBOL [
    Title: "Custom Log File Entry Generator"
    Date: 20-Jul-2024
    Author: "Rebol Expert"
    Purpose: {
        Demonstrates using a template resolver to create structured,
        human-readable log file entries from application event data.
    }
]

;;-----------------------------------------------------------------------------
;; 1. The Proven Template Resolution System
;;    (Copied from the provided, working script)
;;-----------------------------------------------------------------------------

;; Global formatter function with comprehensive type handling
template-formatter: function [
    "Format values for template output with specialized handling per datatype."
    value [any-type!]
    return: [string!]
][
    case [
        tuple? value [mold value]
        date? value [mold value]
        block? value [mold value]
        percent? value [form round/to value 0.01]
        money? value [rejoin ["$" form round/to value 0.01]]
        pair? value [
            rejoin [
                either value/x = to integer! value/x [form to integer! value/x][form value/x]
                "x"
                either value/y = to integer! value/y [form to integer! value/y][form value/y]
            ]
        ]
        time? value [
            rejoin [
                next form 100 + value/hour ":"
                next form 100 + value/minute ":"
                next form 100 + to-integer value/second
                either value/second > to-integer value/second [
                    rejoin ["." next form 1000 + to-integer (value/second - to-integer value/second) * 1000]
                ][
                    ""
                ]
            ]
        ]
        file? value [mold value]
        email? value [form value]
        url? value [mold value]
        true [form value]
    ]
]

;; The core resolver function
resolve-template-var: function [
    {Graceful template resolver for popular Rebol datatypes.}
    fld-name [string!] "The field name to resolve (without the 'template-' prefix.)"
    return: [string!] "The resolved value or an informative placeholder."
][
    full-fld-name: rejoin ["template-" fld-name]
    template-word: to-word full-fld-name

    set/any 'bind-result try [bind template-word system/contexts/user]

    either error? bind-result [
        rejoin ["{{" fld-name " - ~UNDEFINED~}}"]
    ][
        set/any 'resolved-value try [get bind-result]

        either error? resolved-value [
            rejoin ["{{" fld-name " - ~UNDEFINED~}}"]
        ][
            either none? resolved-value [
                rejoin ["{{" fld-name " - ~NONE~}}"]
            ][
                template-formatter resolved-value
            ]
        ]
    ]
]

;;-----------------------------------------------------------------------------
;; 2. The Custom Logging Implementation
;;-----------------------------------------------------------------------------
print "--- Generating Structured Log Entries ---"

; This is our log entry format. It uses the same {{...}} placeholders.
log-template: "[{{timestamp}}] [{{level}}] User: {{user-email}} | Status: {{status-code}} | Success: {{success}} | Event: {{event-msg}} | Details: {{details}}"

; This is our main logging function. It takes an object containing the
; details of a single event and uses the template to format a log string.
log-event: function [
    "Creates a formatted log string from an event object."
    event-object [object!]
][
    ; To use the resolver, we need to set the global 'template-*' variables
    ; from the fields in our event object.
    set 'template-timestamp now
    set 'template-level event-object/level
    set 'template-user-email event-object/user-email
    set 'template-status-code event-object/status-code
    set 'template-success event-object/success
    set 'template-event-msg event-object/event-msg

    ; Handle optional fields gracefully. If 'details' doesn't exist in the
    ; object, we unset the global variable so the resolver shows UNDEFINED.
    either find event-object 'details [
        set 'template-details event-object/details
    ][
        if value? 'template-details [unset 'template-details]
    ]

    ; Generic template processor (simplified for this use case)
    result: copy log-template
    foreach word [timestamp level user-email status-code success event-msg details] [
        placeholder: rejoin ["{{" word "}}"]
        replace/all result placeholder (resolve-template-var form word)
    ]

    result
]


;;-----------------------------------------------------------------------------
;; 3. Simulating Application Events and Logging Them
;;-----------------------------------------------------------------------------
; Let's create a few simulated application events as objects.
event-1: make object! [
    level: 'INFO
    user-email: user1@example.com
    status-code: 200
    success: true
    event-msg: "User login successful."
]

event-2: make object! [
    level: 'ERROR
    user-email: user2@example.com
    status-code: 503
    success: false
    event-msg: "Database connection failed."
    details: "Timeout after 3000ms"
]

event-3: make object! [
    level: 'WARN
    user-email: admin@example.com
    status-code: 404
    success: false
    event-msg: "Configuration file not found."
    details: %/etc/app/prod.cfg
]

; Now, we process each event and print the resulting log entry.
; In a real application, we would `write/append %app.log log-string`.
print "--- Application Log ---"
print log-event event-1
print log-event event-2
print log-event event-3
print "--- End of Log ---"
