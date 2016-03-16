function New-Snapshot {
<#
.SYNOPSIS
Creates one or more objects from Cimi.


.DESCRIPTION
Creates one or more objects from Cimi.


.OUTPUTS
This Cmdlet returns one or more objects from Cimi. On failure it returns $null.


.INPUTS
See PARAMETER section for a description of input parameters.


.EXAMPLE
-DFTODO-

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Cimi/Client/New-Snapshot/


.NOTES
See module manifest for required software versions and dependencies at: 
http://dfch.biz/biz/dfch/PS/Cimi/Client/biz.dfch.PS.Cimi.Client.psd1/


#>
[CmdletBinding(
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Cimi/Client/New-Snapshot/'
	,
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'High'
	,
	DefaultParameterSetName = 'sync'
)]
[OutputType([hashtable])]
Param 
(
	[Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
	[Alias("Machine")]
	[Alias("Id")]
	$InputObject
	,
	[Parameter(Mandatory = $false, Position = 1)]
	[string] $Name
	,
	[Parameter(Mandatory = $false, Position = 2)]
	[string] $Description
	,
	[Parameter(Mandatory = $false, Position = 3)]
	[string] $TemplateId
	,
	[Parameter(Mandatory = $false, Position = 3)]
	[IO.Swagger.Model.CloudResourceTemplate] $Template
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'sync')]
	[Parameter(Mandatory = $false, ParameterSetName = 'async')]
	[switch] $Async = $false
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'asjob')]
	[switch] $StartJob = $false
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
	Log-Debug $fn ("CALL. Objects '{0}'." -f $InputObject.Count) -fac 1;
	
	# Parameter validation
	Contract-Requires ($svc -is [biz.dfch.CS.Cimi.Client.BaseCimiClient]) "Connect to the server before using the Cmdlet";
	Contract-Requires(!!$Template -or !!$TemplateId);
		
	$invokeAction = 'CreateSnapshot';
	if($Async)
	{
		$invokeAction += 'Async';
		$TotalAttempts = 1;
	} elseif($StartJob)
	{
		$invokeAction += 'StartJob';
		$TotalAttempts = 1;
	}
	
	if ( $PSBoundParameters.ContainsKey('TemplateId') )
	{
		$Template = Get-SnapshotTemplate -Id $TemplateId -svc $svc;
		Contract-Requires(!!$Template);
		Contract-Requires(1 -eq $Template.Count);
	}
	
	$InputObjectTemp = New-Object System.Collections.ArrayList($InputObject.Count);
	$ids = @();
	foreach($Object in $InputObject)
	{
		if($Object -isnot [IO.Swagger.Model.Machine])
		{
			$cimiId = [Guid]::Parse($Object);
			Contract-Requires(!!$cimiId);
			Contract-Requires($cimiId -is [Guid]);
			Contract-Requires(![string]::IsNullOrWhiteSpace($cimiId));
			
			$ObjectTemp = $svc.GetSnapshot($cimiId);
			Contract-Requires(!!$ObjectTemp) "Id: Parameter validation FAILED, not a valid Machine.";
			$null = $InputObjectTemp.Add($ObjectTemp);
			$ids += $ObjectTemp.Id.ToString();
		}
		else
		{
			$null = $InputObjectTemp.Add($Object);
			$ids += $Object.Id.ToString();
		}
	}
	$InputObject = $InputObjectTemp.ToArray();
	Remove-Variable InputObjectTemp -ErrorAction:SilentlyContinue -Confirm:$false;
	Remove-Variable ObjectTemp -ErrorAction:SilentlyContinue -Confirm:$false;
	Log-Debug $fn ("CALL. Ids [{0}]; Async '{1}'; AsJob '{2}'." -f ($ids -join ', '), !!$Async, !!$StartJob) -fac 1;
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
		if(!$StartJob)
		{
			$response = $svc.$invokeAction($Name, $Description, $Object.Id, $Template, $TotalAttempts, $BaseWaitingMilliseconds, $JobTimeOut);
		}
		else
		{
			$response = $svc.$invokeAction($Name, $Description, $Object.Id, $Template, $TotalAttempts, $BaseWaitingMilliseconds);
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function New-Snapshot; } 
