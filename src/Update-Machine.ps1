function Update-Machine {
<#
.SYNOPSIS
Updates one or more objects from Cimi.


.DESCRIPTION
Updates one or more objects from Cimi.


.OUTPUTS
This Cmdlet returns one or more objects from Cimi. On failure it returns $null.


.INPUTS
See PARAMETER section for a description of input parameters.


.EXAMPLE
-DFTODO-

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Cimi/Client/Update-Machine/


.NOTES
See module manifest for required software versions and dependencies at: 
http://dfch.biz/biz/dfch/PS/Cimi/Client/biz.dfch.PS.Cimi.Client.psd1/


#>
[CmdletBinding(
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Cimi/Client/Update-Machine/'
	,
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'High'
	,
	DefaultParameterSetName = 'object'
)]
[OutputType([hashtable])]
Param 
(
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'id')]
	$Id
	,
	[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'object')]
	[Alias("Machine")]
	[IO.Swagger.Model.Machine] $InputObject
	,
	[Parameter(Mandatory = $false, Position = 1)]
	[switch] $Async
	,
	[Parameter(Mandatory = $false, Position = 2)]
	[switch] $WaitForCompletion
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'id')]
	[hashtable] $Properties
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
	Log-Debug $fn ("CALL. Id '{0}'; Async '{1}'." -f $Id, !!$Async) -fac 1;
	
	# Parameter validation
	Contract-Requires ($svc -is [biz.dfch.CS.Cimi.Client.BaseCimiClient]) "Connect to the server before using the Cmdlet";
		
	$invokeAction = 'UpdateMachine';
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
	
	if(!$PSCmdlet.ParameterSetName -eq 'object') 
	{
		$InputObjectTemp = New-Object System.Collections.ArrayList($Id.Count);
		foreach($Object in $Id)
		{
			Contract-Requires(!!$Id);
			Contract-Requires($Id -is [Guid]);
			Contract-Requires(![string]::IsNullOrWhiteSpace($Id));
			
			$ObjectTemp = $svc.GetMachine($Object);
			if(!$ObjectTemp)
			{
				$msg = "Id: Parameter validation FAILED. '{0}' is not a valid machine." -f $Object;
				Log-Error $fn $msg;
				$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Object;
				$PSCmdlet.ThrowTerminatingError($e);
			}
			$null = $InputObjectTemp.Add($ObjectTemp);
		}
		$InputObject = $InputObjectTemp.ToArray();
		Remove-Variable InputObjectTemp -ErrorAction:SilentlyContinue -Confirm:$false;
		Remove-Variable ObjectTemp -ErrorAction:SilentlyContinue -Confirm:$false;
	}
}

PROCESS 
{
	trap { Log-Exception $_; break; }
	
    # Default test variable for checking function response codes.
    [Boolean] $fReturn = $false;
    # Return values are always and only returned via OutputParameter.
    $OutputParameter = $null;

	$r = @();
	foreach($Object in $InputObject)
	{
		if(!$PSCmdlet.ParameterSetName -eq 'object') 
		{
			$machineProperties = New-Object biz.dfch.CS.Cimi.Client.MachineProperties($Object);
			foreach($propertyName in $Properties.Keys)
			{
				Log.Debug $f ("Set machine property [{0}] = '{1}'" -f $propertyName, $Properties.Item($propertyName));
				$machineProperties.$propertyName = $Properties.Item($propertyName);
			}
			$response = $svc.$invokeAction($Object, $machineProperties, $TotalAttempts, $BaseWaitingMilliseconds, $JobTimeOut);
		}
		else
		{
			$response = $svc.$invokeAction($Object, $TotalAttempts, $BaseWaitingMilliseconds, $JobTimeOut);
		}
		$r += $response;
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Update-Machine; } 
