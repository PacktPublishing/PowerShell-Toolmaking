param (
    # Parameter help description
    [Parameter(Mandatory=$false)]
    [string]
    $data="SELECT * FROM server_report"
)

$SQLInstance = "poshcourse.database.windows.net"
$SQLUser = "posh"
$SQLPwdSecured = Read-Host -AsSecureString
$string = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SQLPwdSecured)
$SQLPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($string)
$database = "poshcourse"

$report = Invoke-Sqlcmd -Query $data -ServerInstance $SQLInstance -Username $SQLUser -Password $SQLPwd -Database $database
$report | ConvertTo-Html -PreContent "<h1>Server Report</h1>" -CssUri .\table.css | Out-File report.html