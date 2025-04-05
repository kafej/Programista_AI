# Get the path of the running script
$scriptFullPath = $PSCommandPath

# Define registry key for tracking state
$regPath = "HKCU:\Software\MyRebootScript"

# Function to check if Docker Desktop is installed
function Is-DockerInstalled {
    $dockerPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*Docker Desktop*" }
    return $null -ne $dockerPath
}

Write-Host "Installing Ollama"
winget install ollama

Write-Host "Refreashing variable Path"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "Adding port 11434 to Firewall"
New-NetFirewallRule -DisplayName "Allow TCP/UDP Port 11434 (Private)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 11434 -Profile Private
New-NetFirewallRule -DisplayName "Allow TCP/UDP Port 11434 (Private)" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 11434 -Profile Private

#Install model
ollama pull deepseek-r1:7b

# Ensure registry key exists
if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Check if script is running before or after reboot
$step = Get-ItemProperty -Path $regPath -Name "Step" -ErrorAction SilentlyContinue

if ($step -eq $null) {
    # First execution before reboot
    Write-Host "Checking if Docker Desktop is installed..."

    if (Is-DockerInstalled) {
        Write-Host "Docker Desktop is installed. Skipping reboot."
        Exit
    }

    Write-Host "Docker Desktop is NOT installed. Installing."
    winget install "Docker Desktop"

    Write-Host "After docker install reboot is required."
    
    # Ask user for confirmation
    $confirmation = Read-Host "Are you ready to reboot? (yes/no)"
    if ($confirmation -ne "yes") {
        Write-Host "Reboot canceled. Exiting script."
        Exit
    }

    # Store step in registry
    Set-ItemProperty -Path $regPath -Name "Step" -Value 1

    # Create script for post-reboot execution
    $postRebootScript = @"
Start-Sleep -Seconds 10  # Wait to ensure reboot is complete
Write-Host 'Performing post-reboot actions...'

# Perform post-reboot actions here
Write-Host 'Post-reboot task completed.'

# Cleanup registry and script
Remove-Item -Path '$regPath' -Recurse -ErrorAction SilentlyContinue
Remove-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'PostRebootScript' -ErrorAction SilentlyContinue
"@

    # Save post-reboot script in the same directory as the original script
    $postScriptPath = "$scriptFullPath"
    $postRebootScript | Set-Content -Path $postScriptPath -Encoding UTF8

    # Add script to run at startup
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "PostRebootScript" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$postScriptPath`""

    # Reboot system
    Write-Host "Rebooting system now..."
    Restart-Computer -Force
} else {
    # Post-reboot execution
    Write-Host "Performing post-reboot actions..."

    # Cleanup registry and script
    Remove-Item -Path $regPath -Recurse -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "PostRebootScript" -ErrorAction SilentlyContinue
    Remove-Item -Path "$scriptFullPath" -ErrorAction SilentlyContinue

    Write-Host "Post-reboot task completed. Cleanup done."

    Start-Sleep 5

    Write-Host "Installing AnythingLLM as Docker container"
    docker pull mintplexlabs/anythingllm

    # Serve the model on port 11434
    ollama serve

    $env:STORAGE_LOCATION="$HOME\Documents\anythingllm"; `
    If(!(Test-Path $env:STORAGE_LOCATION)) {New-Item $env:STORAGE_LOCATION -ItemType Directory}; `
    If(!(Test-Path "$env:STORAGE_LOCATION\.env")) {New-Item "$env:STORAGE_LOCATION\.env" -ItemType File}; `
    docker run -d -p 3001:3001 `
    --name ProgramistaMAG-LLM `
    --cap-add SYS_ADMIN `
    --restart=always `
    -v "$env:STORAGE_LOCATION`:/app/server/storage" `
    -v "$env:STORAGE_LOCATION\.env:/app/server/.env" `
    -e STORAGE_DIR="/app/server/storage" `
    mintplexlabs/anythingllm;

    #Start Docker
    Start-Process "C:\ProgramData\Microsoft\Windows\Start Menu\Docker Desktop.lnk"
    # Wait till Docker will fully load
    Start-Sleep 15
    #Open AnythingLLM local website
    Start-Process "http://localhost:3001"

}
