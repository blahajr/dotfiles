if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$cfg = "$env:USERPROFILE\.config\christitus\config.json"

iex "& { $(irm https://christitus.com/win) } $(if (Test-Path $cfg) { \"-Config '$cfg'\" })"