function Get-AsciiDirectoryStructure {
    param(
        [string]$DirectoryPath,
        [string]$Indent = "",
        [string]$GitignorePath,
        [string]$OutputPath
    )

    $gitignorePatterns = Get-Content -Path $GitignorePath | Where-Object { $_ -notmatch '^#|^$' }

    $result = ""
    $items = Get-ChildItem -Path $DirectoryPath -Force | Where-Object {
        $include = $true
        foreach ($pattern in $gitignorePatterns) {
            if ($_.FullName -like "*$pattern*" -or $_.Name -eq ".git") {
                $include = $false
                break
            }
        }
        return $include
    }

    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]

        if ($i -eq $items.Count - 1) {
            $result += "${Indent}└─ $($item.Name)`n"
            $newIndent = "${Indent}   "
        }
        else {
            $result += "${Indent}├─ $($item.Name)`n"
            $newIndent = "${Indent}│  "
        }

        if ($item.PSIsContainer) {
            $result += Get-AsciiDirectoryStructure -DirectoryPath $item.FullName -Indent $newIndent -GitignorePath $GitignorePath -OutputPath $OutputPath
        }
    }

    if ($Indent -eq "") {
        Set-Content -Path $OutputPath -Value $result
    }

    return $result
}

$rootDirectory = "/Users/emreguclu/Repos/DeployVMWithTerraform" # Replace with the desired directory path
$gitignorePath = "$rootDirectory/.gitignore" # Replace with the path to your .gitignore file
$outputPath = "$rootDirectory/temp/dirstructure.txt" # Replace with the desired output file path
Get-AsciiDirectoryStructure -DirectoryPath $rootDirectory -GitignorePath $gitignorePath -OutputPath $outputPath
