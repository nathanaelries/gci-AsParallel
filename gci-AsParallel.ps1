function Get-ChildItemAsParallel {
    <#
    .SYNOPSIS
    Retrieves a directory listing using parallel processing.

    .DESCRIPTION
    This function uses PLINQ (Parallel LINQ) to enumerate files and directories in parallel,
    which may provide a performance improvement over the standard Get-ChildItem command in some scenarios.
    You can supply one or more paths (via the parameter or pipeline) and optionally search recursively.

    .PARAMETER Path
    One or more paths to search. Wildcards are not supported. Each path is checked for existence.
    
    .PARAMETER Recurse
    If specified, the function will enumerate files and directories in all subdirectories.
    
    .EXAMPLE
    Get-ChildItemAsParallel -Path 'C:\Temp'
    
    Retrieves files and directories in C:\Temp (top-level only).

    .EXAMPLE
    'C:\Temp','C:\Logs' | Get-ChildItemAsParallel -Recurse
    
    Retrieves files and directories from C:\Temp and C:\Logs, including all subdirectories.

    .NOTES
    Author: Your Name
    Date  : 2025-02-11
    #>
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string[]]$Path,

        [Parameter(Mandatory = $false)]
        [Switch]$Recurse
    )

    process {
        # Determine the search option based on the Recurse switch
        $searchOption = if ($Recurse) {
            [System.IO.SearchOption]::AllDirectories
        }
        else {
            [System.IO.SearchOption]::TopDirectoryOnly
        }

        # Initialize an array to hold the results
        $results = @()

        foreach ($p in $Path) {
            if (-not (Test-Path -LiteralPath $p)) {
                Write-Warning "The specified path '$p' does not exist. Skipping..."
                continue
            }

            try {
                $dirInfo = [System.IO.DirectoryInfo]::new($p)
            }
            catch {
                Write-Warning "Unable to create DirectoryInfo for path '$p': $_"
                continue
            }

            # Use parallel processing to enumerate directories and files.
            # Note: PLINQ will attempt to process the enumerable in parallel.
            try {
                $directories = [System.Linq.ParallelEnumerable]::AsParallel(
                    $dirInfo.EnumerateDirectories("*", $searchOption)
                )
            }
            catch {
                Write-Warning "Error enumerating directories in '$p': $_"
                $directories = @()
            }

            try {
                $files = [System.Linq.ParallelEnumerable]::AsParallel(
                    $dirInfo.EnumerateFiles("*", $searchOption)
                )
            }
            catch {
                Write-Warning "Error enumerating files in '$p': $_"
                $files = @()
            }

            # Combine directories and files, and add them to the result array.
            $results += $directories + $files
        }

        # Output the final list of files and directories.
        return $results
    }
}
