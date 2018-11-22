#$file = "C:\Data\ConfigFile.txt"
param 
(
    # A list of servers
    [Parameter(Mandatory=$False)]
    [string]
    $serverList = ".\servers.txt",

    # File to copy
    [Parameter(Mandatory=$True)]
    [string]
    $file,

    # Destination where to copy to
    [Parameter(Mandatory=$True)]
    [string]
    $dest
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

$servers = Get-Content -Path $serverList

foreach($server in $servers)
{
    $destination = "\\$server\" + $dest
    if(Test-Path -Path $destination)
    {
        try 
        {
            $fileDate = (Get-ChildItem "$destination\ConfigFile.txt" -ErrorAction Stop).LastWriteTime
            $fileDateSource = (Get-ChildItem $file -ErrorAction Stop).LastWriteTime
            
            if($fileDate -lt $fileDateSource)
            {
                Copy-Item -Path $file -Destination $destination -Force -ErrorAction Stop
                Write-Verbose "File copied to $server"
                Write-Log -info "File copied to $server"
            }
            else 
            {
                Write-Verbose "The destination file on $server is more recent."
                Write-Log -info "The destination file on $server is more recent."
            }
            
        }
        catch [System.Management.Automation.ItemNotFoundException]
        {
            Write-Verbose "The destination file on $server does not exist. Copying a new version."
            Write-Log -info "The destination file on $server does not exist. Copying a new version."
            try 
            {
                Copy-Item -Path $file -Destination $destination -Force -ErrorAction Stop
                Write-Verbose "File copied to $server"
                Write-Log -info "File copied to $server"
            }
            catch 
            {
                Write-Verbose $_.Exception
                Write-Log -info $_.Exception
            }
            
        }
        catch 
        {
            Write-Verbose $_.Exception
            Write-Log -info $_.Exception
        }
        
    }
    else 
    {
        Write-Verbose "The destination folder structure does not exist on $server"
        Write-Log -info "The destination folder structure does not exist on $server"
    }
}