Rebol []

;;==== Revised ANSI Style System ====
;; Base text styles (non-bold, optimized for readability)
gbl-map-text-opts: make map! [
    plain:         ""                      ;; plain text without hue or style.
    alert:         "^[[97;101m"            ;; White text on bright red background.
    beige:         "^[[38;2;255;228;196m"  ;; Light beige / tan.
    blue:          "^[[94m"                ;; Dark blue.
    brown:         "^[[38;2;165;107;70m"   ;; Darker brown for better readability.
    conceal:       "^[[8m"                 ;; Concealed / hidden / invisible text.
    cyan:          "^[[96m"                ;; Bright cyan / green.
    dim:           "^[[90m"                ;; Bright black (dark gray / charcoal).
    dingy:         "^[[38;2;200;200;200m"  ;; Dingy white.
    gold:          "^[[38;2;255;205;40m"   ;; Dark yellow.
    green:         "^[[92m"                ;; Grass green.
    ivory:         "^[[38;2;255;255;240m"  ;; Bright white.
    khaki:         "^[[38;2;179;179;126m"  ;; Medium khaki (tannish brown).
    mint:          "^[[38;2;100;136;116m"  ;; Dim mint green.
    orange:        "^[[38;2;255;150;10m"   ;; Vibrant orange.
    papaya:        "^[[38;2;255;80;37m"    ;; Bright papaya (reddish orange).
    pink:          "^[[38;2;255;164;200m"  ;; Soft pink.
    purple:        "^[[95m"                ;; Dark purple / violet.
    tanner:        "^[[38;2;142;128;110m"  ;; tanner color.
    red:           "^[[91m"                ;; Bright red.
    sky:           "^[[38;2;164;200;255m"  ;; Light sky blue.
    warn:          "^[[93m^[[7m"           ;; Black text on yellow background.
    wheat:         "^[[38;2;245;222;129m"  ;; Medium yellow.
    yellow:        "^[[93m"                ;; Bright yellow.
]

;; ANSI control codes:
as-plain:        "^[[0m"      ;; Reset back to no color or style; just plain text again.

;; Text style modifiers:
as-blink:        "^[[5m"      ;; Blinking text.
as-bold:         "^[[1m"      ;; Bold / bright text.
as-inverted:     "^[[7m"      ;; Inverted / background color.
as-struck:       "^[[9m"      ;; Strikethrough text.
as-underlined:   "^[[4m"      ;; Underlined text.

;; Unified text styler function:
stylize: function [
    {Apply a named base color with optional style modifiers to the text value.}
    text-hue [word! none!] "Name of the base color (e.g., 'blue, 'green)."
    the-text-to-stylize [any-type!] "Text / value to stylize."
    /blink         "Add the text blink effect."
    /bold          "Make the text bold."
    /invert        "Invert foreground / background."
    /struck        "Strike-through the text."
    /underlined    "Underline text."
][
    base: select gbl-map-text-opts text-hue

    if none? base [
        print rejoin ["❌ stylize: UNRECOGNIZED COLOR / STYLE> " text-hue]
        print rejoin ["Valid styles are: " keys-of gbl-map-text-opts]
        return the-text-to-stylize
    ]

    ;; Apply possible modifiers in a consistent order:
    modifiers: copy base

    case/all [
        bold        [append modifiers as-bold]
        underlined  [append modifiers as-underlined]
        invert      [if not text-hue == 'warn [append modifiers as-inverted]]   ;; 'warn has the invert ANSI code, it doesn't need it again.
        blink       [append modifiers as-blink]
        struck      [append modifiers as-struck]
    ]

    ;; Return styled text with reset-to-plain text ANSI code:
    return rejoin [modifiers the-text-to-stylize as-plain]
]

;;-----------------------------------------------------------
hue-datatype: function [
    {Assign colors to datatypes to print them.}
    the-datatype-to-colorize [any-type!]
][
    result: none

    ;; the `/word` refinement with `type?` lets us use the syntax: `decimal!` instead of `#(decimal!)`
    result: switch/default type?/word the-datatype-to-colorize [
        decimal! [stylize 'ivory the-datatype-to-colorize]
        integer! [stylize 'ivory the-datatype-to-colorize]
        string! [stylize 'beige the-datatype-to-colorize]
        block! [stylize 'blue the-datatype-to-colorize]
        map! [stylize 'mint the-datatype-to-colorize]
        word! [stylize 'wheat the-datatype-to-colorize]
        date! [stylize 'brown the-datatype-to-colorize]
        time! [stylize 'sky the-datatype-to-colorize]
        file! [stylize  'cyan the-datatype-to-colorize]
        error! [stylize  'alert the-datatype-to-colorize]
        email! [stylize 'pink the-datatype-to-colorize]
        hash! [stylize 'dim the-datatype-to-colorize]
        char! [stylize 'gold the-datatype-to-colorize]
        logic! [stylize 'purple the-datatype-to-colorize]
        pair! [stylize 'khaki the-datatype-to-colorize]
        tuple! [stylize 'tanner the-datatype-to-colorize]
        url! [stylize 'pink the-datatype-to-colorize]
        money! [stylize 'green the-datatype-to-colorize]
        binary! [stylize 'orange the-datatype-to-colorize]
        none! [stylize 'dim the-datatype-to-colorize]
    ][
        ;; Default case only for unhandled types
        stylize 'plain the-datatype-to-colorize
    ]

    return result
]


;; ===== Usage Examples =====
print rejoin [stylize/blink 'alert "blink alert"]
print rejoin [stylize/bold 'alert "bold alert"]
print rejoin [stylize/struck 'alert "struck alert"]
print rejoin [stylize/underlined 'alert "underlined alert"]
prin newline

print rejoin [stylize/blink 'warn "blink warn"]
print rejoin [stylize/bold 'warn "bold warn"]
print rejoin [stylize/struck 'warn "struck warn"]
print rejoin [stylize/underlined 'warn "underlined warn"]
prin newline

print rejoin [stylize/blink 'sky "blink sky"]
print rejoin [stylize/bold 'sky "bold sky"]
print rejoin [stylize/invert 'sky "invert sky"]
print rejoin [stylize 'sky "regular sky"]
print rejoin [stylize/struck 'sky "struck sky"]
print rejoin [stylize/underlined 'sky "underlined sky"]
prin newline

print rejoin [stylize/blink 'blue "blink blue"]
print rejoin [stylize/bold 'blue "bold blue"]
print rejoin [stylize/invert 'blue "invert blue"]
print rejoin [stylize 'blue "regular blue"]
print rejoin [stylize/struck 'blue "struck blue"]
print rejoin [stylize/underlined 'blue "underlined blue"]
prin newline

print rejoin [stylize/blink 'red "blink red"]
print rejoin [stylize/bold 'red "bold red"]
print rejoin [stylize/invert 'red "invert red"]
print rejoin [stylize 'red "regular red"]
print rejoin [stylize/struck 'red "struck red"]
print rejoin [stylize/underlined 'red "underlined red"]
prin newline

print rejoin [stylize/blink 'papaya "blink papaya"]
print rejoin [stylize/bold 'papaya "bold papaya"]
print rejoin [stylize/invert 'papaya "invert papaya"]
print rejoin [stylize 'papaya "regular papaya"]
print rejoin [stylize/struck 'papaya "struck papaya"]
print rejoin [stylize/underlined 'papaya "underlined papaya"]
prin newline

print rejoin [stylize/blink 'yellow "blink yellow"]
print rejoin [stylize/bold 'yellow "bold yellow"]
print rejoin [stylize/invert 'yellow "invert yellow"]
print rejoin [stylize 'yellow "regular yellow"]
print rejoin [stylize/struck 'yellow "struck yellow"]
print rejoin [stylize/underlined 'yellow "underlined yellow"]
prin newline

print rejoin [stylize/blink 'wheat "blink wheat"]
print rejoin [stylize/bold 'wheat "bold wheat"]
print rejoin [stylize/invert 'wheat "invert wheat"]
print rejoin [stylize 'wheat "regular wheat"]
print rejoin [stylize/struck 'wheat "struck wheat"]
print rejoin [stylize/underlined 'wheat "underlined wheat"]
prin newline

print rejoin [stylize/blink 'gold "blink gold"]
print rejoin [stylize/bold 'gold "bold gold"]
print rejoin [stylize/invert 'gold "invert gold"]
print rejoin [stylize 'gold "regular gold"]
print rejoin [stylize/struck 'gold "struck gold"]
print rejoin [stylize/underlined 'gold "underlined gold"]
prin newline

print rejoin [stylize/blink 'green "blink green"]
print rejoin [stylize/bold 'green "bold green"]
print rejoin [stylize/invert 'green "invert green"]
print rejoin [stylize 'green "regular green"]
print rejoin [stylize/struck 'green "struck green"]
print rejoin [stylize/underlined 'green "underlined green"]
prin newline

print rejoin [stylize/blink 'cyan "blink cyan"]
print rejoin [stylize/bold 'cyan "bold cyan"]
print rejoin [stylize/invert 'cyan "invert cyan"]
print rejoin [stylize 'cyan "regular cyan"]
print rejoin [stylize/struck 'cyan "struck cyan"]
print rejoin [stylize/underlined 'cyan "underlined cyan"]
prin newline

print rejoin [stylize/blink 'mint "blink mint"]
print rejoin [stylize/bold 'mint "bold mint"]
print rejoin [stylize/invert 'mint "invert mint"]
print rejoin [stylize 'mint "regular mint"]
print rejoin [stylize/struck 'mint "struck mint"]
print rejoin [stylize/underlined 'mint "underlined mint"]
prin newline

print rejoin [stylize/blink 'ivory "blink ivory"]
print rejoin [stylize/bold 'ivory "bold ivory"]
print rejoin [stylize/invert 'ivory "invert ivory"]
print rejoin [stylize 'ivory "regular ivory"]
print rejoin [stylize/struck 'ivory "struck ivory"]
print rejoin [stylize/underlined 'ivory "underlined ivory"]
prin newline

print rejoin [stylize/blink 'dingy "blink dingy"]
print rejoin [stylize/bold 'dingy "bold dingy"]
print rejoin [stylize/invert 'dingy "invert dingy"]
print rejoin [stylize 'dingy "regular dingy"]
print rejoin [stylize/struck 'dingy "struck dingy"]
print rejoin [stylize/underlined 'dingy "underlined dingy"]
prin newline

print rejoin [stylize/blink 'orange "blink orange"]
print rejoin [stylize/bold 'orange "bold orange"]
print rejoin [stylize/invert 'orange "invert orange"]
print rejoin [stylize 'orange "regular orange"]
print rejoin [stylize/struck 'orange "struck orange"]
print rejoin [stylize/underlined 'orange "underlined orange"]
prin newline

print rejoin [stylize/blink 'khaki "blink khaki"]
print rejoin [stylize/bold 'khaki "bold khaki"]
print rejoin [stylize/invert 'khaki "invert khaki"]
print rejoin [stylize 'khaki "regular khaki"]
print rejoin [stylize/struck 'khaki "struck khaki"]
print rejoin [stylize/underlined 'khaki "underlined khaki"]
prin newline

print rejoin [stylize/blink 'tanner "blink tanner"]
print rejoin [stylize/bold 'tanner "bold tanner"]
print rejoin [stylize/invert 'tanner "invert tanner"]
print rejoin [stylize 'tanner "regular tanner"]
print rejoin [stylize/struck 'tanner "struck tanner"]
print rejoin [stylize/underlined 'tanner "underlined tanner"]
prin newline

print rejoin [stylize/blink 'beige "blink beige"]
print rejoin [stylize/bold 'beige "bold beige"]
print rejoin [stylize/invert 'beige "invert beige"]
print rejoin [stylize 'beige "regular beige"]
print rejoin [stylize/struck 'beige "struck beige"]
print rejoin [stylize/underlined 'beige "underlined beige"]
prin newline

print rejoin [stylize/blink 'brown "blink brown"]
print rejoin [stylize/bold 'brown "bold brown"]
print rejoin [stylize/invert 'brown "invert brown"]
print rejoin [stylize 'brown "regular brown"]
print rejoin [stylize/struck 'brown "struck brown"]
print rejoin [stylize/underlined 'brown "underlined brown"]
prin newline

print rejoin [stylize/blink 'pink "blink pink"]
print rejoin [stylize/bold 'pink "bold pink"]
print rejoin [stylize/invert 'pink "invert pink"]
print rejoin [stylize 'pink "regular pink"]
print rejoin [stylize/struck 'pink "struck pink"]
print rejoin [stylize/underlined 'pink "underlined pink"]
prin newline

print rejoin [stylize/blink 'purple "blink purple"]
print rejoin [stylize/bold 'purple "bold purple"]
print rejoin [stylize/invert 'purple "invert purple"]
print rejoin [stylize 'purple "regular purple"]
print rejoin [stylize/struck 'purple "struck purple"]
print rejoin [stylize/underlined 'purple "underlined purple"]
prin newline

print rejoin [stylize/blink 'dim "blink dim"]
print rejoin [stylize/bold 'dim "bold dim"]
print rejoin [stylize/invert 'dim "invert dim"]
print rejoin [stylize 'dim "regular dim"]
print rejoin [stylize/struck 'dim "struck dim"]
print rejoin [stylize/underlined 'dim "underlined dim"]
prin newline

;; Combine all style modifiers:
print rejoin [stylize/blink/bold/invert/struck/underlined 'dim "blink, bold, invert, struck, underlined dim"]

;; stylize a map's keys:
print rejoin [stylize/bold 'dim keys-of gbl-map-text-opts]

;; Conceal a portion of text:
name: "Johnny"
print rejoin ["Welcome: Mr." stylize/invert 'conceal name "to the club!"]

print lf
some-string: "John Smith"
print hue-datatype some-string

some-decimal: 9.99
print hue-datatype some-decimal

some-int: 1
print hue-datatype some-int

some-block: [1 "a" 8.9]
print hue-datatype some-block

some-date: 2025-06-29
print hue-datatype some-date

some-email: john@somewhere.com
print hue-datatype some-email

some-URL: https://website.com
print hue-datatype some-URL

some-time: now/time
print hue-datatype some-time
