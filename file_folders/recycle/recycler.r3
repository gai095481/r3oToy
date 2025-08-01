REBOL []

; Define the path to the PowerShell script
ps-script-path: %/path/to/your/Send-ToRecycleBin.ps1 ; Adjust path as needed

; Define the item(s) to recycle
item-to-recycle: %"C:\Path\To\Your\File_or_Folder.txt" ; Or a Rebol block of paths

; --- Function to call the PS script ---
recycle-item: func [
    "Sends an item to the Recycle Bin using the PS script"
    item [file!] "The path to the item to recycle"
    /dry-run "Perform a dry run"
][
    ; Build the PowerShell command
    ps-command: rejoin [
        {powershell.exe -ExecutionPolicy Bypass -File "} ps-script-path {"}
        { -Path "} item {"}
    ]
    if dry-run [
        append ps-command " -DryRun"
    ]

    print ["Executing command:" ps-command]

    ; Execute the command
    ; Using call/wait ensures the script finishes before Rebol continues
    exit-code: call/wait ps-command

    ; Check the exit code (0 usually means success in PS)
    either zero? exit-code [
        print ["Successfully sent" item "to Recycle Bin (or simulated). Exit code:" exit-code]
    ][
        print ["Error sending" item "to Recycle Bin. Exit code:" exit-code]
        ; You might want to signal an error in Rebol depending on your needs
    ]
]

; --- Call the function ---
recycle-item item-to-recycle
; recycle-item/dry-run item-to-recycle ; For dry run
