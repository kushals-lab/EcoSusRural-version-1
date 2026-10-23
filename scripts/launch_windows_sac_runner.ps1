#requires -Version 5.1
<#
.SYNOPSIS
    Runs the EcoSusRural Windows desktop app, surviving Smart App Control blocks.

.DESCRIPTION
    On Windows 11 with Smart App Control (SAC) in enforcement mode, the freshly
    linked, unsigned runner can be refused at process start:

        Unable to start executable "build\windows\x64\runner\Debug\eco_sus_rural.exe"
        ProcessException: An Application Control policy has blocked this file
        App failed to start

    SAC blocks unsigned binaries that Microsoft's app intelligence service cannot
    classify and has no per-app exclusions. The block is a verdict transition:
    the same binary starts on a later attempt once Windows has a verdict for it
    (Code Integrity event 3076 audit / 3077 block / 3118 details, policy
    WindowsLockdownPolicy). This wrapper builds the runner, probes it until it
    starts, then hands over to `flutter run`.

    Docs: https://learn.microsoft.com/windows/apps/develop/smart-app-control/overview

    Parameters: -Mode debug|profile|release, -ProbeAttempts, -ProbeDelaySeconds,
    -SkipBuild (probe the existing build) and -DiagnoseOnly.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\run_windows.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\run_windows.ps1 -DiagnoseOnly
#>
[CmdletBinding()]
param(
    [ValidateSet('debug', 'profile', 'release')]
    [string]$Mode = 'debug',
    [int]$ProbeAttempts = 10,
    [int]$ProbeDelaySeconds = 30,
    [switch]$SkipBuild,
    [switch]$DiagnoseOnly
)

$ErrorActionPreference = 'Stop'
$modeDir = @{ debug = 'Debug'; profile = 'Profile'; release = 'Release' }[$Mode]

function Get-SmartAppControlState {
    <# Off / On (enforcement) / Evaluation / Unavailable for this device. #>
    try {
        $value = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy' `
                -Name VerifiedAndReputablePolicyState -ErrorAction Stop).VerifiedAndReputablePolicyState
    } catch {
        return 'Unavailable'
    }
    switch ([int]$value) {
        0 { return 'Off' }
        1 { return 'On (enforcement)' }
        2 { return 'Evaluation' }
        default { return "Unknown ($value)" }
    }
}

function Get-AppControlBlocks {
    <# Code Integrity events naming this app since $Since (empty array if none). #>
    param([datetime]$Since)
    $filter = @{
        LogName   = 'Microsoft-Windows-CodeIntegrity/Operational'
        Id        = 3076, 3077, 3118
        StartTime = $Since
    }
    try {
        # Get-WinEvent errors out when the filter matches nothing.
        $events = Get-WinEvent -FilterHashtable $filter -ErrorAction Stop
    } catch {
        return @()
    }
    return @($events | Where-Object { $_.Message -match 'eco_sus_rural' })
}

function Test-RunnerStarts {
    <# ok | blocked | exited | missing #>
    param([string]$ExePath, [int]$HoldSeconds = 3)

    if (-not (Test-Path -LiteralPath $ExePath)) { return 'missing' }

    $started = Get-Date
    try {
        $proc = Start-Process -FilePath $ExePath -PassThru -ErrorAction Stop
    } catch {
        return 'blocked'
    }
    Start-Sleep -Seconds $HoldSeconds
    if ($null -ne (Get-Process -Id $proc.Id -ErrorAction SilentlyContinue)) {
        # /T so children of the probe go away with it.
        & taskkill.exe /PID $proc.Id /T /F 2>&1 | Out-Null
        return 'ok'
    }
    if (@(Get-AppControlBlocks -Since $started.AddSeconds(-5)).Count -gt 0) { return 'blocked' }
    return 'exited'
}

function Write-SacGuidance {
    Write-Host ''
    Write-Host 'Smart App Control refused to start the runner executable.' -ForegroundColor Yellow
    Write-Host 'It blocks unsigned binaries it cannot classify and has no per-app exclusions.'
    Write-Host '  1. Run this script again later: once Windows has a verdict for the'
    Write-Host '     binary it starts normally.'
    Write-Host '  2. Develop on a machine/VM without Smart App Control.'
    Write-Host '  3. Turn it Off - Settings > Privacy & security > Windows Security >'
    Write-Host '     App & browser control > Smart App Control settings.'
    Write-Host '     One-way operation: it cannot be turned back on without a Windows reset.'
    Write-Host ''
    Write-Host 'Inspect it: powershell -File scripts\run_windows.ps1 -DiagnoseOnly'
    Write-Host 'Docs: https://learn.microsoft.com/windows/apps/develop/smart-app-control/overview'
    Write-Host ''
}

# --- Project root: this script lives in <project>\scripts ---------------------
$root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath (Join-Path $root 'pubspec.yaml'))) {
    if (Test-Path -LiteralPath (Join-Path (Get-Location) 'pubspec.yaml')) {
        $root = (Get-Location).Path
    } else {
        throw "Could not find pubspec.yaml above $PSScriptRoot - run this script from the project."
    }
}
$exePath = Join-Path $root "build\windows\x64\runner\$modeDir\eco_sus_rural.exe"
$sacState = Get-SmartAppControlState

if ($DiagnoseOnly) {
    Write-Host "Project          : $root"
    Write-Host "Smart App Control: $sacState"
    Write-Host "Runner ($Mode): $exePath (exists: $(Test-Path -LiteralPath $exePath))"
    Write-Host ''
    $blocks = @(Get-AppControlBlocks -Since (Get-Date).AddDays(-2))
    if ($blocks.Count -eq 0) {
        Write-Host 'No Application Control block for eco_sus_rural in the last 2 days.' -ForegroundColor Green
    } else {
        Write-Host "$($blocks.Count) Application Control event(s) for eco_sus_rural (2 days):" -ForegroundColor Yellow
        foreach ($block in $blocks) {
            $policy = if ($block.Message -match 'Policy ID:\{([0-9a-f-]+)\}') { $Matches[1] } else { 'n/a' }
            Write-Host ("  {0:yyyy-MM-dd HH:mm:ss}  id={1}  policy={2}" -f $block.TimeCreated, $block.Id, $policy)
        }
        Write-Host 'Event 3077 = enforced block, 3076 = evaluation audit, 3118 = SAC details.'
    }
    exit 0
}

if ($sacState -eq 'On (enforcement)') {
    Write-Host 'Smart App Control is On (enforcement) - unsigned dev builds may be blocked.' `
        -ForegroundColor DarkYellow
}

if (-not $SkipBuild) {
    Write-Host "==> flutter build windows --$Mode"
    & flutter build windows "--$Mode"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

# --- Probe: wait until Windows actually lets the freshly built runner start ---
$state = 'missing'
for ($attempt = 1; $attempt -le $ProbeAttempts; $attempt++) {
    Write-Host "==> probe $attempt/$ProbeAttempts : $exePath"
    $state = Test-RunnerStarts -ExePath $exePath
    if ($state -eq 'missing') { throw "Runner not found: $exePath" }
    if ($state -eq 'ok') {
        Write-Host '    runner starts' -ForegroundColor Green
        break
    }
    if ($state -eq 'exited') {
        Write-Host '    runner started, then exited on its own' -ForegroundColor DarkYellow
        break
    }
    Write-Host '    blocked by Windows Application Control (no verdict yet)' -ForegroundColor Yellow
    if ($attempt -lt $ProbeAttempts) {
        Write-Host "    retrying in $ProbeDelaySeconds s ..."
        Start-Sleep -Seconds $ProbeDelaySeconds
    }
}
if ($state -eq 'blocked') {
    Write-SacGuidance
    exit 3
}

# --- Hand over to the interactive Flutter tool -------------------------------
$flutterArgs = @('run', '-d', 'windows')
if ($Mode -ne 'debug') { $flutterArgs += "--$Mode" }
Write-Host "==> flutter $($flutterArgs -join ' ')"
& flutter @flutterArgs
exit $LASTEXITCODE
