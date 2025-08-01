# --- Script: Send-ToRecycleBin.ps1 ---

<#
.SYNOPSIS
    Moves one or more files or folders to the Windows Recycle Bin.

.DESCRIPTION
    This script accepts file or folder paths as input and moves them to the Windows Recycle Bin.
    It uses the stable .NET Microsoft.VisualBasic.FileIO.FileSystem methods for the operation.
    Verbose output is controlled by the standard -Verbose switch.

.PARAMETER Path
    One or more paths to files or folders to be moved to the Recycle Bin.
    Paths can be provided as strings or passed via the pipeline.
    Wildcards are supported by the underlying .NET method.

.PARAMETER Verbose
    If specified, enables detailed logging messages during execution.

.PARAMETER DryRun
    If specified, the script lists the items that would be moved but does not perform the action.
    Useful for testing.

.EXAMPLE
    # Move a single file (silent)
    .\Send-ToRecycleBin.ps1 -Path "C:\Path\To\File.txt"

.EXAMPLE
    # Move multiple items with verbose output
    .\Send-ToRecycleBin.ps1 -Path "C:\Path\To\File1.txt", "C:\Path\To\Folder1" -Verbose

.EXAMPLE
    # Move items using pipeline input
    Get-ChildItem "C:\Path\To\Temp\*" | .\Send-ToRecycleBin.ps1

.EXAMPLE
    # Dry run to see what would be moved (shows summary)
    .\Send-ToRecycleBin.ps1 -Path "C:\Path\To\Item" -DryRun

.NOTES
    Requires .NET Framework/Library access to Microsoft.VisualBasic.
    Uses [Microsoft.VisualBasic.FileIO.FileSystem] for stable Recycle Bin operations.
#>
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Enter the path(s) to the file(s) or folder(s) to recycle.")]
    [Alias("PSPath")] # Allows passing items from Get-ChildItem via pipeline
    [string[]]$Path,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

begin {
    # Use $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Verbose') to check for -Verbose
    # Or use the automatic $VerbosePreference variable which is 'Continue' when -Verbose is used.
    $IsVerbose = ($VerbosePreference -eq 'Continue')

    if ($IsVerbose) {
        Write-Verbose "Initializing Send-ToRecycleBin script..."
    }

    $UseVBMethodFile = $true
    $UseVBMethodDirectory = $true
    $ProcessedCount = 0
    $ErrorCount = 0
    $SuccessfulMoves = 0

    # --- Load Required .NET Assembly ---
    if ($IsVerbose) {
        Write-Verbose "Loading Microsoft.VisualBasic assembly..."
    }
    try {
        Add-Type -AssemblyName "Microsoft.VisualBasic" -ErrorAction Stop
        if ($IsVerbose) {
            Write-Verbose "Microsoft.VisualBasic assembly loaded successfully."
        }
    } catch {
        Write-Warning "Failed to load 'Microsoft.VisualBasic' assembly for files. Falling back to permanent deletion for files."
        try {
            Add-Type -AssemblyName "System.IO" -ErrorAction Stop
        } catch {
            Write-Error "Failed to ensure 'System.IO' is available. Cannot proceed with file deletion."
            $UseVBMethodFile = $false
            $ErrorCount++ # Increment error count for initialization failure
        }
        $UseVBMethodFile = $false
    }

    try {
        # Ensure System.IO.Directory is available for potential fallback (though .NET VB handles dirs)
        Add-Type -AssemblyName "System.IO" -ErrorAction Stop
    } catch {
        Write-Warning "Failed to ensure 'System.IO' is available for general IO checks (non-critical)."
        # This might not be critical if .NET VB works for directories
    }

    if ($DryRun -and $IsVerbose) {
        Write-Verbose "[DRY-RUN] Mode activated."
    }
}

process {
    foreach ($ItemPath in $Path) {
        # Resolve the path to handle relative paths or pipeline input
        try {
            $ResolvedPath = Resolve-Path -Path $ItemPath -ErrorAction Stop | Select-Object -ExpandProperty Path
        } catch {
            Write-Error "Could not resolve path: '$ItemPath'. Error: $_"
            $ErrorCount++
            continue # Skip to the next item
        }

        # Check if the resolved path exists
        if (-not (Test-Path -Path $ResolvedPath -PathType Any)) {
            # Use Warning for non-existent paths, Error might be too strong if globbing
            Write-Warning "Path does not exist or is inaccessible: '$ResolvedPath'. Skipping."
            $ErrorCount++
            continue
        }

        $ItemType = if (Test-Path -Path $ResolvedPath -PathType Container) { "Directory" } else { "File" }
        $ProcessedCount++

        if ($DryRun) {
            if ($IsVerbose) {
                Write-Verbose "[DRY-RUN] Would move ${ItemType}: '$ResolvedPath'"
            }
        } else {
            if ($IsVerbose) {
                Write-Verbose "Attempting to move ${ItemType} to Recycle Bin: '$ResolvedPath'"
            }
            try {
                if ($ItemType -eq "File") {
                    if ($UseVBMethodFile) {
                        # Use .NET VB method for files
                        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($ResolvedPath, 'OnlyErrorDialogs', 'SendToRecycleBin', 'DoNothing')
                    } else {
                        # Fallback: Permanent deletion for files
                        [System.IO.File]::Delete($ResolvedPath)
                        if ($IsVerbose) {
                            Write-Verbose "  -> Permanently deleted (fallback): '$ResolvedPath'"
                        }
                    }
                } else {
                    # ItemType is "Directory"
                    # Use .NET VB method for directories (handles recursion)
                    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($ResolvedPath, 'OnlyErrorDialogs', 'SendToRecycleBin', 'DoNothing')
                }
                if ($IsVerbose) {
                   Write-Verbose "  -> Success"
                }
                $SuccessfulMoves++
            } catch [System.UnauthorizedAccessException] {
                Write-Error "Error moving '$ResolvedPath': Access denied. ($($_.Exception.Message))" -ErrorAction Continue
                $ErrorCount++
            } catch [System.IO.IOException] {
                # This includes file/directory-in-use errors
                Write-Error "Error moving '$ResolvedPath': IO Error (possibly in use). ($($_.Exception.Message))" -ErrorAction Continue
                $ErrorCount++
            } catch [System.Management.Automation.MethodInvocationException] {
                # Catch errors specifically from the .NET VB method call
                Write-Error "Error moving '$ResolvedPath': .NET VB Method Error. ($($_.Exception.InnerException.Message))" -ErrorAction Continue
                $ErrorCount++
            } catch {
                Write-Error "Error moving '$ResolvedPath': Unexpected error. ($($_.Exception.Message))" -ErrorAction Continue
                $ErrorCount++
            }
        }
    }
}

# ... (previous code in the end block remains largely the same) ...

end {
    # --- Report Results ---
    # Show summary only for DryRun or if Verbose is enabled
    if ($DryRun) {
        # Always show Dry Run summary
        Write-Host "Dry Run Complete. Items that would be processed: $ProcessedCount"
        if ($ErrorCount -gt 0) {
            Write-Warning "Errors encountered during dry run: $ErrorCount"
            # Exit with error code 1 if errors occurred during dry-run
            exit 1
        } else {
            # Exit with success code 0 if dry-run completed without errors
            exit 0
        }
    } elseif ($IsVerbose) {
        # Show detailed summary only in Verbose mode for normal execution
        $MethodUsedFile = if ($UseVBMethodFile) { "Recycle Bin (via .NET VB)" } else { "Permanently deleted (fallback)" }
        $MethodUsedDir = "Recycle Bin (via .NET VB)"
        Write-Host "Operation Complete. Processed: $ProcessedCount, Moved: $SuccessfulMoves, Errors: $ErrorCount"
        # Optionally report method used if verbose or if fallback was used for files
        if ($IsVerbose -or (-not $UseVBMethodFile)) {
             Write-Host "Methods - Files: ${MethodUsedFile}, Directories: ${MethodUsedDir}"
        }
        if ($ErrorCount -gt 0) {
            Write-Warning "One or more errors occurred during execution. Check error messages above."
            # Exit with error code 1 if errors occurred during normal execution
            exit 1
        } else {
            # Exit with success code 0 if verbose mode completed without errors
            exit 0
        }
    } else {
        # Silent mode (neither -DryRun nor -Verbose)
        # Potentially report critical errors if any occurred, but not the standard summary
        if ($ErrorCount -gt 0) {
            # In silent mode, we still want to indicate an error via exit code
            # Even if we don't print a summary message by default.
            # Write-Warning "Operation finished with $ErrorCount error(s). Use -Verbose for details."
            exit 1 # Exit with error code
        } else {
            # Silent success: Exit with code 0
            exit 0
        }
    }
    # Default implicit exit (should not be reached due to explicit exits above,
    # but added for clarity). PowerShell usually defaults to 0 if no error occurred.
    # exit 0
}
