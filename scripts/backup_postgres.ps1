<#!
.SYNOPSIS
Creates a compressed, timestamped PostgreSQL backup without storing credentials.

.DESCRIPTION
Uses the standard PG* environment variables (PGHOST, PGPORT, PGDATABASE,
PGUSER and PGPASSWORD) already supplied by the operator or secret manager.
It does not set, print, or persist passwords. The resulting custom-format
archive is intended for a separately encrypted, access-controlled backup store.

Run only against a database you are authorised to back up:
  .\scripts\backup_postgres.ps1
#>
[CmdletBinding()]
param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\database\backups')
)

$required = 'PGHOST', 'PGDATABASE', 'PGUSER'
$missing = $required | Where-Object { [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($_)) }
if ($missing) {
    throw "Missing required PostgreSQL environment variable(s): $($missing -join ', ')."
}

$pgDump = Get-Command pg_dump -ErrorAction SilentlyContinue
if ($null -eq $pgDump) {
    throw 'pg_dump was not found on PATH. Install PostgreSQL client tools or add their bin directory to PATH.'
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$database = [Environment]::GetEnvironmentVariable('PGDATABASE')
$target = Join-Path $OutputDirectory ("ecosusrural-$database-$stamp.dump")

& $pgDump.Source --format=custom --file=$target --no-owner --no-privileges
if ($LASTEXITCODE -ne 0) {
    throw "pg_dump failed with exit code $LASTEXITCODE."
}

Write-Output "Backup created: $target"
Write-Output 'Store this archive in encrypted off-host storage and perform a separate, authorised restore rehearsal.'
