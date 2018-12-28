$user = $REQ_PARAMS_USER
$passwordd = $REQ_PARAMS_PASSWORD
$VM = $REQ_PARAMS_MACHINE
$Key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)

$secPwd = ConvertTo-SecureString $passwod -Key $Key
$cred = New-Object System.Management.Automation.PSCredential($user, $secPwd)

Login-AzureRmAccount -Credential $cred
Select-AzureRmSubscription -SubscriptionName "<insert name here>"

$state = $($(Get-AzureRmVM -Name $VM -ResourceGroupName PowerShellCourse -Status))

if($state -like "VM Deallocated")
{
    Get-AzureRmVM -Name $VM -ResourceGroupName PowerShellCourse | Start-AzureRmVM
    Start-Sleep -Seconds 30
    Out-File -Encoding ascii -FilePath $res -InputObject "$state"
}
else
{
    Get-AzureRmVm -Name $VM -ResourceGroupName PowerShellCourse | Stop-AzureRmVM
    Start-Sleep -Seconds 30
    Out-File -Encoding ascii -FilePath $res -InputObject "$state"
}