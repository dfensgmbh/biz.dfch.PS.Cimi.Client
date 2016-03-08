
$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".");

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "Module-Tests" "Module-Tests" {

	# Settings depending on environment.
	Write-Host "Loading settings from Appclusive..." "- BaseUrl" $biz_dfch_PS_Appclusive_Client.ServerBaseUri;
	$svc = Enter-ApcServer;
	
	Write-Host $UriOAuth2BaseUrl
	try
	{
		$UriOAuth2BaseUrl = $svc.Core.ManagementUris | ? Name -eq 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.OAuth2BaseUrl';
	}
	catch
	{
		$svc = Enter-ApcServer -Credential (Get-Credential -Message 'Appclusive Login');
	}
	$UriOAuth2BaseUrl = $svc.Core.ManagementUris | ? Name -eq 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.OAuth2BaseUrl';
	$PapBaseUrl = $svc.Core.ManagementUris | ? Name -eq 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.BaseUrl';
	$CredOAuth2BaseUrl = Get-ApcManagementCredential -Name 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.OAuth2BaseUrl';
	$CredAccessRefreshToken = Get-ApcManagementCredential -Name 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.AccessRefreshToken';
		
	$OAuthBaseUrl = $UriOAuth2BaseUrl.Value; 
	$OAuthClientId = $CredOAuth2BaseUrl.Username;
	$OAuthClientSecret = $CredOAuth2BaseUrl.Password;
	$ApiBrokerBaseUrl = $PapBaseUrl.Value;
	$AccessRefreshToken = $CredAccessRefreshToken.Password;
	$TenantId = Get-ApcKeyNameValue -Key 'biz.dfch.CS.Appclusive.Core.Scs.Cmp' -Name 'tenantId' -ValueOnly;
	$cimiSettings =(Get-ApcKeyNameValue -Key 'biz.dfch.CS.Cimi' -Name 'TestSettings').Value | ConvertFrom-Json;
	$SystemWithSubsystems = $cimiSettings.SystemWithSubsystems;
	$SystemWithMachines = $cimiSettings.SystemWithMachines;
	$MachineId = $cimiSettings.MachineId;
	$SystemTemplateId = $cimiSettings.SystemTemplateId;
	$MachineTemplateId = $cimiSettings.MachineTemplateId;
	$TotalAttempts = [int]$cimiSettings.TotalAttempts;
	$BaseWaitingMilliseconds = [int]$cimiSettings.BaseWaitingMilliseconds;
	$JobTimeOut = [int]$cimiSettings.JobTimeOut;
	$CimiVersion = 'v2';
			
	Write-Host "Testing Cimi..." ' - BaseUrl' $OAuthBaseUrl;
	
	Context "#CLOUDTCL-????-EnterServer" {
		
		It "Enter-ServerWithParams-ShouldFailed" -Test{
			# Arrange
			# N/A
			
			# Act
			$result = Enter-CimiServer;

			# Assert
			$result | Should Be $null;
		}
		
		It "Enter-Server-ShouldSucceed" -Test{
			# Arrange
			# N/A
			
			# Act
			$result = Enter-CimiServer -OAuthBaseUrl $OAuthBaseUrl -ApiBrokerBaseUrl $ApiBrokerBaseUrl -OAuthClientId $OAuthClientId -OAuthClientSecret $OAuthClientSecret -AccessRefreshToken $AccessRefreshToken -TenantId $TenantId -TotalAttempts $TotalAttempts -BaseWaitingMilliseconds $BaseWaitingMilliseconds -JobTimeOut $JobTimeOut -CimiVersion $CimiVersion;

			# Assert
			$result | Should Not Be $null;
			$result -is [biz.dfch.CS.Cimi.Client.BaseCimiClient] | Should Be $true;
			$result.IsLoggedIn | Should Be $true;
		}
	}
}
