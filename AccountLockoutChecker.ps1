$LogPath="C:\Users\Administrator\Desktop\Projects\AD-lockout-checker\Logs"
$LogFile="Lockouts -$(Get-Date -Format "yyyy-MM-dd hh-mm").csv"

<#With this variable we will obtain every lockeout user#>
$LockedOutUsers=Search-ADAccount -LockedOut -Server wservertest.local

<#On this array we will saver every user locked out and every field we needed#>
$Export=[System.Collections.ArrayList]@()

foreach($LockedOutUser in $LockedOutUsers){

    <#We will save every user as an object with fields name, username,lockout date and when was last passwordm attempt#>
    $ADUser=Get-ADUser -Identity $LockedOutUser.SamAccountName -Server wservertest.local -Properties *
    $Entry=New-Object -TypeName PSObject
    Add-Member -InputObject $Entry -MemberType NoteProperty -Name "Name" -Value $ADUser.Name
    Add-Member -InputObject $Entry -MemberType NoteProperty -Name "UserName" -Value $ADuser.SamAccountName
    Add-Member -InputObject $Entry -MemberType NoteProperty -Name "LockoutTime" -Value $([datetime]::FromFileTime($ADUser.lockoutTime))
    Add-Member -InputObject $Entry -MemberType NoteProperty -Name "LastBadPasswordAttempt" -Value $ADuser.LastBadPasswordAttempt
    <#we wil add every lockout user on our array and secure there is nothing "void"#>
    [void]$Export.Add($Entry)
}

<#Finally check if we have info and save it on to a CSV file#>
if($Export){
    $Export | Export-Csv -Path "$LogPath\$LogFile" -Delimiter ',' -NoTypeInformation
}