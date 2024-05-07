$dirs = Get-ChildItem -Directory -Recurse

# Utwórz tablicę z dozwolonymi rozszerzeniami
$allowedExtensions = @("gcm", "iso", "gcz", "ciso", "chd", "mdf", "nrg", "bin", "cue")

foreach ($dir in $dirs) {
    $decodedDirName = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($dir.FullName))
    Write-Host "Processing directory:" $decodedDirName
    $files = Get-ChildItem -Path $decodedDirName

    if ($files.Count -gt 0) {
        $fileGroups = @{}

        foreach ($file in $files) {
            # Sprawdź, czy plik ma dozwolone rozszerzenie
            if ($allowedExtensions -contains $file.Extension.ToLower().TrimStart('.')) {
                $decodedFileName = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($file.Name))
                Write-Host "Checking file:" $decodedFileName
                if ($decodedFileName -match "^(.*?)\(Disc \d+\)(.*?)\.(.*)$") {
                    $prefix = $Matches[1].Trim()
                    $fileExtension = $Matches[3]

                    if (-not $fileGroups.ContainsKey($prefix)) {
                        $fileGroups[$prefix] = @()
                    }
                    $fileGroups[$prefix] += $file
                }
            }
        }

        foreach ($prefix in $fileGroups.Keys) {
            $groupFiles = $fileGroups[$prefix]
            if ($groupFiles.Count -eq $files.Count) {
                Write-Host "All files with prefix '$prefix' belong to the same group."
                continue
            }

            $folderName = $prefix
            $folderPath = Join-Path -Path $decodedDirName -ChildPath $folderName
            if (-not (Test-Path $folderPath)) {
                Write-Host "Creating folder for prefix '$folderName': $folderPath"
                New-Item -ItemType Directory -Path $folderPath | Out-Null
            }

            foreach ($file in $groupFiles) {
                Write-Host "Moving file '$($file.Name)' to folder '$folderName'"
                Move-Item -Path $file.FullName -Destination $folderPath -Force
            }
        }
    }
}
