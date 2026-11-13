$ErrorActionPreference = "Stop"

$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Not elevated: skipped the Rex install and the Hyper-V firewall rule. Run again from an administrator session."
    exit 0
}

if (-not (winget source list | Select-String -Quiet "^rex\s")) {
    winget source add --name rex --arg https://pkgs.superlogical.com/rex/winget --type Microsoft.Rest --explicit --accept-source-agreements
}

winget list --id Superlogical.RexServer.Snapshot --source rex --accept-source-agreements --disable-interactivity | Out-Null
if ($LASTEXITCODE -ne 0) {
    winget install Superlogical.RexServer.Snapshot --source rex --accept-package-agreements --accept-source-agreements --disable-interactivity
}

if (-not (Get-NetFirewallHyperVRule -Name "rex-wsl" -ErrorAction SilentlyContinue)) {
    New-NetFirewallHyperVRule -Name "rex-wsl" -DisplayName "Rex (WSL)" -Direction Inbound `
        -VMCreatorId "{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}" -Protocol TCP `
        -LocalAddresses 100.70.0.10 -LocalPorts 7297 `
        -RemoteAddresses 100.70.0.11, 100.121.29.45 -Action Allow | Out-Null
}

Write-Output "Windows side applied: Rex Server and the rex-wsl Hyper-V firewall rule are present."
