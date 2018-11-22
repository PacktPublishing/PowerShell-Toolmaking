param
(
    # Username parameter
    [Parameter(Mandatory=$true)]
    [string]
    $userName,

    # List of target computers
    [Parameter(Mandatory=$true)]
    [String[]]
    $computers,

    # Value for registry key
    [string]
    $value = "SomeSetting"
)

function Write-Log
{
    param
    (
        [string]
        $info,

        [string]
        $logFile="logFile.txt"
    )

    $entry = "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - $info"
    $entry | Out-File -FilePath $logFile -Append

}

try
{
    $SID = (New-Object System.Security.Principal.NTAccount($userName)).Translate([System.Security.Principal.SecurityIdentifier]).Value
}
catch
{
    Write-Output "Can't get SID. Check log file for exception details."
    Write-Log -info "Can't get SID"
    Write-Log -info $_.Exception
    Exit -1
}

 Invoke-Command -ComputerName $computers -ScriptBlock {
    $SID = $args[0]
    $value = $args[1]

    write-output $env:COMPUTERNAME

    try
    {
        $newItem = New-Item -Path "Registry::HKEY_USERS\$SID\Software\Test" -Name "App1" -Force -ErrorAction Stop
        $newItemProperty = New-ItemProperty -Path "Registry::HKEY_USERS\$SID\Software\Test\App1"`
         -Name "Setting1" -Value $value -PropertyType String -Force -ErrorAction Stop

         $output = "The contents of new item process:{0}.`n The contents of the new item property process:{1}" -f $newItem, $newItemProperty

         return $output
    }
    catch
    {
        Write-Output "Problem creating registry keys"
        Return $_.Exception
    }
    
 } -ArgumentList $SID, $value