param (
    [Parameter()]
    [string]$OSDBProvider,

    [Parameter()]
    [string]$OSDBAuth,

    [Parameter()]
    [string]$OSDBServer,

    [Parameter()]
    [string]$OSDBCatalog,

    [Parameter()]
    [string]$OSDBSAUser,

    [Parameter()]
    [string]$OSDBSAPass,

    [Parameter()]
    [string]$OSDBSessionServer,

    [Parameter()]
    [string]$OSDBSessionCatalog,

    [Parameter()]
    [string]$OSDBSessionUser,

    [Parameter()]
    [string]$OSDBSessionPass,

    [Parameter()]
    [string]$OSDBAdminUser,

    [Parameter()]
    [string]$OSDBAdminPass,

    [Parameter()]
    [string]$OSDBRuntimeUser,

    [Parameter()]
    [string]$OSDBRuntimePass,

    [Parameter()]
    [string]$OSDBLogUser,

    [Parameter()]
    [string]$OSDBLogPass
)



# --- VARIABLES TO CHANGE ---- #

$LicensePath = "$PSScriptRoot\Sources\license.lic"
$InstallDir = "c:\OutSystems"

$ConfigToolArgs = @{
    InstallType         = 'Standalone'

    DBProvider          = $OSDBProvider         # SQL (for standard), SQLExpress, Azure SQL
    DBAuth              = $OSDBAuth             # SQL or Windows

    DBServer            = $OSDBServer
    DBCatalog           = $OSDBCatalog
    DBSAUser            = $OSDBSAUser              # For Windows auth you need to add the domain like DOMAIN\Username
    DBSAPass            = $OSDBSAPass

    DBSessionServer     = $OSDBSessionServer
    DBSessionCatalog    = $OSDBSessionCatalog
    DBSessionUser       = $OSDBSessionUser            # For Windows auth you need to add the domain like DOMAIN\Username
    DBSessionPass       = $OSDBSessionPass

    DBAdminUser         = $OSDBAdminUser              # For Windows auth you need to add the domain like DOMAIN\Username
    DBAdminPass         = $OSDBAdminPass
    DBRuntimeUser       = $OSDBRuntimeUser            # For Windows auth you need to add the domain like DOMAIN\Username
    DBRuntimePass       = $OSDBRuntimePass
    DBLogUser           = $OSDBLogUser               # For Windows auth you need to add the domain like DOMAIN\Username
    DBLogPass           = $OSDBLogPass
}

# --- VARIABLES TO CHANGE ---- #

# -- Import module from Powershell Gallery
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Remove-Module Outsystems.SetupTools -ErrorAction SilentlyContinue
Install-Module Outsystems.SetupTools -Force
Import-Module Outsystems.SetupTools

# -- Import module local
# Remove-Module Outsystems.SetupTools -ErrorAction SilentlyContinue
# Import-Module .\..\..\src\Outsystems.SetupTools

# -- Check HW and OS for compability
Test-OSPlatformHardwareReqs -Verbose
Test-OSPlatformSoftwareReqs -Verbose

# -- Install PreReqs
Install-OSPlatformServerPreReqs -Verbose

# -- Download and install OS Server and Dev environment from repo
Install-OSPlatformServer -Version 10.0.823.0 -InstallDir $InstallDir -Verbose
Install-OSDevEnvironment -Version 10.0.825.0 -InstallDir $InstallDir -Verbose

# -- Download and install OS Server and Dev environment from local source
# Install-OSPlatformServer -SourcePath "$PSScriptRoot\Sources" -Version 10.0.816.0 -Verbose
# Install-OSDevEnvironment -SourcePath "$PSScriptRoot\Sources" -Version 10.0.822.0 -Verbose

# -- Configure environment
Invoke-OSConfigurationTool -Verbose @ConfigToolArgs

# -- Install Service Center and SysComponents
Install-OSPlatformServiceCenter -Verbose
Install-OSPlatformSysComponents -Verbose

# -- Install license
Install-OSPlatformLicense -Path $LicensePath -Verbose

# -- Install Lifetime
Install-OSPlatformLifetime -Verbose

# -- System tunning
Set-OSPlatformPerformanceTunning -Verbose

# -- Security settings
Set-OSPlatformSecuritySettings -Verbose