[CmdletBinding()]
param(

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
    [string]$OSServerVersion='10.0.823.0',

    [Parameter()]
    [string]$OSServiceStudioVersion='10.0.825.0'

)
# -- Preference variables
$global:ErrorActionPreference = 'Stop'

# -- Script variables
$rebootNeeded = $false
$majorVersion = "$(([System.Version]$OSServerVersion).Major).$(([System.Version]$OSServerVersion).Minor)"

# -- Configuration tool base settings
$ConfigToolArgs = @{
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
}
# -- If controller or private key is specified, add them to the config tool parameters 
if ($OSController) { $ConfigToolArgs.Add('Controller',$OSController) }
if ($PrivateKey) { $ConfigToolArgs.Add('PrivateKey',$PrivateKey) }

# -- Version specific config tool parameters
switch ($majorVersion) {
    '10.0' 
    {
        # -- If its OS10, add the log db user
        $ConfigToolArgs.Add('DBLogUser',$OSDBLogUser)
        $ConfigToolArgs.Add('DBLogPass',$OSDBLogPass)
    }
    '11.0' 
    {
        # -- If its OS11 we can add the logging database settings. If not specified, the log DB will default to the platform database
        # -- Also, we can set rabbit settings. Going with the defaults for now
    }
}

# PS Logging
Start-Transcript -Path "C:\windows\temp\transcript0.txt" -Append | Out-Null

# -- Disable windows defender realtime scan
Set-MpPreference -DisableRealtimeMonitoring $true | Out-Null

# -- Import module from Powershell Gallery
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force  | Out-Null
Install-Module -Name Outsystems.SetupTools -Force | Out-Null
Import-Module -Name Outsystems.SetupTools -ArgumentList $true, 'AzureRM' | Out-Null

# -- Start logging
Set-OSInstallLog -Path $OSLogPath -File "InstallLog-$(get-date -Format 'yyyyMMddHHmmss').log" | Out-Null

# -- Check HW and OS for compability. Will throw if VM is not compatible
Test-OSServerHardwareReqs -MajorVersion $majorVersion | Out-Null
Test-OSServerSoftwareReqs -MajorVersion $majorVersion | Out-Null

# -- Install PreReqs
Install-OSServerPreReqs -MajorVersion "$(([System.Version]$OSServerVersion).Major).$(([System.Version]$OSServerVersion).Minor)" | Out-Null

# -- Download and install OS Server and Dev environment from repo
Install-OSServer -Version $OSServerVersion -InstallDir $OSInstallDir | Out-Null
Install-OSServiceStudio -Version $OSServiceStudioVersion -InstallDir $OSInstallDir | Out-Null

# -- If its OS11 we need to install RabbitMQ
switch ($majorVersion) {
    '11.0' 
    {
        # -- Install RabbitMQ if its OS11
        Install-OSRabbitMQ | Out-Null

        # -- Configure windows firewall with rabbit
        Set-OSServerWindowsFirewall -IncludeRabbitMQ | Out-Null
    }
    '10.0'
    {
        # -- Configure windows firewall without rabbit
        Set-OSServerWindowsFirewall | Out-Null
    }
}

# -- Disable IPv6
Disable-OSServerIPv6 | Out-Null

# -- Run config tool
Invoke-OSConfigurationTool @ConfigToolArgs | Out-Null

# -- If this is a frontend, disable the controller service and wait for the service center to be published by the controller before running the system tunning
if ($OSRole -eq "FE")
{
    Get-Service -Name "OutSystems Deployment Controller Service" | Stop-Service -WarningAction SilentlyContinue | Out-Null
    Set-Service -Name "OutSystems Deployment Controller Service" -StartupType "Disabled" | Out-Null

    while (-not $(Get-OSServerVersion -ErrorAction SilentlyContinue)) {
        Start-Sleep -s 15
    }
    Start-Sleep -s 15
} 
else 
{
    # -- If not a frontend install Service Center, SysComponents and license
    Install-OSPlatformServiceCenter | Out-Null
    Publish-OSPlatformSystemComponents | Out-Null
    Install-OSPlatformLicense | Out-Null
}

# -- Install Lifetime if role is LT
if ($OSRole -eq "LT")
{
    Publish-OSPlatformLifetime | Out-Null
}

# -- System tunning
Set-OSServerPerformanceTunning | Out-Null

# -- Security settings
Set-OSServerSecuritySettings | Out-Null

# -- Outputs the private key
Get-OSServerPrivateKey
