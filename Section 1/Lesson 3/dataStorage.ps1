$myArray = @(1, 2, 3, 4, 5) ## Simple array
$myArray += 6 ## Adding a member to the end of an array

$myArray = $myArray + 6 ## This is the same thing as the line above, but in a fully exended syntax

$myArray = New-Object System.Collections.ArrayList ## Array list
$myArray.Add(1) ## Adding items to an array list
$myArray.Add(2)
$myArray.Add(3)
$myArray.Add(4)
$myArray.Add(5)

$myArray.Add(6) ## Add another item
$myArray.Remove(3)## Remove an item with a value 3

$myHashtable = @{'Name' = "PowerShell";'Version' = $PSVersionTable.PSVersion} ## Hashtable with two key value pairs
$myHashtable['Name'] ## Calling a Name key
$myHashtable['Version'] ## Calling a Version key

$myHashtable.Add('Number', 8) ## Adding another key value pair to an existing hash table

Get-Process | Select-Object ProcessName,@{Name="NPM+PM";Expression={$_.NPM + $_.PM}} ## Using hashtables to format the data on screen