# Get the directory where the script is run (e.g., d:\retrobat\roms)
$baseDir = Get-Location

# Get all subdirectories directly under the base directory (e.g., d:\retrobat\roms\psx, d:\retrobat\roms\ps2)
$subDirs = Get-ChildItem -Path $baseDir -Directory

# Define the allowed file extensions
$allowedExtensions = @("gcm", "iso", "gcz", "ciso", "chd", "mdf", "nrg", "bin", "cue", "ccd", "img", "sub", "rvz")

# Process each subdirectory
foreach ($subDir in $subDirs) {
    $subDirPath = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($subDir.FullName))
    Write-Host "Processing subdirectory:" $subDirPath
    
    # Get all files directly inside the current subdirectory
    $files = Get-ChildItem -Path $subDirPath | Where-Object { -not $_.PSIsContainer }

    # Only proceed if there are files directly in the current subdirectory
    if ($files.Count -gt 0) {
        $fileGroups = @{}

        foreach ($file in $files) {
            # Check if the file has an allowed extension
            if ($allowedExtensions -contains $file.Extension.ToLower().TrimStart('.')) {
                $decodedFileName = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($file.Name))
                Write-Host "Checking file:" $decodedFileName

                # Check if the file matches the pattern (e.g., Game (Disc 1).iso)
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

        # Process each group of files
        foreach ($prefix in $fileGroups.Keys) {
            $groupFiles = $fileGroups[$prefix]

            # Check if a folder with the same prefix already exists in the subdirectory
            $folderPath = Join-Path -Path $subDirPath -ChildPath $prefix
            if ((Test-Path $folderPath) -and (Get-ChildItem -Path $folderPath -Directory).Count -gt 0) {
                Write-Host "Skipping group '$prefix' as a folder with this name already exists: $folderPath"
                continue
            }

            # Create a new folder for the group if it doesn't exist
            if (-not (Test-Path $folderPath)) {
                Write-Host "Creating folder for prefix '$prefix': $folderPath"
                New-Item -ItemType Directory -Path $folderPath | Out-Null
            }

            # Move each file in the group to the newly created folder
            foreach ($file in $groupFiles) {
                Write-Host "Moving file '$($file.Name)' to folder '$folderPath'"
                Move-Item -Path $file.FullName -Destination $folderPath -Force
            }
        }
    }
    else {
        Write-Host "No files found directly in $subDirPath"
    }
}
