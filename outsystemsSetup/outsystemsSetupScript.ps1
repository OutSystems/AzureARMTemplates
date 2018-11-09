﻿[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('DC', 'FE', 'LT')]
    [string]$OSRole,
    
    [Parameter()]
    [string]$OSDBAuth = 'Database Authentication',
    [string]$OSController,
    [string]$OSPrivateKey,
    [string]$OSDBServer,
    [string]$OSDBLogServer,
    [string]$OSDBSessionServer,
    [string]$OSDBSAUser,
    [string]$OSDBSAPass,
    [string]$OSDBSALogUser,
    [string]$OSDBSALogPass,
    [string]$OSDBSASessionUser,
    [string]$OSDBSASessionPass,
    [string]$OSDBCatalog,
    [string]$OSDBLogCatalog,
    [string]$OSDBSessionCatalog,
    [string]$OSDBAdminUser,
    [string]$OSDBAdminPass,
    [string]$OSDBRuntimeUser,
    [string]$OSDBRuntimePass,
    [string]$OSDBLogUser,
    [string]$OSDBLogPass,
    [string]$OSDBSessionUser,
    [string]$OSDBSessionPass,
    [string]$OSRabbitMQHost,
    [string]$OSRabbitMQUser,
    [string]$OSRabbitMQPass,
    [string]$OSRabbitMQVHost,
    [string]$OSInstallDir,
    [string]$OSServerVersion,
    [string]$OSServiceStudioVersion
)

# -- Preference variables
$ErrorActionPreference = 'Stop'

# Start PS Logging
Start-Transcript -Path "$Env:Windir\temp\OutSystemsSetupScript.log" -Append | Out-Null

# -- Import module from Powershell Gallery
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
Install-Module -Name Outsystems.SetupTools -Force | Out-Null
Import-Module -Name Outsystems.SetupTools -ArgumentList $true, 'AzureRM' | Out-Null

# -- Script variables
$rebootNeeded = $false
$majorVersion = "$(([System.Version]$OSServerVersion).Major).$(([System.Version]$OSServerVersion).Minor)"

# Initialize and format the data disk
Get-Disk 2 | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -UseMaximumSize -MbrType IFS -driveletter F | Format-Volume -FileSystem NTFS -Confirm:$false | Out-Null
$null = Get-PSDrive

# -- Disable windows defender realtime scan
Set-MpPreference -DisableRealtimeMonitoring $true | Out-Null

# -- Check HW and OS for compability. Will throw if VM is not compatible
Test-OSServerHardwareReqs -MajorVersion $majorVersion -ErrorAction Stop | Out-Null
Test-OSServerSoftwareReqs -MajorVersion $majorVersion -ErrorAction Stop | Out-Null

# -- Install PreReqs
Install-OSServerPreReqs -MajorVersion "$(([System.Version]$OSServerVersion).Major).$(([System.Version]$OSServerVersion).Minor)" -ErrorAction Stop | Out-Null

# -- Download and install OS Server and Dev environment from repo
Install-OSServer -Version $OSServerVersion -InstallDir $OSInstallDir -ErrorAction Stop | Out-Null
Install-OSServiceStudio -Version $OSServiceStudioVersion -InstallDir $OSInstallDir -ErrorAction Stop | Out-Null

# -- Disable IPv6
Disable-OSServerIPv6 -ErrorAction Stop | Out-Null

# -- Start a new config
if ($OSPrivateKey)
{
    New-OSServerConfig -DatabaseProvider 'SQL' -PrivateKey $OSPrivateKey -ErrorAction Stop | Out-Null
}
else
{
    New-OSServerConfig -DatabaseProvider 'SQL' -ErrorAction Stop | Out-Null
}

# -- Configure common settings to both versions
# **** Platform Database ****
Set-OSServerConfig -SettingSection 'PlatformDatabaseConfiguration' -Setting 'UsedAuthenticationMode' -Value $OSDBAuth -ErrorAction Stop | Out-Null #!!!
Set-OSServerConfig -SettingSection 'PlatformDatabaseConfiguration' -Setting 'Server' -Value $OSDBServer -ErrorAction Stop | Out-Null
Set-OSServerConfig -SettingSection 'PlatformDatabaseConfiguration' -Setting 'Catalog' -Value $OSDBCatalog -ErrorAction Stop | Out-Null
Set-OSServerConfig -SettingSection 'PlatformDatabaseConfiguration' -Setting 'AdminUser' -Value $OSDBAdminUser -ErrorAction Stop | Out-Null
Set-OSServerConfig -SettingSection 'PlatformDatabaseConfiguration' -Setting 'AdminPassword' -Value $OSDBAdminPass -ErrorAction Stop | Out-Null
Set-OSServerConfig -SettingSection 'PlatformDatabaseConfiguration' -Setting 'RuntimeUser' -Value $OSDBRuntimeUser -ErrorAction Stop | Out-Null
Set-OSServerConfig -SettingSection 'PlatformDatabaseConfiguration' -Setting 'RuntimePassword' -Value $OSDBRuntimePass -ErrorAction Stop | Out-Null
# **** Session Database ****
Set-OSServerConfig -SettingSection 'SessionDatabaseConfiguration' -Setting 'UsedAuthenticationMode' -Value $OSDBAuth -ErrorAction Stop | Out-Null #!!!
Set-OSServerConfig -SettingSection 'SessionDatabaseConfiguration' -Setting 'Server' -Value $OSDBSessionServer -ErrorAction Stop | Out-Null
Set-OSServerConfig -SettingSection 'SessionDatabaseConfiguration' -Setting 'Catalog' -Value $OSDBSessionCatalog -ErrorAction Stop | Out-Null
Set-OSServerConfig -SettingSection 'SessionDatabaseConfiguration' -Setting 'SessionUser' -Value $OSDBSessionUser -ErrorAction Stop | Out-Null
Set-OSServerConfig -SettingSection 'SessionDatabaseConfiguration' -Setting 'SessionPassword' -Value $OSDBSessionPass -ErrorAction Stop | Out-Null
# **** Service config ****
Set-OSServerConfig -SettingSection 'ServiceConfiguration' -Setting 'CompilerServerHostname' -Value $OSController -ErrorAction Stop | Out-Null

# -- Configure platform according to major version
switch ($majorVersion)
{
    '11.0'
    {
        # -- Configure version specific platform settings
        # **** Cache invalidation service config ****
        Set-OSServerConfig -SettingSection 'CacheInvalidationConfiguration' -Setting 'ServiceHost' -Value $OSRabbitMQHost -ErrorAction Stop | Out-Null
        Set-OSServerConfig -SettingSection 'CacheInvalidationConfiguration' -Setting 'ServiceUsername' -Value $OSRabbitMQUser -ErrorAction Stop | Out-Null
        Set-OSServerConfig -SettingSection 'CacheInvalidationConfiguration' -Setting 'ServicePassword' -Value $OSRabbitMQPass -ErrorAction Stop | Out-Null
        Set-OSServerConfig -SettingSection 'CacheInvalidationConfiguration' -Setting 'VirtualHost' -Value $OSRabbitMQVHost -ErrorAction Stop | Out-Null

        # **** Logging database ****
        Set-OSServerConfig -SettingSection 'LoggingDatabaseConfiguration' -Setting 'UsedAuthenticationMode' -Value $OSDBAuth -ErrorAction Stop | Out-Null #!!!
        Set-OSServerConfig -SettingSection 'LoggingDatabaseConfiguration' -Setting 'Server' -Value $OSDBLogServer -ErrorAction Stop | Out-Null
        Set-OSServerConfig -SettingSection 'LoggingDatabaseConfiguration' -Setting 'Catalog' -Value $OSDBLogCatalog -ErrorAction Stop | Out-Null
        Set-OSServerConfig -SettingSection 'LoggingDatabaseConfiguration' -Setting 'AdminUser' -Value $OSDBAdminUser -ErrorAction Stop | Out-Null
        Set-OSServerConfig -SettingSection 'LoggingDatabaseConfiguration' -Setting 'AdminPassword' -Value $OSDBAdminPass -ErrorAction Stop | Out-Null
        Set-OSServerConfig -SettingSection 'LoggingDatabaseConfiguration' -Setting 'RuntimeUser' -Value $OSDBRuntimeUser -ErrorAction Stop | Out-Null
        Set-OSServerConfig -SettingSection 'LoggingDatabaseConfiguration' -Setting 'RuntimePassword' -Value $OSDBRuntimePass -ErrorAction Stop | Out-Null

        # -- Configure windows firewall with rabbit
        Set-OSServerWindowsFirewall -IncludeRabbitMQ -ErrorAction Stop | Out-Null
    }
    '10.0'
    {
        # -- Configure version specific platform settings
        # **** Logging database ****
        Set-OSServerConfig -SettingSection 'PlatformDatabaseConfiguration' -Setting 'LogUser' -Value $OSDBLogUser -ErrorAction Stop | Out-Null
        Set-OSServerConfig -SettingSection 'PlatformDatabaseConfiguration' -Setting 'LogPassword' -Value $OSDBLogPass -ErrorAction Stop | Out-Null

        # -- Configure windows firewall without rabbit
        Set-OSServerWindowsFirewall -ErrorAction Stop | Out-Null
    }
}

# -- If this is a frontend, disable the controller service and wait for the service center to be published by the controller before running the system tunning
if ($OSRole -eq "FE")
{
    Get-Service -Name "OutSystems Deployment Controller Service" | Stop-Service -WarningAction SilentlyContinue | Out-Null
    Set-Service -Name "OutSystems Deployment Controller Service" -StartupType "Disabled" | Out-Null

    while (-not $(Get-OSServerVersion -ErrorAction SilentlyContinue))
    {
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

if ($OSRole -ne "FE")
{
    # -- System tunning
    Set-OSServerPerformanceTunning | Out-Null

    # -- Security settings
    Set-OSServerSecuritySettings | Out-Null
}

# -- Outputs the private key
Get-OSServerPrivateKey
