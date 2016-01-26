function Stop-Machine {
<#
.SYNOPSIS
Performs a specific action to an Cimi object.


.DESCRIPTION
Performs a specific action to an Cimi object.


.OUTPUTS
This Cmdlet returns a Job (if async) or a boolean (machine action succeed). On failure it returns $null.


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
	DefaultParameterSetName = 'sync'
)]
[OutputType([hashtable])]
Param 
(
	[Parameter(Mandatory = $false, Position = 0)]
	$Id
	,
	[Parameter(Mandatory = $false, Position = 1)]
	[switch] $Force
	,
	[Parameter(Mandatory = $false, Position = 2, ParameterSetName = 'async')]
	[switch] $Async
	,
	[Parameter(Mandatory = $false, Position = 2, ParameterSetName = 'sync')]
	[switch] $WaitForCompletion
	,
	[Parameter(Mandatory = $false)]
	[int] $TotalAttempts = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).TotalAttempts
	,
	[Parameter(Mandatory = $false)]
	[int] $BaseWaitingMilliseconds = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).BaseWaitingMilliseconds
	,
	[Parameter(Mandatory = $false)]
	[int] $JobTimeOut = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).JobTimeOut
	,
	[Parameter(Mandatory = $false)]
	$svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Service
)

BEGIN 
{
	trap { Log-Exception $_; break; }
	
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug $fn ("CALL. Id '{0}'; Force '{1}'; Async '{2}'." -f $Id, !!$Force, !!$Async) -fac 1;
	
	# Parameter validation
	Contract-Requires ($svc -is [biz.dfch.CS.Cimi.Client.BaseCimiClient]) "Connect to the server before using the Cmdlet";
	Contract-Requires(!!$Id);
}

PROCESS 
{
	trap { Log-Exception $_; break; }
	
    # Default test variable for checking function response codes.
    [Boolean] $fReturn = $false;
    # Return values are always and only returned via OutputParameter.
    $OutputParameter = $null;
	
	$invokeAction = 'StopMachine';
	if($Async)
	{
		$invokeAction += 'Async';
	}
	
	if($Async -or !$WaitForCompletion) 
	{
		$TotalAttempts = 1;
		$BaseWaitingMilliseconds = 1;
		$JobTimeOut = 1;
	}

	$OutputParameter = $svc.$invokeAction($Id, !!$Force, $TotalAttempts, $BaseWaitingMilliseconds, $JobTimeOut);
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Stop-Machine; } 
