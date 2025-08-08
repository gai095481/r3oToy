## Recycling Helper (Windows)

- File: `file_folders/recycle/recycler.r3`
- Purpose: Shell out to PowerShell to send a file to the Recycle Bin.

### `recycle-item`
- Signature:
  ```rebol
  recycle-item item [file!] /dry-run
  ```
- Description: Builds and executes a PowerShell command that calls `Send-ToRecycleBin.ps1` with a path. Returns via side-effects (prints) and exit code from `call/wait`.

### Usage
```rebol
; Configure script path (edit the file):
ps-script-path: %/path/to/your/Send-ToRecycleBin.ps1

; Load and call
do %file_folders/recycle/recycler.r3
recycle-item %"C:\\Path\\To\\File.txt"
recycle-item/dry-run %"C:\\Path\\To\\File.txt"
```

Notes:
- Windows-specific. Requires PowerShell and a compatible `Send-ToRecycleBin.ps1` script.
- Consider error-handling or wrapping return codes for integration.