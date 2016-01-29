function Enter-Server {
<#
.SYNOPSIS
Performs a login to an Cimi server.


.DESCRIPTION
Performs a login to an Cimi server. 

This is the first Cmdlet to be executed and required for all other Cmdlets of this module. It creates service references to the routers of the application.


.OUTPUTS
This Cmdlet returns a CimiClient. On failure it returns $null.


.INPUTS
See PARAMETER section for a description of input parameters.


.EXAMPLE
$svc = Enter-Server;
$svc

AccessRefreshToken                 : 11111111-1111-1111-1111-111111111111
OAuthBaseUrl                       : https://cimi/openam/oauth2
ApiBrokerBaseUrl                   : https://cimi
OAuthClientId                      : ClientId
OAuthClientSecret                  : ClientSecret
TenantId                           : 11111111-1111-1111-1111-111111111111
TotalAttempts                      : 5
BaseWaitIntervalMilliseconds       : 5000
JobTotalAttempts                   : 5
BaseJobWaitIntervalMilliseconds    : 5000
BaseJobPollingInbervalMilliseconds : 5000
JobTimeOut                         : 3600000
IsLoggedIn                         : True

Perform a login to an Cimi server with default credentials (current user) and against server defined within module configuration xml file.


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Cimi/Client/Enter-Server/


.NOTES
See module manifest for required software versions and dependencies at: 
http://dfch.biz/biz/dfch/PS/Cimi/Client/biz.dfch.PS.Cimi.Client.psd1/


#>
[CmdletBinding(
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Cimi/Client/Enter-Server/'
	,
	DefaultParameterSetName = 'OAuthClientCred'
)]
[OutputType([hashtable])]
Param 
(
	# [Optional] The OAuthBaseUrl such as 'https://cimi/'. If you do not 
	# specify this value it is taken from the module configuration file.
	[Parameter(Mandatory = $false, Position = 0)]
	[Uri] $OAuthBaseUrl = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).OAuthBaseUrl
	,
	# [Optional] The ApiBrokerBaseUrl such as 'https://cimiapibroker/'. If you do not 
	# specify this value it is taken from the module configuration file.
	[Parameter(Mandatory = $false, Position = 1)]
	[Uri] $ApiBrokerBaseUrl = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).ApiBrokerBaseUrl
	,
	# Encrypted credentials as [System.Management.Automation.PSCredential] with 
	# which to perform login. Default is credential as specified in the module 
	# configuration file.
	[Parameter(Mandatory = $false, Position = 2, ParameterSetName = 'OAuthClientCred')]
	[alias("cred")]
	$Credential = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Credential
	,
	[Parameter(Mandatory = $false, Position = 2, ParameterSetName = 'OAuthClientSecrect')]
	[string] $OAuthClientId
	,
	[Parameter(Mandatory = $false, Position = 3, ParameterSetName = 'OAuthClientSecrect')]
	[string] $OAuthClientSecret
	,
	[Parameter(Mandatory = $false, Position = 4)]
	[string] $AccessRefreshToken = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).AccessRefreshToken
	,
	[Parameter(Mandatory = $false, Position = 5)]
	$TenantId = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).TenantId
	,
	[Parameter(Mandatory = $false, Position = 6)]
	[int] $TotalAttempts = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).TotalAttempts
	,
	[Parameter(Mandatory = $false, Position = 7)]
	[int] $BaseWaitingMilliseconds = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).BaseWaitingMilliseconds
	,
	[Parameter(Mandatory = $false, Position = 8)]
	[int] $JobTimeOut = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).JobTimeOut
	,
	[Parameter(Mandatory = $false, Position = 9)]
	$CimiVersion = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).CimiVersion
)

Begin 
{
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug $fn ("CALL. OAuthBaseUrl '{0}'; ApiBrokerBaseUrl '{1}'. Username '{2}'" -f $OAuthBaseUrl, $ApiBrokerBaseUrl, $Credential.Username ) -fac 1;
}
# Begin 

Process 
{

[boolean] $fReturn = $false;

try 
{
	# Parameter validation
	Contract-Assert(!!$AccessRefreshToken);
	
	if($PSCmdlet.ParameterSetName -eq 'OAuthClientCred') 
	{
		Contract-Assert(!!$Credential.UserName);
		$OAuthClientId = $Credential.GetNetworkCredential().Username;
		$OAuthClientSecret = $Credential.GetNetworkCredential().Password;
	}
	
	$Uri = $OAuthBaseUrl.AbsoluteUri.Trim('/');
	$Username = $OAuthClientId;
	#$o = New-Object biz.dfch.CS.Cimi.Client.$CimiVersion.CimiClient;
	$o = [biz.dfch.CS.Cimi.Client.CimiClientFactory]::GetByVersion($CimiVersion);
	$o.JobTimeOut = $JobTimeOut;
	$c = $o.Login($Uri, $Username, $OAuthClientSecret, $AccessRefreshToken, $ApiBrokerBaseUrl.AbsoluteUri.Trim('/'), $TenantId, $TotalAttempts, $BaseWaitingMilliseconds);
	(Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).CloudEntryPoint = $c;
	(Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Service = $o;

	$OutputParameter = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Service;
	$fReturn = $true;

}
catch 
{
	if($gotoSuccess -eq $_.Exception.Message) 
	{
			$fReturn = $true;
	} 
	else 
	{
		[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		$ErrorText += (($_ | fl * -Force) | Out-String);
		$ErrorText += (($_.Exception | fl * -Force) | Out-String);
		$ErrorText += (Get-PSCallStack | Out-String);
		
		if($_.Exception -is [System.Net.WebException]) 
		{
			Log-Critical $fn "Login to Uri '$Uri' with Username '$Username' FAILED [$_].";
			Log-Debug $fn $ErrorText -fac 3;
		}
		else 
		{
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) 
			{
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} 
			elseif($gotoFailure -ne $_.Exception.Message) 
			{ 
				Write-Verbose ("$fn`n$ErrorText"); 
			} 
			else 
			{
				# N/A
			}
		}
		$fReturn = $false;
		$OutputParameter = $null;
	}
}
finally 
{
	# Clean up
	# N/A
}
return $OutputParameter;

}
# Process

End 
{
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
}
# End

} # function

Set-Alias -Name Connect- -Value 'Enter-Server';
Set-Alias -Name Enter- -Value 'Enter-Server';
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Enter-Server -Alias Connect-, Enter-; } 
