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
[string]$body = $report | Sort-Object State | ConvertTo-Html -PreContent "<h1>Server Report</h1>" -CssUri .\table.css
$smtp = "SMTSERVER"
$to = "admins@company.com"
$from = "monitoring@company.com"
$subject = "Server Report"

Send-MailMessage -SmtpServer $smtp -To $to -From $from -Subject $subject -Body $body -BodyAsHtml
# SIG # Begin signature block
# MIIFoQYJKoZIhvcNAQcCoIIFkjCCBY4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUP34sBVGSo4Z7tCDEQ+xgyDte
# kmagggM2MIIDMjCCAhqgAwIBAgIQGvXmbFlL3oRMKXImS63OIjANBgkqhkiG9w0B
# AQsFADAgMR4wHAYDVQQDDBVlZGdhci5kb2NrdXNAYXBwZHMuZXUwHhcNMTgxMDE4
# MTQxMjEyWhcNMTkxMDE4MTQzMjEyWjAgMR4wHAYDVQQDDBVlZGdhci5kb2NrdXNA
# YXBwZHMuZXUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCvJtl72MAo
# GrgprRgBLw1+hnuhrHXhfQGKQqFoYb1cYutseUYq3Ce3lPSdF1fiRf/UjO3RVpCX
# 49RiI846vnoY9mS/EBBELkMy8pM/R4rJHmLbTE1DnJVqpZnnHX1W2cw9wJjVP8iC
# yM6a00DfgKRC+nc74IswsFzhxwrxJv9zGiQhWTNH1g8u3F4vaIoE7XK4u52RP/wU
# Tz06cGhsJpYDgywk9SqAzYxu8RgSJr3htYg3Srb9UfIojUM9LbdW6ItTAEpasB6/
# AUyBMmflpqM8JtdkPtSEzneyVVfmVRU9bLg/F9sy+t6/dcE6XnOvUygOeEbWWVj5
# p8S5AnvZ69JnAgMBAAGjaDBmMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
# BgEFBQcDAzAgBgNVHREEGTAXghVlZGdhci5kb2NrdXNAYXBwZHMuZXUwHQYDVR0O
# BBYEFEHK/Qy0O9WWiWt7fPcWsfQP6Lx6MA0GCSqGSIb3DQEBCwUAA4IBAQAA9ZEM
# ZkYXYMluLtH43TBWXBK6+I6WEGL7q5LOnh/+CkbNvOM/UtDZxsMhV4FgZLGF4ThV
# Ef12ndhrY+FTJy0uzGU7LKH1lhGibvvdBJPqyPxCh9tKkU7Ty8TZUwdqueJRY/dX
# wSeJbqGCFUcK4m0vCEVS1un3OLr6VoA4FF5V96RVP+I8xP5f2Yhb3POS9Xxzkrrz
# KWNWtz0XVFEOF3zS5uPcUNfbBsjSqCOkE8tQKFC6bosH4qpKeHQCn5wUh6uQfso1
# f0lMizsPp9qe5IvHui5g3QINPss85Y+30iuMSWN0hfWIFzyTt1MjkqNx2I4fzd9G
# NZugt3It9aghNMayMYIB1TCCAdECAQEwNDAgMR4wHAYDVQQDDBVlZGdhci5kb2Nr
# dXNAYXBwZHMuZXUCEBr15mxZS96ETClyJkutziIwCQYFKw4DAhoFAKB4MBgGCisG
# AQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFBUs
# e2xJhoC2dsBcLQDSvjoK3FGuMA0GCSqGSIb3DQEBAQUABIIBAF4bk0PLKrPtsyg/
# pSrVpS8zPLXhQarveTwCX1o7DmtwJRQw6hOpY72VkXntIwyhv3g6r8WmiJE5Ilsw
# 3t0S8u+lrFkg7vEkeUKvhrWOZitdtfWKMCwhOlkv2M7GQsXvOcREeHqLZcWDj9II
# ukvsCN0Ejr5bq/u1cVqev4RxWT+2IX1iWDbjY+uVtC6Whbyhl+88cc67wQ42jKl+
# jtN8uuyz6c9ZIlvSGdmyUwd9o32pbBRYjlS6Hf1iLJNEX7QtuWBDXqV8QeSugzvK
# EYwSa3nJaDMb/qWP/vlmILfV/ojRsqHj6Bi4WIsymXawJFRexS9IOkAurlcPB6ru
# reXRi7c=
# SIG # End signature block
