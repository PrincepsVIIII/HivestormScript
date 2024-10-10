#2024 Hivestorm Competition Windows Script - Annotated

# Define the array at a global scope
$failedProcesses = New-Object -TypeName System.Collections.ArrayList
$successfulProcesses = New-Object -TypeName System.Collections.ArrayList


# Error handling wrapper function to ensure continued execution
function Try-Execute {
    param (
        [string]$ProcessName,
        [scriptblock]$CodeBlock
    )

    try {
        & $CodeBlock
		Write-Host "                                                    "
        Write-Host "Completed - ${ProcessName}" -ForegroundColor Green
		$successfulProcesses.Add("$ProcessName")
    }
    catch {
		$failedProcesses.Add("$ProcessName")
        Write-Host "Failed - ${ProcessName}: $($_.Exception.Message)" -ForegroundColor Red
    }
}

#Function to clear the processes lists
function Clear-Lists {
	$failedProcesses.Clear()
	$successfulProcesses.Clear()
}

# Function to report process status
function Report-Process-Status {
	if ($failedProcesses -ne 0){
		foreach($process in $failedProcesses){
			Write-Host "Failed - $process" -ForegroundColor Red
		}
	}
	foreach($process in $successfulProcesses){
		Write-Host "Success - $process" -ForegroundColor Green
	}
}

# Function to provide the Task Summary
function Task-Summary {
	param (
        $multipleProcesses
    )
		Write-Host "==============================="
		Write-Host "           Task Summary        "
		Write-Host "==============================="
		if ($multipleProcesses -eq $true){
			
			if ($failedProcesses.Count -eq 0){
				Report-Process-Status
				Write-Host "All processes completed successfully." -ForegroundColor Green
			}
			else{
				$failedCount = $failedProcesses.Count
				Report-Process-Status
				Write-Host "${failedCount} processes failed." -ForegroundColor Red
				
			}
		}
		else{
			Report-Process-Status
		}
	Write-Host "==============================="
	Clear-Lists
}
# Function to configure secure audit policies
function Set-AuditPolicies {
    Write-Host "Configuring secure audit policies..."

    # Set all audit policies for success and failure
    $auditSettings = @(
		"auditpol /set /category:'Account Logon' /success:enable /failure:enable",
        "auditpol /set /category:'Account Management' /success:enable /failure:enable",
        "auditpol /set /category:'DS Access' /success:enable /failure:enable",
        "auditpol /set /category:'Logon/Logoff' /success:enable /failure:enable",
		"auditpol /set /category:'System' /success:enable /failure:enable",
        "auditpol /set /category:'Object Access' /success:enable /failure:enable",
        "auditpol /set /category:'Policy Change' /success:enable /failure:enable",
        "auditpol /set /category:'Privilege Use' /success:enable /failure:enable",
        "auditpol /set /category:'Detailed Tracking' /success:enable /failure:enable"
    )

    foreach ($policy in $auditSettings) {
        Invoke-Expression $policy
    }
    Write-Host "Audit policies configured successfully."
}

# Function to set Account security and password settings
function Set-AccountPolicies {
    Write-Host "Configuring account policies..."
	# Define the path to the security template
	$templatePath = "C:\HivestormTemplate.inf"

	# Check if the template file exists
	if (Test-Path $templatePath) {
		Write-Host "Applying security template..." -ForegroundColor Cyan
    
		# Apply the security template using Secedit
		secedit /configure /db secedit.sdb /cfg $templatePath /verbose

		# Check if the security template was applied successfully
		if ($?) {
			Write-Host "Security template applied successfully." -ForegroundColor Green
		} else {
			Write-Host "Failed to apply the security template." -ForegroundColor Red
		}
	}	 
	else {
		Write-Host "Security template file not found. Please verify the path." -ForegroundColor Red
	}
}


# Function to locate and confirm removal of media files
function Remove-MediaFiles {
    Write-Host "Searching for media files in the C:\Users folder..."

    # Define the path to the Users directory
    $userFolder = "C:\Users"

    # Define file extensions for media types to be removed
    $mediaExtensions = @('*.mp3', '*.mp4', '*.wav', '*.jpg', '*.jpeg', '*.png', '*.gif', '*.bmp', '*.avi', '*.mov', '*.wmv', '*.mkv', '*.jfif', '*.txt')

    # Initialize an array to store found media files
    $mediaFiles = @()

    # Search for media files in the Users folder and its subdirectories
    foreach ($extension in $mediaExtensions) {
        $mediaFiles += Get-ChildItem -Path $userFolder -Recurse -Filter $extension -ErrorAction SilentlyContinue
    }

    # Filter media files to ensure they are within the C:\Users path
    $mediaFiles = $mediaFiles | Where-Object { $_.FullName -like "$userFolder\*" }

    # Check if any media files were found
    if ($mediaFiles.Count -eq 0) {
        Write-Host "No media files found in the Users folder." -ForegroundColor Yellow
        return
    }

    # List found media files and ask for confirmation before removal
    Write-Host "Found the following media files in C:\Users:"
    foreach ($file in $mediaFiles) {
        Write-Host "$($file.FullName)"
    }
    # Confirm removal with the user
    try {
        foreach ($file in $mediaFiles) {
            # Double-check that each file path still matches the intended Users directory
            if ($file.FullName.StartsWith("$userFolder\", [System.StringComparison]::InvariantCultureIgnoreCase)) {
				if($file.Name.StartsWith("Forensics", [System.StringComparison]::InvariantCultureIgnoreCase)){
					Write-Host "Skipped: $($file.FullName)" -ForegroundColor Yellow
				}
				else{
					Remove-Item -Path $file.FullName -Force -Confirm
					Write-Host "Removed: $($file.FullName)" -ForegroundColor Green
				}
			}
        }
    }
    catch {
        Write-Host "Failed - An error occurred while removing media files: $($_.Exception.Message)" -ForegroundColor Red
    }	
}

# Function to disable insecure services
function Disable-InsecureServices {
    Write-Host "Disabling insecure and unnecessary services..."

    # List of services to disable, including new services requested
    $servicesToDisable = @(
        "RemoteRegistry",   # Allows remote access to the registry, disable to prevent remote tampering.
        "SSDPDiscovery",    # SSDP discovery, unnecessary and can be used for information gathering.
        "Telnet",           # Insecure remote login protocol, replaced by SSH.
        "UPnPHost",         # UPnP protocol can be used in network attacks.
        "Fax",              # Typically unnecessary and can be a security risk.
        "XblGameSave",      # Xbox Live game save service, not required.
        "XboxGipSvc",       # Xbox accessory management, not needed for most environments.
        "RemoteDesktopServices", # Remote desktop, insecure access protocol unless configured securely.
        "FTPSVC",          # FTP service, not secure and should be disabled unless necessary.
        "W3SVC",            # Web Services, often unused in competitions.
        "IISADMIN"         # IIS admin service, associated with web hosting.
    )

    foreach ($service in $servicesToDisable) {
        try {
		Stop-Service -Name"$service" -Force
		Set-Service -Name "$service" -Status Stopped -StartupType Disabled -ErrorAction Stop
            	Write-Host "Disabled - ${service}" -ForegroundColor Green
        }
        catch [System.InvalidOperationException] {
			Write-Host "Unsuccessful - The service ${service} was not found" -ForegroundColor Yellow
			
        }
		catch {
			Write-Host "Failed - Could not disable ${service}: $($_.Exception.Message)" -ForegroundColor Red
		}
    }

    Write-Host "Insecure services configuration completed."	
}

# Function to show the user menu
function Show-Menu {
    Clear-Host
	Write-Host "Welcome to my HiveStorm 2024 Windows Script. This script is currently under testing the following categories are still untested on an official practice image: 1-5. Please use caution when using these functions."
	Write-Host "                               "
    Write-Host "==============================="
    Write-Host "    Princeps' Security Menu    "
    Write-Host "==============================="
    Write-Host "1. Configure Audit Policies"
    Write-Host "2. Configure Account Policies"
    Write-Host "3. Locate and Remove Media Files"
    Write-Host "4. Disable Insecure Services"
    Write-Host "5. Run All Security Functions"
    Write-Host "0. Exit"
    Write-Host "==============================="
}

# Function to run the menu with user selection
function Run-Menu {
    do {
        Show-Menu
        $choice = Read-Host "Select an option (0-5)"
        switch ($choice) {
            "1" {
                Try-Execute -ProcessName "Configure Audit Policies" -CodeBlock { Set-AuditPolicies }
				Task-Summary -multipleProcesses $false 
                Read-Host "Press Enter to return to the menu"
				
            }
            "2" {
                Try-Execute -ProcessName "Configure Account Policies" -CodeBlock { Set-AccountPolicies }
				Task-Summary -multipleProcesses $false 
                Read-Host "Press Enter to return to the menu"
            }
            "3" {
                Try-Execute -ProcessName "Locate and Remove Media Files" -CodeBlock { Remove-MediaFiles }
				Task-Summary -multipleProcesses $false 
                Read-Host "Press Enter to return to the menu"
            }
            "4" {
                Try-Execute -ProcessName "Disable Insecure Services" -CodeBlock { Disable-InsecureServices }
				Task-Summary -multipleProcesses $false 
                Read-Host "Press Enter to return to the menu"
            }
            "5" {
                Try-Execute -ProcessName "Configure Audit Policies" -CodeBlock { Set-AuditPolicies }
                Try-Execute -ProcessName "Configure Account Policies" -CodeBlock { Set-AccountPolicies }
                Try-Execute -ProcessName "Locate and Remove Media Files" -CodeBlock { Remove-MediaFiles }
                Try-Execute -ProcessName "Disable Insecure Services" -CodeBlock { Disable-InsecureServices }
				Task-Summary -multipleProcesses $true 
                Write-Host "All security functions have been executed."
                Read-Host "Press Enter to return to the menu..."
            }
            "0" {
                Write-Host "Exiting the script. Goodbye!"
            }
            default {
                Write-Host "Invalid option. Please select a number between 0 and 5."
                Read-Host "Press Enter to return to the menu"
            }
        }
    } 
	while ($choice -ne "0")
}


# Execute the menu function to allow user selection
Run-Menu
