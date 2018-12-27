Import-Module SqlServer
$SQLInstance = "poshcourse.database.windows.net"
$SQLUser = "posh"
$SQLPwdSecured = Read-Host -AsSecureString
$string = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SQLPwdSecured)
$SQLPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($string)
$database = "poshcourse"

try 
{
    $computers = Get-ADComputer -Filter * -ErrorAction Stop | ForEach-Object {$_.Name}  
}
catch 
{
    Write-Error "Unable to query AD"
    Write-Error $_.Exception
    Exit -1
}

$report = @()

foreach($computer in $computers)
{
    $serverObject = "" | Select-Object ServerName, State, CPUModel, CPUCores, CPUNumber, CPUClockSpeed, RAM, HDDSpace, HDDFreeSpace

    $serverObject.ServerName = $computer
    $connection = Test-Connection -ComputerName $computer -Count 2 -ErrorAction SilentlyContinue

    if($connection)
    {
        $serverObject.State = "Online"
        try 
        {
            $CPU = Get-WmiObject -Class Win32_Processor -ErrorAction Stop | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed
            $serverObject.CPUModel = $CPU.Name
            $serverObject.CPUCores = $cpu.NumberOfCores
            $serverObject.CPUClockSpeed = $cpu.MaxClockSpeed
            $serverObject.CPUNumber = $CPU.NumberOfLogicalProcessors
        }
        catch 
        {
            $CPU = "" | Select-Object Name, NumberOfCores, MaxClockSpeed, NumberOfLogicalProcessors
            $serverObject.CPUModel = "ERROR - WMI"
            $serverObject.CPUCores =  "ERROR - WMI"
            $serverObject.CPUClockSpeed =  "ERROR - WMI"
            $serverObject.CPUNumber =  "ERROR - WMI"

        }
        
        $serverObject.RAM = [math]::Round($(Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory/1GB,2)
        
        $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object FreeSpace, Size
        
        $serverObject.HDDSpace = [math]::Round($disk.Size/1gb,2)
        $serverObject.HDDFreeSpace = [math]::Round($disk.FreeSpace/1gb,2)

        $report += $serverObject    
    }
    else
    {
        $serverObject.State = "Offline"    
        $serverObject.CPUModel = "N/A"
        $serverObject.CPUCores = "N/A"
        $serverObject.CPUClockSpeed = "N/A"
        $serverObject.CPUNumber = "N/A"
        $serverObject.RAM = "N/A"               
        $serverObject.HDDSpace = "N/A"
        $serverObject.HDDFreeSpace = "N/A"
        
        $report += $serverObject
    }
}

foreach($item in $report)
{
    $SQLQuery ="INSERT INTO server_report (serverName, state, cpuModel, cpuCores, cpuNumber, cpuClockSpeed, ram,
    hddSpace, hddFreeSpace) VALUES ('{0}', '{1}', '{2}', '{3}', '{4}', '{5}', '{6}', '{7}', '{8}')" -f $item.serverName, $item.state, $item.cpuModel, $item.cpuCores, $item.cpuNumber, $item.cpuClockSpeed, $item.ram, $item.hddSpace, $item.hddFreeSpace

    $SQLResult = Invoke-Sqlcmd -Query $SQLQuery -ServerInstance $SQLInstance -Username $SQLUser -Password $SQLPwd -Database $database
}