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

# -- Disable windows defender realtime scan
Set-MpPreference -DisableRealtimeMonitoring $true

# -- Import module from Powershell Gallery
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Remove-Module Outsystems.SetupTools -ErrorAction SilentlyContinue
Install-Module Outsystems.SetupTools -Force
Import-Module Outsystems.SetupTools

# -- Start logging
Start-Transcript -Path "$OSLogPath\InstallLog-$(get-date -Format 'yyyyMMddHHmmss').log" -Force

# -- Check HW and OS for compability
Test-OSServerHardwareReqs -Verbose
Test-OSServerSoftwareReqs -Verbose

# -- Install PreReqs
Install-OSPlatformServerPreReqs -Verbose

# -- Download and install OS Server and Dev environment from repo
Install-OSPlatformServer -Version $OSPlatformVersion -InstallDir $OSInstallDir -Verbose

# -- Configure environment
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
#Sleep here 10 seconds to avoid the error machine.config is being used by another process.
Invoke-OSConfigurationTool -Verbose @ConfigToolArgs

# -- Configure windows firewall
Set-OSServerWindowsFirewall -Verbose

# -- Install Service Center, SysComponents and license if not frontend
If ($OSRole -ne "FE") {
    Install-OSPlatformServiceCenter -Verbose
    Install-OSPlatformSysComponents -Verbose
    Install-OSPlatformLicense -Path $OSLicensePath -Verbose
}

# -- Install Lifetime
If ($OSRole -eq "LT") {
    Publish-OSPlatformLifetime -Verbose    
}

# -- Download and install dev environment
Install-OSDevEnvironment -Version $OSDevEnvironmentVersion -InstallDir $OSInstallDir -Verbose

# -- System tunning
Set-OSPlatformPerformanceTunning -Verbose

# -- Security settings
Set-OSPlatformSecuritySettings -Verbose

# -- Stop logging
Stop-Transcript