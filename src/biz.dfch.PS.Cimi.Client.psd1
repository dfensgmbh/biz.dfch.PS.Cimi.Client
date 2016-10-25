#
# Module manifest for module 'biz.dfch.PS.Cimi.Client'
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'biz.dfch.PS.Cimi.Client.psm1'

# Version number of this module.
ModuleVersion = '2.2.0.20161025'

# ID used to uniquely identify this module
GUID = 'fbedfa51-f3cf-457c-9aa3-b998dc54d07b'

# Author of this module
Author = 'Ronald Rink'

# Company or vendor of this module
CompanyName = 'd-fens GmbH'

# Copyright statement for this module
Copyright = '(c) 2015-2016 d-fens GmbH. Distributed under Apache 2.0 license.'

# Description of the functionality provided by this module
Description = 'PowerShell module for the Cimi Framework and Middleware'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
DotNetFrameworkVersion = '4.5'

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(
	'biz.dfch.PS.System.Logging'
	,
	'biz.dfch.PS.System.Utilities'
)

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @(
	'biz.dfch.CS.Cimi.Client.dll'
	,
	'System.Net'
	,
	'System.Web'
	,
	'System.Web.Extensions'
)

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = @(
	'Import-Module.ps1'
)

# ModuleToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(
	'Enter-Server.ps1'
	,
	'Get-ModuleVariable.ps1'
	,
	'Stop-Machine.ps1'
	,
	'Start-Machine.ps1'
	,
	'Restart-Machine.ps1'
	,
	'Get-Machine.ps1'
	,
	'Get-System.ps1'
	,
	'Get-Job.ps1'
	,
	'Update-Machine.ps1'
	,
	'Get-Snapshot.ps1'
	,
	'Get-SnapshotTemplate.ps1'
	,
	'New-Snapshot.ps1'
)

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module.
# ModuleList = @()

# List of all files packaged with this module
FileList = @(
	'LICENSE'
	,
	'NOTICE'
	,
	'README.md'
	,
	'biz.dfch.CS.Cimi.Client.dll'
	,
	'biz.dfch.PS.Cimi.Client.xml'
	,
	'biz.dfch.CS.Cimi.Client.Model.dll'
	,
	'Newtonsoft.Json.dll'
	,
	'Newtonsoft.Json.xml'
	,
	'log4net.dll'
	,
	'log4net.xml'
	,
	'biz.dfch.CS.System.Utilities.dll'
	,
	'biz.dfch.CS.Scs.Cmp.ApiBroker.Client.dll'
	,
	'biz.dfch.CS.Cimi.Client.dll'
	,
	'Import-Module.ps1'
)

# Private data to pass to the module specified in RootModule/ModuleToProcess
PrivateData = @{

	PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @("dfch", "PowerShell", "Cimi", "Client")
		
        # A URL to the license for this module.
        LicenseUri = 'https://github.com/dfensgmbh/biz.dfch.PS.Cimi.Client/blob/master/LICENSE'
		
        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/dfensgmbh/biz.dfch.PS.Cimi.Client'
		
        # A URL to an icon representing this module.
        IconUri = 'https://raw.githubusercontent.com/dfensgmbh/biz.dfch.PS.Cimi.Client/master/logo-32x32.png'
		
        # ReleaseNotes of this module
        ReleaseNotes = '20161025
**Features**
* Updated biz.dfch.CS.Cimi client to version 2.2.0
* Installation base path is "$env:ProgramFiles\WindowsPowerShell\Modules" and can be manually set as input parameter'

    } 

	"MODULEVAR" = "biz_dfch_PS_Cimi_Client"
}

# HelpInfo URI of this module
HelpInfoURI = 'http://dfch.biz/biz/dfch/PS/Cimi/Client/'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
DefaultCommandPrefix = 'Cimi'

}

# 
# Copyright 2014-2016 d-fens GmbH
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
