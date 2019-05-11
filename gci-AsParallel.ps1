function GCI-AsParallel {
    <#
    .SYNOPSIS
    Returns a directory listing using parallel processing. Should be faster than Get-ChildItem in most cases.
    .PARAMETER Path
    Specifies a path to one or more locations. Wildcards are not permitted...yet... Path is required...For now...
    #>
    [cmdletbinding()]
    param
        (
            [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true)]
            [String[]]$Path,
            [Parameter(Mandatory = $false)]
            [Switch]$Recurse
        )
    if($Recurse){$SearchOption = "AllDirectories"}else{$SearchOption = "TopDirectoryOnly"}
    [System.IO.DirectoryInfo[]]$dirInfo = [System.IO.DirectoryInfo]::new($Path)

            try{[System.IO.FileInfo[]]$Files = [System.Linq.ParallelEnumerable]::AsParallel(
                $dirInfo.EnumerateFiles("*",[System.IO.SearchOption]::$SearchOption) 
            )}catch{$Files=$null}
            try{[System.IO.DirectoryInfo[]]$Directories = [System.Linq.ParallelEnumerable]::AsParallel(
                $dirInfo.EnumerateDirectories("*",[System.IO.SearchOption]::$SearchOption)
            )}catch{$Directories=$null}
   
   return $Directories+$Files
}
