function Get-System {
<#
.SYNOPSIS
Retrieves one or more objects from Cimi.


.DESCRIPTION
Retrieves one or more objects from Cimi.


.OUTPUTS
This Cmdlet returns one or more objects from Cimi. On failure it returns $null.


.INPUTS
See PARAMETER section for a description of input parameters.


.EXAMPLE
-DFTODO-

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Cimi/Client/Get-System/


.NOTES
See module manifest for required software versions and dependencies at: 
http://dfch.biz/biz/dfch/PS/Cimi/Client/biz.dfch.PS.Cimi.Client.psd1/


#>
[CmdletBinding(
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Cimi/Client/Get-System/'
	,
	DefaultParameterSetName = 'list'
)]
Param 
(
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'id')]
	$Id
	,
	[Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'name')]
	$Name
	,
	[Parameter(Mandatory = $false, Position = 2, ParameterSetName = 'list')]
	$ParentId
	,
	# Indicates to return all file information
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[switch] $ListAvailable
	,
	[Parameter(Mandatory = $false)]
	$TenantId
	,
	[Parameter(Mandatory = $false)]
	[int] $TotalAttempts = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).TotalAttempts
	,
	[Parameter(Mandatory = $false)]
	[int] $BaseWaitingMilliseconds = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).BaseWaitingMilliseconds
	,
	[Parameter(Mandatory = $false)]
	$svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Service
)

BEGIN 
{
	trap { Log-Exception $_; break; }
	
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug $fn ("CALL. Id '{0}' Name '{1}'; ParentId '{2}'." -f $Id, $Name, $ParentId) -fac 1;
	
	# Parameter validation
	Contract-Requires ($svc -is [biz.dfch.CS.Cimi.Client.BaseCimiClient]) "Connect to the server before using the Cmdlet";
	
	if($PSCmdlet.ParameterSetName -ne 'list') 
	{
		Contract-Requires(!!$Id -or !!$Name);
	}
	
	$invokeAction = 'GetSystem';
	$collectionName = 'Systems';
	if($PSCmdlet.ParameterSetName -ne 'id') 
	{
		$invokeAction += 'Collection';
		$Id = $ParentId;
	}
	
    if($PSBoundParameters.ContainsKey('TenantId'))
    {
		$svc.TenantId = $TenantId;
	}
}

PROCESS 
{
	trap { Log-Exception $_; break; }
	
    # Default test variable for checking function response codes.
    [Boolean] $fReturn = $false;
    # Return values are always and only returned via OutputParameter.
    $OutputParameter = $null;

	$r = $svc.$invokeAction($Id, $TotalAttempts, $BaseWaitingMilliseconds);
	if($PSCmdlet.ParameterSetName -eq 'name') 
	{
		$r = $r.$collectionName | ? Name -eq $Name;
	}
	$OutputParameter = $r;
	$fReturn = $true;
}

END 
{

	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
	
	# Return values are always and only returned via OutputParameter.
	return $OutputParameter;

} 

}

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-System; } 
