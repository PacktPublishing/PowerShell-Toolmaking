$myObj = Get-Service ## PowerShell will instantiate $myObj as System.Array type of an object
$myObj 

$myObj2 = New-Object -TypeName psobject ## Setting up $myObj2 as System.Object type of an object
$myObj2 | Add-Member -NotePropertyName "Name" -NotePropertyValue "PowerShell" ## Adding a property called Name
$myObj2 | Add-Member -NotePropertyName "Version" -NotePropertyValue $PSVersionTable.PSVersion ## Adding a property called Version that is populated from $PSVersionTable.PSVersion value
$myObj2 | Add-Member -NotePropertyName "Number" -NotePropertyValue 0.9 ## Another property
$myObj2 | Add-Member -NotePropertyName "Number2" -NotePropertyValue 6 ## one more property 

Add-Member -InputObject $myObj2 ScriptMethod AddNumbers { ## Here we add a method to an object
    return($this.Number + $this.Number2) ## It will simply return a sum of Number and Number2 properties
} -Force -PassThru