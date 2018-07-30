[CmdletBinding()]
Param(

    [Parameter()]
    [string]$OSRole,

    [Parameter()]
    [string]$OSController,

    [Parameter()]
    [string]$OSPrivateKey,

    [Parameter()]
    [string]$OSLogPath="$Env:Windir\Temp\OutsystemsInstall",

    [Parameter()]
    [ValidateSet('SQL','SQLExpress','AzureSQL')]
    [string]$OSDBProvider='SQL',

    [Parameter()]
    [ValidateSet('SQL','Windows')]
    [string]$OSDBAuth='SQL',

    [Parameter(Mandatory=$true)]
    [string]$OSDBServer,

    [Parameter()]
    [string]$OSDBCatalog='outsystems',

    [Parameter(Mandatory=$true)]
    [string]$OSDBSAUser,

    [Parameter(Mandatory=$true)]
    [string]$OSDBSAPass,

    [Parameter(Mandatory=$true)]
    [string]$OSDBSessionServer,

    [Parameter()]
    [string]$OSDBSessionCatalog='osSession',

    [Parameter()]
    [string]$OSDBSessionUser='OSSTATE',

    [Parameter(Mandatory=$true)]
    [string]$OSDBSessionPass,

    [Parameter()]
    [string]$OSDBAdminUser='OSADMIN',

    [Parameter()]
    [string]$OSDBAdminPass,

    [Parameter()]
    [string]$OSDBRuntimeUser='OSRUNTIME',

    [Parameter(Mandatory=$true)]
    [string]$OSDBRuntimePass,

    [Parameter()]
    [string]$OSDBLogUser='OSLOG',

    [Parameter(Mandatory=$true)]
    [string]$OSDBLogPass,

    [Parameter()]
    [string]$OSInstallDir="$Env:ProgramFiles\OutSystems",

    [Parameter()]
    [string]$OSLicensePath,

    [Parameter()]
    [string]$OSPlatformVersion='10.0.823.0',

    [Parameter()]
    [string]$OSDevEnvironmentVersion='10.0.825.0'

)

# -- Configuration tool variables
$ConfigToolArgs = @{

    Controller          = $OSController
    PrivateKey          = $OSPrivateKey

    DBProvider          = $OSDBProvider
    DBAuth              = $OSDBAuth

    DBServer            = $OSDBServer
    DBCatalog           = $OSDBCatalog
    DBSAUser            = $OSDBSAUser
    DBSAPass            = $OSDBSAPass

    DBSessionServer     = $OSDBSessionServer
    DBSessionCatalog    = $OSDBSessionCatalog
    DBSessionUser       = $OSDBSessionUser
    DBSessionPass       = $OSDBSessionPass

    DBAdminUser         = $OSDBAdminUser
    DBAdminPass         = $OSDBAdminPass
    DBRuntimeUser       = $OSDBRuntimeUser
    DBRuntimePass       = $OSDBRuntimePass
    DBLogUser           = $OSDBLogUser
    DBLogPass           = $OSDBLogPass
}

# -- Stop on any error
$ErrorActionPreference = "Stop"

# -- Disable windows defender realtime scan
Set-MpPreference -DisableRealtimeMonitoring $true | Out-Null

# -- Import module from Powershell Gallery
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force  | Out-Null
Remove-Module Outsystems.SetupTools -ErrorAction SilentlyContinue | Out-Null
Install-Module Outsystems.SetupTools -Force | Out-Null
Import-Module Outsystems.SetupTools | Out-Null

# -- Start logging
Set-OSInstallLog -Path $OSLogPath -File "InstallLog-$(get-date -Format 'yyyyMMddHHmmss').log" | Out-Null

# -- Check HW and OS for compability
Test-OSServerHardwareReqs | Out-Null
Test-OSServerSoftwareReqs | Out-Null

# -- Install PreReqs
Install-OSServerPreReqs -MajorVersion "$(([System.Version]$OSPlatformVersion).Major).$(([System.Version]$OSPlatformVersion).Minor)" | Out-Null

# -- Download and install OS Server and Dev environment from repo
Install-OSPlatformServer -Version $OSPlatformVersion -InstallDir $OSInstallDir | Out-Null
Install-OSDevEnvironment -Version $OSDevEnvironmentVersion -InstallDir $OSInstallDir | Out-Null

# -- Configure windows firewall
Set-OSServerWindowsFirewall | Out-Null

# -- Disable IPv6
Disable-OSIPv6 | Out-Null

# -- If this is a frontend, wait for the controller to become available
If ($OSRole -eq "FE"){
    While ( -not $(Get-OSPlatformVersion -Host $ConfigToolArgs.Controller -ErrorAction SilentlyContinue ) ) {
#       Write-Output "Waiting for the controller $($ConfigToolArgs.Controller)"
        Start-Sleep -s 15
    }
#   Write-Output "Controller $($ConfigToolArgs.Controller) available. Waiting more 15 seconds for full initialization"
    Start-Sleep -s 15
}

# -- Run config tool
Invoke-OSConfigurationTool @ConfigToolArgs | Out-Null

# -- If this is a frontend, disable the controller service and wait for the service center to be published by the controller before running the system tunning
If ($OSRole -eq "FE"){

    Get-Service -Name "OutSystems Deployment Controller Service" | Stop-Service -WarningAction SilentlyContinue | Out-Null
    Set-Service -Name "OutSystems Deployment Controller Service" -StartupType "Disabled" | Out-Null

    While ( -not $(Get-OSPlatformVersion -ErrorAction SilentlyContinue) ) {
#        Write-Output "Waiting for service center to be published"
        Start-Sleep -s 15
    }
#    Write-Output "Service Center available. Waiting more 15 seconds for full initialization"
    Start-Sleep -s 15
} Else {
    # -- If not a frontend install Service Center, SysComponents and license
    Install-OSPlatformServiceCenter | Out-Null
    Publish-OSPlatformSystemComponents | Out-Null
    Install-OSPlatformLicense -Path $OSLicensePath | Out-Null
}

# -- Install Lifetime if role is LT
If ($OSRole -eq "LT"){
    Publish-OSPlatformLifetime | Out-Null
}

# -- System tunning
Set-OSPlatformPerformanceTunning | Out-Null

# -- Security settings
Set-OSServerSecuritySettings | Out-Null

# -- Outputs the private key
Get-OSPlatformServerPrivateKey
