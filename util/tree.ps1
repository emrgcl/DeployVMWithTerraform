function Get-AsciiDirectoryTree {
    param (
        [string]$Path = '.',
        [string]$OutputFile = 'DirectoryStructure.txt',
        [int]$Level = 0
    )

    $filesAndFolders = Get-ChildItem -Path $Path -Force
    $markdownTree = ""

    foreach ($item in $filesAndFolders) {
        if ($item.PSIsContainer) {
            $markdownTree += "  " * $Level + "- " + $item.Name + "`n"
            $markdownTree += Get-AsciiDirectoryTree -Path $item.FullName -Level ($Level + 1)
        }
        else {
            $markdownTree += "  " * $Level + "- " + $item.Name + "`n"
        }
    }

    if ($Level -eq 0) {
        $markdownTree | Set-Content -Path $OutputFile
    }
    else {
        return $markdownTree
    }
}

# Usage example
Get-AsciiDirectoryTree -Path "./" -OutputFile "DirectoryStructure.txt"
