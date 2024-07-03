param (
    [string]$file
)

# Get the directory of the current PowerShell script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Example of an external command located in the same directory
$TOOL = Join-Path $scriptDir "rr-mod-tool.exe"
$FILE_TOOL = Join-Path $scriptDir "file.exe"
$MAGIC_FILE = Join-Path $scriptDir "magic"

# Function to check the first 4 bytes of the file
function Unpack-Recursive {
    param (
        [string]$file,
	[int]$level
    )

    # Convert the file path to a full path
    try {
        $fullPath = (Resolve-Path $file).Path
    } catch {
        Write-Output "File not found: $file"
        return
    }

    # Read the first 4 bytes of the file
    try {
        $fileStream = [System.IO.File]::OpenRead($fullPath)
        $binaryReader = New-Object System.IO.BinaryReader($fileStream)
        $magicBytes = $binaryReader.ReadBytes(4)
        $magicString = [System.Text.Encoding]::ASCII.GetString($magicBytes)

        $fileStream.Close()

        switch -Regex ($magicString) {
            "^(EPAC|PACH)$" {
		    Write-Output "! $file $magicString";
		    $dest_dir = "$fullPath.$magicString"
		    & $TOOL -u "$fullPath" "$dest_dir"
                    if ((Test-Path $dest_dir) -and $magicString -eq "PACH" -and $level -gt 0) {
			    Remove-Item $fullPath
		    }
		    Get-ChildItem $dest_dir | ForEach-Object {
     			   if ($_.PSIsContainer -eq $false) {
            			$level = $level + 1
            			Unpack-Recursive $_.FullName $level
        		   }
    	            }
		    return
	    }
            "BPE " {
		    Write-Output "! $file $magicString";
		    $dest_file = "$fullPath.BPE"
		    & $TOOL -u "$fullPath" "$dest_file"
		    if (Test-Path $dest_file) {
                        if ($level -gt 0) { Remove-Item $fullPath }
        		$level = $level + 1
        		Unpack-Recursive $dest_file $level
                    }
		    return
            }
            default {
		    $fileSize = (Get-Item $fullPath).length
		    $tex = $false
            	    if ($fileSize -ge 36) {
                    	$extracted = [System.Text.Encoding]::ASCII.GetString([System.IO.File]::ReadAllBytes($fullPath)[32..35])
                        if ($extracted -match "dds|tga|atb|png") {
		    		Write-Output "! $file TEX";
				$tex = $true
		    		$dest_file = "$fullPath.TEX"
		    		& $TOOL -u "$fullPath" "$dest_file"
		    		if ((Test-Path $dest_file) -and $level -gt 0) {
                        		Remove-Item $fullPath
				}
                	}
            	    }
		    if (-not $tex) {
			if ((Get-Item $fullPath).Name -ne "__entry__") {
                    		$extension = $magicString
                    		if ($extension -match "JBOY") { $extension = "YOBJ" }
               			if ($extension -match "^[A-Z]{3}") {
                      			Rename-Item $fullPath -NewName "$fullPath.$extension"
               			} else {
                      			$fileType = (& $FILE_TOOL -b $fullPath -m $MAGIC_FILE).Split(' ')[0] 
                       			switch ($fileType) {
                       				"Targa" { $extension = "TGA" }
                       				"Non-ISO" { $extension = "TXT" }
                       				default { $extension = $fileType }
                       			}
                       			if ($extension -match "^[a-zA-Z0-9]{3,4}$") {
		    				Write-Output "! $file $extension";
                       				Rename-Item $file -NewName "$file.$extension"
                       			}
               			}
			}
      		    }
		    return
            }
        }
    } catch {
        Write-Output "Error reading file: $_"
    }
}

# Check if file is provided
if ($null -eq $file) {
    Write-Output "Usage: .\check_magic_bytes.ps1 <file>"
    exit 1
}

# Start the magic byte check process
Unpack-Recursive $file 0

