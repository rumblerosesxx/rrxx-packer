param (
    [string]$file
)

# Get the directory of the current PowerShell script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Example of an external command located in the same directory
$TOOL = Join-Path $scriptDir "rr-mod-tool.exe"

function Repack-Recursive {
    param (
        [string]$file
    )

    # Convert the file path to a full path
    try {
        $fullPath = (Resolve-Path $file).Path.TrimEnd('\')
    } catch {
        Write-Output "File not found: $file"
        return
    }

    # Get the file extension and convert it to uppercase
    $extension = (Get-Item $fullPath).Extension.ToUpper().TrimStart('.')

    # Get the base name of the file without the extension
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fullPath)

    # Ensure to stop processing for files named same as special extensions
    if ($baseName -eq $extension) {
        return
    }

    $newfile = [System.IO.Path]::ChangeExtension($fullPath, $null).TrimEnd('.')
    $lcase = $extension.ToLower()
    switch -Regex ($extension) {
	"^(EPAC|PACH)$" {
		Get-ChildItem -Path $fullPath | ForEach-Object {
            		Repack-Recursive $_.FullName
    	        }
		Write-Output "$TOOL -p $lcase $fullPath $newfile"
		& $TOOL -p $lcase $fullPath $newfile
	}
        "^TEX$" {
		Write-Output "$TOOL -p $lcase $fullPath $newfile"
		& $TOOL -p $lcase $fullPath $newfile
	}
        "^BPE$" {
		Write-Output "$TOOL -p $lcase $fullPath $newfile"
		& $TOOL -p $lcase $fullPath $newfile
	}
        "^(PAC,1,2,3,4,5,6,7,8,9)$" {
		return
	}
	default {
		$bfile = [System.IO.Path]::GetFileName($fullPath)
		$newfile = [System.IO.Path]::GetFileNameWithoutExtension($bfile)
		if ($bfile -ne $newfile) {
			Write-Output "! Rename $bfile -> $newfile"
			# Get the full path without the extension
			$newfile = [System.IO.Path]::ChangeExtension($fullPath, $null)
			Rename-Item -Path $fullPath -NewName $newfile
		}
	}
    }
    if (Test-Path $newfile) {
    	if ($fullPath -eq $newfile) {
		Remove-Item $fullPath -Recurse -Force
		Repack-Recursive "$newfile"
	}
    }
		
}

# Check if file is provided
if ($null -eq $file) {
    Write-Output "Usage: .\check_magic_bytes.ps1 <file>"
    exit 1
}

# Start the magic byte check process
Repack-Recursive $file

