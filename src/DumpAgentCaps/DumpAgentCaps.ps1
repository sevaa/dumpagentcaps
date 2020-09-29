param
(
    [string]$Prefix,    
    [string]$Security,
    [string]$PAT,
    [string]$Endpoint    
)

Import-Module "Microsoft.TeamFoundation.DistributedTask.Task.Common"
Import-Module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
Add-Type -Assembly "Microsoft.TeamFoundation.DistributedTask.WebApi"
Add-Type -Assembly "Microsoft.TeamFoundation.SourceControl.WebApi"
Add-Type -Assembly "Microsoft.VisualStudio.Services.ReleaseManagement.WebApi"

$VSS = Get-VssConnection -TaskContext $distributedTaskContext
if($Security -ne "Context")
{
    Add-Type -Assembly "Microsoft.VisualStudio.Services.Common"
    
    $Uri = $VSS.Uri
    if($Security -eq "PAT")
    {
        $Cred = New-Object Microsoft.VisualStudio.Services.Common.VssBasicCredential "",$PAT
        $Cred = New-Object Microsoft.VisualStudio.Services.Common.VssCredentials $Cred
    }
    elseif($Security -eq "Agent")
    {
        $Cred = New-Object Microsoft.VisualStudio.Services.Common.VssCredentials $TRUE
    }
    elseif($Security -eq "Endpoint")
    {
        $EP = Get-ServiceEndpoint -Context $distributedTaskContext -Name $Endpoint
        $User = $EP.Authorization.Parameters["username"]
        $Pwd = $EP.Authorization.Parameters["password"]
        $Pwd = ConvertTo-SecureString -AsPlainText $Pwd -Force

        $Cred = New-Object System.Net.NetworkCredential $User,$Pwd
        $Cred = New-Object Microsoft.VisualStudio.Services.Common.WindowsCredential $Cred
        $Cred = New-Object Microsoft.VisualStudio.Services.Common.VssCredentials $Cred
    }
    $VSS = New-Object Microsoft.VisualStudio.Services.WebApi.VssConnection $Uri,$Cred
}

$AgentCli = $VSS.GetClient([Microsoft.TeamFoundation.DistributedTask.WebApi.TaskAgentHttpClient])

$AgentConfig = Get-Content "$Env:AGENT_HOMEDIRECTORY\.agent" -Raw
$AgentConfig = $AgentConfig.Replace("""workFolder""", """_workFolder""")
$AgentConfig = $AgentConfig | ConvertFrom-Json
$Agent = $AgentCli.GetAgentAsync($AgentConfig.PoolId, $Env:AGENT_ID, $TRUE, $FALSE, $NULL, $NULL, [System.Threading.CancellationToken]::None).GetAwaiter().GetResult()

foreach($CapName in $Agent.UserCapabilities.Keys)
{
    $CapValue = $Agent.UserCapabilities[$CapName]
    Write-Host "$CapName = $CapValue"
    Write-Host "##vso[task.setvariable variable=$Prefix$CapName;]$CapValue"
}
