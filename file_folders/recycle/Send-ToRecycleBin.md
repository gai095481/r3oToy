# The `Send-ToRecycleBin.ps1` User's Guide

This PowerShell script provides a reliable way to move one or more files or folders to the Windows Recycle Bin from the command line. It is designed to be robust and suitable for calling from other scripts or programs such as Rebol 3 Oldes scripts.

## Requirements

1. **PowerShell:** The script is designed for PowerShell (tested on Windows PowerShell 5.1 and PowerShell 7.x). It uses standard PowerShell cmdlets and .NET methods.
2. **.NET Framework/Runtime:** The script relies on the `Microsoft.VisualBasic` .NET assembly, which is typically included with standard Windows installations and PowerShell environments. It uses classes from this assembly for stable Recycle Bin operations.
3. **Windows OS:** The script is designed for Windows, as it interacts with the Windows Recycle Bin.

## Script Functionality

The script accepts one or more file or folder paths as input.

For each item:

1. It resolves the provided path (handling relative paths).
2. It checks if the item exists.
3. It determines if the item is a file or a directory.
4. Depending on the mode:
    * **Dry Run (`-DryRun`)**: Lists the items that would be moved, without performing any action.
    * **Normal Mode**: Moves the item to the Windows Recycle Bin.
5. It provides appropriate feedback via exit codes and optional console messages.

### Robustness Features

* **Stable Deletion Method:** Uses `[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile` and `[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory`. These .NET methods are more stable for Recycle Bin operations than older COM-based approaches, especially when dealing with multiple items.
* **Fallback for Files:** If loading the `Microsoft.VisualBasic` assembly fails (unlikely), it falls back to permanent file deletion using `[System.IO.File]::Delete`. This ensures file operations can still proceed, albeit without Recycle Bin recovery.
* **Error Handling:** Includes specific error handling for common issues like access denied or files/directories being in use.
* **Explicit Exit Codes:** The script explicitly returns an exit code of `0` for success and `1` for failure, making it suitable for automation and integration with other tools.

## Usage

Open a PowerShell terminal and run the script with the required parameters.

### Syntax

```powershell
.\Send-ToRecycleBin.ps1 -Path <String[]> [-DryRun] [-Verbose]
```

### Parameters

* **`-Path`** (Mandatory): One or more paths to the files or folders you want to move to the Recycle Bin. Paths can be absolute (e.g., `C:\Path\To\Item`) or relative (e.g., `.\Item`, `..\Folder\Item`). Wildcards are supported by the underlying .NET methods.
* **`-DryRun`** (Optional Switch): If included, the script performs a simulation. It resolves paths and checks existence but does *not* move any items. It reports the number of items that would be processed. Useful for testing.
* **`-Verbose`** (Optional Common Parameter): If included, the script outputs detailed information about its actions, including initialization, resolving paths, and attempting to move each item.

### Examples

1. **Move a Single File (Silent):**
    
    ```powershell
    .\Send-ToRecycleBin.ps1 -Path "C:\Temp\OldFile.txt"
    ```
    
    Moves `OldFile.txt` to the Recycle Bin. Produces no output on success.
2. **Move Multiple Items (Silent):**
    
    ```powershell
    .\Send-ToRecycleBin.ps1 -Path "C:\Temp\OldFile.txt", "C:\Temp\OldFolder"
    ```
    
    Moves both `OldFile.txt` and the directory `OldFolder` to the Recycle Bin. Silent operation.
3. **Dry Run to Preview:**
    
    ```powershell
    .\Send-ToRecycleBin.ps1 -Path "C:\Temp\Item1", "C:\Temp\Item2" -DryRun
    ```
    
    Checks if `Item1` and `Item2` exist and reports how many items would be processed. No items are moved.
4. **Verbose Output for Debugging:**
    
    ```powershell
    .\Send-ToRecycleBin.ps1 -Path ".\MyFile.log" -Verbose
    ```
    
    Moves `MyFile.log` and shows detailed messages about the process.
5. **Using Pipeline Input:**
    
    ```powershell
    Get-ChildItem "C:\Temp\*.tmp" | .\Send-ToRecycleBin.ps1
    ```
    
    Pipes all `.tmp` files from `C:\Temp` to the script, moving them to the Recycle Bin.

## Exit Codes

The script uses explicit exit codes to indicate the result of its operation:

* **`0`**: Success. The script completed its run. In Normal Mode, this means no errors occurred during processing. In Dry Run mode, it means paths were resolved successfully.
* **`1`**: Failure. An error occurred during the script's execution (e.g., a specified path did not exist, an item could not be moved due to permissions).

You can check the exit code in PowerShell immediately after running the script using the `$LASTEXITCODE` automatic variable:

```powershell
.\Send-ToRecycleBin.ps1 -Path "C:\SomeFile.txt"
$LASTEXITCODE # This will be 0 or 1
```

## Output & Logging

By default, the script produces minimal output to the console:

* **Errors:** If an item cannot be moved (e.g., due to permissions), a `Write-Error` message is displayed.
* **Warnings:** If a specified path does not exist, a `Write-Warning` message is displayed.
* **Dry Run Summary:** If `-DryRun` is used, a summary line is printed (e.g., "Dry Run Complete. Items that would be processed: N").
* **No Success Messages:** In normal mode, successful moves do not produce console output unless `-Verbose` is used.

Using the `-Verbose` switch will enable detailed logging messages throughout the script's execution.

## Troubleshooting

* **`Could not resolve path` Error:** Double-check the path(s) provided to the `-Path` parameter. Ensure they exist and are accessible.
* **`Access denied` Error:** Make sure the PowerShell process has the necessary permissions to delete the specified file or folder.
* **`Failed to load 'Microsoft.VisualBasic'` Warning:** This indicates the primary method for moving to the Recycle Bin failed. The script will fall back to permanent deletion for files. This warning should be rare.

