$dirs = Get-ChildItem -Directory -Recurse

# Utwórz tablicę z dozwolonymi rozszerzeniami
$allowedExtensions = @("gcm", "iso", "gcz", "ciso", "chd", "mdf", "nrg", "bin", "cue")

foreach ($dir in $dirs) {
    $decodedDirName = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($dir.FullName))
    Write-Host "Processing directory:" $decodedDirName
    $files = Get-ChildItem -Path $decodedDirName

    if ($files.Count -gt 0) {
        $createM3U = $false
        $gameTitle = $dir.Name
        $filesToAdd = @() # Initialize array to store files

        foreach ($file in $files) {
            $decodedFileName = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($file.Name))
            Write-Host "Checking file:" $decodedFileName
            if ($decodedFileName -match ".*\(Disc [1-9][0-9]?\).*\..+$") {
                Write-Host "File meets the condition:" $decodedFileName
                $createM3U = $true
                $discName = $decodedFileName
                $discNumber = $decodedFileName -replace ".*\(Disc (\d+).*", '$1'

                if ($discNumber.Length -gt 2) {
                    $discNumber = $discNumber.Substring(0, 2)
                }

                $filesToAdd += $discName # Store files in array
            }
        }

        # Sort files in alphabetical order
        $filesToAdd = $filesToAdd | Sort-Object

        if ($createM3U -eq $true) {
            $m3uDirectory = $files[0].Directory.FullName
            $m3uFilePath = Join-Path -Path $m3uDirectory -ChildPath "$gameTitle.m3u"

            if (-not (Test-Path $m3uFilePath)) {
                Write-Host "Creating m3u file for:" $gameTitle
                New-Item -ItemType File -Path $m3uDirectory -Name "$gameTitle.m3u" -Force | Out-Null
            }

            foreach ($fileToAdd in $filesToAdd) {
                Add-Content -Path $m3uFilePath -Value $fileToAdd
                Write-Host "Adding to m3u file:" $fileToAdd
            }

            Write-Host "m3u file created:" $m3uFilePath
        } else {
            Write-Host "No files meeting the condition found in directory:" $decodedDirName
        }
    }
}
