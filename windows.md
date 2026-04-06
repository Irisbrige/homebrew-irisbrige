# Windows Deployment Guide

[中文说明](./windows_CN.md)

This document explains how to deploy `irisbrige-edge` on Windows and keep it running as a Windows service.

It covers two approaches:

1. Deploy automatically with the repository PowerShell script.
2. Deploy manually with WinSW.

## Contents

- [Prerequisites](#prerequisites)
- [Option 1: Deploy with the Script](#option-1)
- [Open an elevated PowerShell session](#open-an-elevated-powershell-session)
- [Run the installer](#run-the-installer)
- [Default locations](#default-locations)
- [Default service settings](#default-service-settings)
- [Common parameters](#common-parameters)
- [Check service status and logs](#check-service-status-and-logs)
- [Additional environment variables](#additional-environment-variables)
- [Uninstall with the script](#uninstall-with-the-script)
- [Option 2: Manual Deployment](#option-2)
- [Detect the architecture](#detect-the-architecture)
- [Resolve the latest irisbrige-edge release](#resolve-the-latest-edge-release)
- [Resolve the latest WinSW release](#resolve-the-latest-winsw-release)
- [Download and extract files](#download-and-extract-files)
- [Install the files](#install-the-files)
- [Create the WinSW XML](#create-the-winsw-xml)
- [Install and start the service](#install-and-start-the-service)
- [Verify the service](#verify-the-service)
- [Remove temporary files](#remove-temporary-files)
- [Troubleshooting](#troubleshooting)

<a id="prerequisites"></a>
## Prerequisites

- Windows 10, Windows 11, or Windows Server.
- PowerShell 5.1 or newer.
- Administrator privileges.
- Internet access to GitHub releases.

If `irisbrige-edge` needs `codex.exe` at runtime:

- make sure `codex.exe` is already reachable on `PATH`, or
- pass `-CodexPath` to the installer script, or
- edit the generated WinSW XML and add the correct directory to `PATH`

<a id="option-1"></a>
## Option 1: Deploy with the Script

Script URL:

```powershell
https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/install-irisbrige-edge-windows.ps1
```

<a id="open-an-elevated-powershell-session"></a>
### 1. Open an elevated PowerShell session

Use "Run as Administrator".

<a id="run-the-installer"></a>
### 2. Run the installer

Run it directly from GitHub:

```powershell
$scriptUrl = "https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/install-irisbrige-edge-windows.ps1"
& ([ScriptBlock]::Create((Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing).Content))
```

The script automatically:

- detects whether the current Windows machine is `amd64` or `arm64`
- resolves the latest `irisbrige-edge` release from GitHub
- downloads the matching Windows zip asset
- resolves the latest WinSW release from GitHub
- prefers a native WinSW arm64 wrapper if one exists, otherwise falls back to `WinSW-x64.exe`
- extracts `irisbrige-edge.exe`
- installs the executable and WinSW wrapper
- writes the WinSW XML configuration
- installs and starts the Windows service

<a id="default-locations"></a>
### 3. Default locations

- Binary directory: `C:\Program Files\Irisbrige\irisbrige-edge`
- Data directory: `C:\ProgramData\Irisbrige\irisbrige-edge`
- Logs directory: `C:\ProgramData\Irisbrige\irisbrige-edge\logs`
- Wrapper executable: `C:\Program Files\Irisbrige\irisbrige-edge\irisbrige-edge-service.exe`
- Wrapper XML: `C:\Program Files\Irisbrige\irisbrige-edge\irisbrige-edge-service.xml`

<a id="default-service-settings"></a>
### 4. Default service settings

- Internal service id: `irisbrigeedge`
- Display name: `Irisbrige Edge`
- Service account: `LocalSystem`
- Start mode: automatic with delayed auto start

<a id="common-parameters"></a>
### 5. Common parameters

Example:

```powershell
$scriptUrl = "https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/install-irisbrige-edge-windows.ps1"
& ([ScriptBlock]::Create((Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing).Content)) `
  -ServiceId irisbrigeedge `
  -DisplayName "Irisbrige Edge" `
  -InstallDir "C:\Program Files\Irisbrige\irisbrige-edge" `
  -DataDir "C:\ProgramData\Irisbrige\irisbrige-edge" `
  -CodexPath "C:\Users\rose\AppData\Local\Programs\codex"
```

Supported parameters:

- `Repository`
- `WinSWRepository`
- `BinaryName`
- `ServiceId`
- `DisplayName`
- `Description`
- `InstallDir`
- `DataDir`
- `WrapperName`
- `ServiceAccount`
- `CodexPath`
- `AdditionalPath`

`ServiceAccount` currently supports:

- `LocalSystem`
- `LocalService`
- `NetworkService`

<a id="check-service-status-and-logs"></a>
### 6. Check service status and logs

Check the service:

```powershell
Get-Service -Name irisbrigeedge
```

Check the wrapper status:

```powershell
& "C:\Program Files\Irisbrige\irisbrige-edge\irisbrige-edge-service.exe" status
```

List log files:

```powershell
Get-ChildItem "C:\ProgramData\Irisbrige\irisbrige-edge\logs"
```

Follow logs:

```powershell
Get-Content "C:\ProgramData\Irisbrige\irisbrige-edge\logs\*.log" -Wait
```

<a id="additional-environment-variables"></a>
### 7. Additional environment variables

The script does not create a separate environment file.

If the service needs extra environment variables, edit:

```powershell
C:\Program Files\Irisbrige\irisbrige-edge\irisbrige-edge-service.xml
```

Add more entries like:

```xml
<env name="OPENAI_API_KEY" value="your-token" />
```

Then restart the service:

```powershell
& "C:\Program Files\Irisbrige\irisbrige-edge\irisbrige-edge-service.exe" restart
```

<a id="uninstall-with-the-script"></a>
### 8. Uninstall with the script

Uninstaller URL:

```powershell
https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/uninstall-irisbrige-edge-windows.ps1
```

Default behavior:

- removes the Windows service registration
- removes the install directory
- keeps the data directory

Run:

```powershell
$scriptUrl = "https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/uninstall-irisbrige-edge-windows.ps1"
& ([ScriptBlock]::Create((Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing).Content))
```

If you also want to remove the data directory and logs:

```powershell
$scriptUrl = "https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/uninstall-irisbrige-edge-windows.ps1"
& ([ScriptBlock]::Create((Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing).Content)) -RemoveData
```

<a id="option-2"></a>
## Option 2: Manual Deployment

These steps mirror the installer script, but everything is done manually.

### 1. Open an elevated PowerShell session

Use "Run as Administrator".

<a id="detect-the-architecture"></a>
### 2. Detect the architecture

```powershell
function Get-IrisbrigeWindowsArch {
  $bindingFlags = [System.Reflection.BindingFlags]::Public -bor [System.Reflection.BindingFlags]::Static

  try {
    $runtimeInfoType = [System.Runtime.InteropServices.RuntimeInformation]
  } catch {
    $runtimeInfoType = $null
  }

  if ($runtimeInfoType) {
    $osArchProperty = $runtimeInfoType.GetProperty("OSArchitecture", $bindingFlags)
    if ($osArchProperty) {
      switch ($osArchProperty.GetValue($null, $null).ToString()) {
        "X64"   { return "amd64" }
        "Arm64" { return "arm64" }
      }
    }
  }

  $hint = if ($env:PROCESSOR_ARCHITEW6432) {
    $env:PROCESSOR_ARCHITEW6432
  } else {
    $env:PROCESSOR_ARCHITECTURE
  }

  switch ($hint.ToUpperInvariant()) {
    "AMD64" { return "amd64" }
    "ARM64" { return "arm64" }
    default { throw "Unsupported architecture: $hint" }
  }
}

$arch = Get-IrisbrigeWindowsArch
$arch
```

<a id="resolve-the-latest-edge-release"></a>
### 3. Resolve the latest `irisbrige-edge` release

```powershell
$headers = @{
  Accept = "application/vnd.github+json"
  "User-Agent" = "irisbrige-edge-installer"
}

$edgeRelease = Invoke-RestMethod -Headers $headers -Uri "https://api.github.com/repos/Irisbrige/homebrew-irisbrige/releases/latest"
$edgeTag = $edgeRelease.tag_name
$edgeVersion = $edgeTag.TrimStart("v")
$edgeAssetName = "irisbrige-edge_${edgeVersion}_windows_${arch}.zip"
$edgeAsset = $edgeRelease.assets | Where-Object { $_.name -eq $edgeAssetName } | Select-Object -First 1

$edgeAsset.browser_download_url
```

<a id="resolve-the-latest-winsw-release"></a>
### 4. Resolve the latest WinSW release

```powershell
$winswRelease = Invoke-RestMethod -Headers $headers -Uri "https://api.github.com/repos/winsw/winsw/releases/latest"

$winswAssetCandidates = if ($arch -eq "arm64") {
  @("WinSW-arm64.exe", "WinSW-x64.exe")
} else {
  @("WinSW-x64.exe")
}

$winswAsset = foreach ($candidate in $winswAssetCandidates) {
  $match = $winswRelease.assets | Where-Object { $_.name -eq $candidate } | Select-Object -First 1
  if ($match) {
    $match
    break
  }
}

$winswAsset.browser_download_url
```

<a id="download-and-extract-files"></a>
### 5. Download and extract files

```powershell
$installDir = "C:\Program Files\Irisbrige\irisbrige-edge"
$dataDir = "C:\ProgramData\Irisbrige\irisbrige-edge"
$logsDir = Join-Path $dataDir "logs"
$tempDir = Join-Path $env:TEMP ("irisbrige-edge-install-" + [guid]::NewGuid().ToString("N"))

New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

$edgeZip = Join-Path $tempDir "irisbrige-edge.zip"
$edgeExtractDir = Join-Path $tempDir "edge"
$winswExe = Join-Path $tempDir $winswAsset.name

Invoke-WebRequest -Headers $headers -Uri $edgeAsset.browser_download_url -OutFile $edgeZip -UseBasicParsing
Invoke-WebRequest -Headers $headers -Uri $winswAsset.browser_download_url -OutFile $winswExe -UseBasicParsing

Expand-Archive -Path $edgeZip -DestinationPath $edgeExtractDir -Force
$edgeExe = Get-ChildItem -Path $edgeExtractDir -Recurse -Filter "irisbrige-edge.exe" -File | Select-Object -First 1
```

<a id="install-the-files"></a>
### 6. Install the files

```powershell
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
New-Item -ItemType Directory -Path $logsDir -Force | Out-Null

Copy-Item $edgeExe.FullName (Join-Path $installDir "irisbrige-edge.exe") -Force
Copy-Item $winswExe (Join-Path $installDir "irisbrige-edge-service.exe") -Force
```

<a id="create-the-winsw-xml"></a>
### 7. Create the WinSW XML

The Windows service internal id below is `irisbrigeedge`.

```powershell
$machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$servicePath = "$installDir;$machinePath"
$xmlPath = Join-Path $installDir "irisbrige-edge-service.xml"

@"
<service>
  <id>irisbrigeedge</id>
  <name>Irisbrige Edge</name>
  <description>Irisbrige Edge background service</description>
  <executable>%BASE%\irisbrige-edge.exe</executable>
  <arguments>server</arguments>
  <workingdirectory>%BASE%</workingdirectory>
  <startmode>Automatic</startmode>
  <delayedAutoStart/>
  <env name="PATH" value="$servicePath" />
  <logpath>$logsDir</logpath>
  <log mode="roll" />
  <onfailure action="restart" delay="10 sec" />
  <serviceaccount>
    <user>LocalSystem</user>
  </serviceaccount>
</service>
"@ | Set-Content -Path $xmlPath -Encoding ASCII
```

If `codex.exe` is not on the machine PATH, add its directory into `$servicePath` before writing the XML.

<a id="install-and-start-the-service"></a>
### 8. Install and start the service

```powershell
$wrapper = Join-Path $installDir "irisbrige-edge-service.exe"

& $wrapper install
& $wrapper start
```

<a id="verify-the-service"></a>
### 9. Verify the service

```powershell
Get-Service -Name irisbrigeedge
& $wrapper status
Get-ChildItem $logsDir
```

<a id="remove-temporary-files"></a>
### 10. Remove temporary files

```powershell
Remove-Item -Path $tempDir -Recurse -Force
```

<a id="troubleshooting"></a>
## Troubleshooting

### The service starts but exits immediately

Check:

```powershell
Get-ChildItem "C:\ProgramData\Irisbrige\irisbrige-edge\logs"
Get-Content "C:\ProgramData\Irisbrige\irisbrige-edge\logs\*.log" -Tail 200
```

### `codex.exe` cannot be found

Rerun the installer with `-CodexPath`, or edit the WinSW XML and add the correct directory to the `PATH` environment entry.

### The service exists but needs to be reinstalled

```powershell
& "C:\Program Files\Irisbrige\irisbrige-edge\irisbrige-edge-service.exe" stop
& "C:\Program Files\Irisbrige\irisbrige-edge\irisbrige-edge-service.exe" uninstall
```

Then run the installer again.

### You want to remove the service completely

Use the uninstaller script:

```powershell
$scriptUrl = "https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/uninstall-irisbrige-edge-windows.ps1"
& ([ScriptBlock]::Create((Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing).Content))
```

Or remove everything including the data directory:

```powershell
$scriptUrl = "https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/uninstall-irisbrige-edge-windows.ps1"
& ([ScriptBlock]::Create((Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing).Content)) -RemoveData
```
