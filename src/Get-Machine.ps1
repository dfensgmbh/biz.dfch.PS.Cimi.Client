function Get-Machine {
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
Online Version: http://dfch.biz/biz/dfch/PS/Cimi/Client/Enter-Server/


.NOTES
See module manifest for required software versions and dependencies at: 
http://dfch.biz/biz/dfch/PS/Cimi/Client/biz.dfch.PS.Cimi.Client.psd1/


#>
[CmdletBinding(
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Cimi/Client/Enter-Server/'
	,
	DefaultParameterSetName = 'list'
)]
[OutputType([hashtable])]
Param 
(
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'id')]
	$Id
	,
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'list')]
	$SystemId
	,
	[Parameter(Mandatory = $false, Position = 1)]
	[switch] $WaitForCompletion
	,
	# Indicates to return all file information
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[switch] $ListAvailable
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
	Log-Debug $fn ("CALL. Id '{0}'; SystemId '{1}'." -f $Id, $SystemId) -fac 1;
	
	# Parameter validation
	Contract-Requires ($svc -is [biz.dfch.CS.Cimi.Client.BaseCimiClient]) "Connect to the server before using the Cmdlet";
	
	if(!$PSCmdlet.ParameterSetName -eq 'list') 
	{
		Contract-Requires(!!$Id);
	}
}

PROCESS 
{
	trap { Log-Exception $_; break; }
	
    # Default test variable for checking function response codes.
    [Boolean] $fReturn = $false;
    # Return values are always and only returned via OutputParameter.
    $OutputParameter = $null;
	
	$invokeAction = 'GetMachine';
	if($PSCmdlet.ParameterSetName -eq 'list') 
	{
		$invokeAction += 'Collection';
		$Id = $SystemId;
	}
	
	if(!$WaitForCompletion) 
	{
		$TotalAttempts = 1;
		$BaseWaitingMilliseconds = 1;
	}

	$OutputParameter = $svc.$invokeAction($Id, $TotalAttempts, $BaseWaitingMilliseconds);
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-Machine; } 
