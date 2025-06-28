Rebol []

;;==== ANSI Style Lookup Hash Map ====
gbl-map-text-opts: make map! [
    alert:         "^[[97;101m"            ;; White text on bright red background.
    beige:         "^[[38;2;255;228;196m"  ;; Light beige / tan.
    blue:          "^[[94m"                ;; Dark blue.
    brown:         "^[[38;2;165;107;70m"   ;; Darker brown for better readability.
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
    tanner:       "^[[38;2;142;128;110m"   ;; tanner color.
    red:           "^[[91m"                ;; Bright red.
    sky:           "^[[38;2;164;200;255m"  ;; Light sky blue.
    warn:          "^[[93m^[[7m"           ;; Black text on yellow background.
    wheat:         "^[[38;2;245;222;129m"  ;; Medium yellow.
    yellow:        "^[[93m"                ;; Bright yellow.
]

;; ANSI control codes:
as-plain:        "^[[0m"    ; Reset all styles
as--alert:       "^[[97;101m" ; White text on bright red background

;; Text style modifiers:
as-blink:        "^[[5m"     ;; Blinking text.
as-bold:         "^[[1m"     ;; Bold/bright text.
as-inverted:     "^[[7m"     ;; Inverted colors.
as-hide:         "^[[8m"     ;; Hidden text.
as-strike-thru:  "^[[9m"     ;; Strikethrough text.
as-underline:    "^[[4m"     ;; Underlined text.

;; Unified text styler function:
stylize: function [
    {Apply a named style with optional modifiers to the text value}
    style [word! none!] "Name of the base color (e.g., 'blue, 'green)"
    value [any-type!] "Text / value to stylize."
    /blink         "Add blink effect."
    /bold          "Make text bold."
    /hide          "Hide text (security)."
    /invert        "Invert foreground/background"
    /strike        "Add strikethrough"
    /underline     "Underline text"
][
    base: select gbl-map-text-opts style

    either none? base [
        print rejoin ["❌ stylize: UNRECOGNIZED BASE STYLE> " style]
        print rejoin ["Valid styles are: " keys-of gbl-map-text-opts]
    ]
    [
        ;; Apply possible modifiers in a consistent order:
        modifiers: copy select gbl-map-text-opts style
        ;probe modifiers

        either hide [  [append modifiers as-hide] ][
            if bold      [append modifiers as-bold]
            if underline [append modifiers as-underline]
            if invert    [append modifiers as-inverted]
            if blink     [append modifiers as-blink]
            if strike    [append modifiers as-strike-thru]
        ]

        ;; Handle cases where the base might be empty:
        if not base [base: copy ""]

        ;; Return styled value with reset code:
        return rejoin [base modifiers value as-plain]
    ]
]

;; ===== Usage Examples =====
print rejoin [stylize/blink 'alert "blink alert"]
print rejoin [stylize/bold 'alert "bold alert"]
print rejoin [stylize/strike 'alert "strike alert"]
print rejoin [stylize/underline 'alert "underline alert"]
prin newline

print rejoin [stylize/blink 'warn "blink warn"]
print rejoin [stylize/bold 'warn "bold warn"]
print rejoin [stylize/strike 'warn "strike warn"]
print rejoin [stylize/underline 'warn "underline warn"]
prin newline

print rejoin [stylize/blink 'sky "blink sky"]
print rejoin [stylize/bold 'sky "bold sky"]
print rejoin [stylize/invert 'sky "invert sky"]
print rejoin [stylize 'sky "regular sky"]
print rejoin [stylize/strike 'sky "strike sky"]
print rejoin [stylize/underline 'sky "underline sky"]
prin newline

print rejoin [stylize/blink 'blue "blink blue"]
print rejoin [stylize/bold 'blue "bold blue"]
print rejoin [stylize/invert 'blue "invert blue"]
print rejoin [stylize 'blue "regular blue"]
print rejoin [stylize/strike 'blue "strike blue"]
print rejoin [stylize/underline 'blue "underline blue"]
prin newline

print rejoin [stylize/blink 'red "blink red"]
print rejoin [stylize/bold 'red "bold red"]
print rejoin [stylize/invert 'red "invert red"]
print rejoin [stylize 'red "regular red"]
print rejoin [stylize/strike 'red "strike red"]
print rejoin [stylize/underline 'red "underline red"]
prin newline

print rejoin [stylize/blink 'papaya "blink papaya"]
print rejoin [stylize/bold 'papaya "bold papaya"]
print rejoin [stylize/invert 'papaya "invert papaya"]
print rejoin [stylize 'papaya "regular papaya"]
print rejoin [stylize/strike 'papaya "strike papaya"]
print rejoin [stylize/underline 'papaya "underline papaya"]
prin newline

print rejoin [stylize/blink 'yellow "blink yellow"]
print rejoin [stylize/bold 'yellow "bold yellow"]
print rejoin [stylize/invert 'yellow "invert yellow"]
print rejoin [stylize 'yellow "regular yellow"]
print rejoin [stylize/strike 'yellow "strike yellow"]
print rejoin [stylize/underline 'yellow "underline yellow"]
prin newline

print rejoin [stylize/blink 'wheat "blink wheat"]
print rejoin [stylize/bold 'wheat "bold wheat"]
print rejoin [stylize/invert 'wheat "invert wheat"]
print rejoin [stylize 'wheat "regular wheat"]
print rejoin [stylize/strike 'wheat "strike wheat"]
print rejoin [stylize/underline 'wheat "underline wheat"]
prin newline

print rejoin [stylize/blink 'gold "blink gold"]
print rejoin [stylize/bold 'gold "bold gold"]
print rejoin [stylize/invert 'gold "invert gold"]
print rejoin [stylize 'gold "regular gold"]
print rejoin [stylize/strike 'gold "strike gold"]
print rejoin [stylize/underline 'gold "underline gold"]
prin newline

print rejoin [stylize/blink 'green "blink green"]
print rejoin [stylize/bold 'green "bold green"]
print rejoin [stylize/invert 'green "invert green"]
print rejoin [stylize 'green "regular green"]
print rejoin [stylize/strike 'green "strike green"]
print rejoin [stylize/underline 'green "underline green"]
prin newline

print rejoin [stylize/blink 'cyan "blink cyan"]
print rejoin [stylize/bold 'cyan "bold cyan"]
print rejoin [stylize/invert 'cyan "invert cyan"]
print rejoin [stylize 'cyan "regular cyan"]
print rejoin [stylize/strike 'cyan "strike cyan"]
print rejoin [stylize/underline 'cyan "underline cyan"]
prin newline

print rejoin [stylize/blink 'mint "blink mint"]
print rejoin [stylize/bold 'mint "bold mint"]
print rejoin [stylize/invert 'mint "invert mint"]
print rejoin [stylize 'mint "regular mint"]
print rejoin [stylize/strike 'mint "strike mint"]
print rejoin [stylize/underline 'mint "underline mint"]
prin newline

print rejoin [stylize/blink 'ivory "blink ivory"]
print rejoin [stylize/bold 'ivory "bold ivory"]
print rejoin [stylize/invert 'ivory "invert ivory"]
print rejoin [stylize 'ivory "regular ivory"]
print rejoin [stylize/strike 'ivory "strike ivory"]
print rejoin [stylize/underline 'ivory "underline ivory"]
prin newline

print rejoin [stylize/blink 'dingy "blink dingy"]
print rejoin [stylize/bold 'dingy "bold dingy"]
print rejoin [stylize/invert 'dingy "invert dingy"]
print rejoin [stylize 'dingy "regular dingy"]
print rejoin [stylize/strike 'dingy "strike dingy"]
print rejoin [stylize/underline 'dingy "underline dingy"]
prin newline

print rejoin [stylize/blink 'orange "blink orange"]
print rejoin [stylize/bold 'orange "bold orange"]
print rejoin [stylize/invert 'orange "invert orange"]
print rejoin [stylize 'orange "regular orange"]
print rejoin [stylize/strike 'orange "strike orange"]
print rejoin [stylize/underline 'orange "underline orange"]
prin newline

print rejoin [stylize/blink 'khaki "blink khaki"]
print rejoin [stylize/bold 'khaki "bold khaki"]
print rejoin [stylize/invert 'khaki "invert khaki"]
print rejoin [stylize 'khaki "regular khaki"]
print rejoin [stylize/strike 'khaki "strike khaki"]
print rejoin [stylize/underline 'khaki "underline khaki"]
prin newline

print rejoin [stylize/blink 'tanner "blink tanner"]
print rejoin [stylize/bold 'tanner "bold tanner"]
print rejoin [stylize/invert 'tanner "invert tanner"]
print rejoin [stylize 'tanner "regular tanner"]
print rejoin [stylize/strike 'tanner "strike tanner"]
print rejoin [stylize/underline 'tanner "underline tanner"]
prin newline

print rejoin [stylize/blink 'beige "blink beige"]
print rejoin [stylize/bold 'beige "bold beige"]
print rejoin [stylize/invert 'beige "invert beige"]
print rejoin [stylize 'beige "regular beige"]
print rejoin [stylize/strike 'beige "strike beige"]
print rejoin [stylize/underline 'beige "underline beige"]
prin newline

print rejoin [stylize/blink 'brown "blink brown"]
print rejoin [stylize/bold 'brown "bold brown"]
print rejoin [stylize/invert 'brown "invert brown"]
print rejoin [stylize 'brown "regular brown"]
print rejoin [stylize/strike 'brown "strike brown"]
print rejoin [stylize/underline 'brown "underline brown"]
prin newline

print rejoin [stylize/blink 'pink "blink pink"]
print rejoin [stylize/bold 'pink "bold pink"]
print rejoin [stylize/invert 'pink "invert pink"]
print rejoin [stylize 'pink "regular pink"]
print rejoin [stylize/strike 'pink "strike pink"]
print rejoin [stylize/underline 'pink "underline pink"]
prin newline

print rejoin [stylize/blink 'purple "blink purple"]
print rejoin [stylize/bold 'purple "bold purple"]
print rejoin [stylize/invert 'purple "invert purple"]
print rejoin [stylize 'purple "regular purple"]
print rejoin [stylize/strike 'purple "strike purple"]
print rejoin [stylize/underline 'purple "underline purple"]
prin newline

print rejoin [stylize/blink 'dim "blink dim"]
print rejoin [stylize/bold 'dim "bold dim"]
print rejoin [stylize/invert 'dim "invert dim"]
print rejoin [stylize 'dim "regular dim"]
print rejoin [stylize/strike 'dim "strike dim"]
print rejoin [stylize/underline 'dim "underline dim"]
prin newline

;; Combined modifiers:
print rejoin [stylize/blink/bold/invert/strike/underline 'dim "blink, bold, invert, strike, underline dim"]

;; stylize a map's key's:
print rejoin [stylize/bold 'dim keys-of gbl-map-text-opts]
