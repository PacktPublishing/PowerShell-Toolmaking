$SQLInstance = "poshcourse.database.windows.net"
$SQLUser = "posh"
$SQLPwdSecured = Read-Host -AsSecureString
$string = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SQLPwdSecured)
$SQLPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($string)
$database = "poshcourse"

Import-Module SqlServer

$SQLQuery = "
    CREATE TABLE server_report (
        ID int IDENTITY(1,1) PRIMARY KEY,
        serverName varchar(255),
        state varchar(255),
        cpuModel varchar(255),
        cpuCores varchar(255),
        cpuNumber varchar(255),
        cpuClockSpeed varchar(255),
        ram varchar(255),
        hddSpace varchar(255),
        hddFreeSpace varchar(255),
    );"

$qq = "ALTER TABLE server_report
ADD DateInserted DATETIME NOT NULL DEFAULT (GETDATE());"

$qq2 = "SELECT * FROM server_report"

$qq3 = "Update server_report
    SET serverName = 'Something'
WHERE serverName = 'PowerShellVM01';"

$qq4 = "DELETE FROM server_report
    WHERE serverName = 'Something';"

$data = "SELECT * FROM server_report
    WHERE DateInserted <= '2018-11-01 11:46:00';"

$SQLResult = Invoke-Sqlcmd -Query $data -ServerInstance $SQLInstance -Username $SQLUser -Password $SQLPwd -Database $database