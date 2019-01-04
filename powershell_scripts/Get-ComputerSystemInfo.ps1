Function Get-FolderBrowserDialog{
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowser.ShowDialog() | Out-Null
    Return $FolderBrowser.SelectedPath
}

Function Save-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.SaveFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = “CSV files (*.csv)|*.csv|All files (*.*)|*.*”
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

#Variable to hold folder to recurse from
$RootFolder = $null

#User input for FolderBrowser Select or command line input
do{
    #User Action to Remove. Yes or No
    Write-Host -Foreground Yellow "`n`nHow do you want to enter input:`n  1) Using Folder Browser Dialog Form.`n  2) Using command line input."
    [string]$answer = Read-Host "`n`nEnter 1 or 2..."
    
    switch($answer) {
        #If the user chooses FolderDialogBrowser Form
        {($answer -eq "1")} { 
            #Opens FodlerDialogBrowser
            Write-Host -ForegroundColor Yellow "`n`nSelect a folder to recurse from...`nFolder may be hidden by front window."
            Read-host "Hit Enter to continue..." | Out-Null
            #Opens FolderBroswerDialog to select Root Folder
            $RootFolder = Get-FolderBrowserDialog
        }
        #If the user Chooses commmand line input 
        {($answer -eq "2")} {
            Write-Host -ForegroundColor Yellow "`nEnter folder recurse from."
            $RootFolder = Read-Host  "Path--->"

        }
        #input error
        default { Write-Host -ForegroundColor Red "You did not enter 1 or 2. No action will be taken.`n" } 
                    }
}until($answer -eq "1"-or $answer -eq "2")



#Script Pause
Write-Host -ForegroundColor Yellow "`n`nSelect *.csv for output..."
Read-host " Hit Enter to continue..." | Out-Null

#Opens Open File Dialog to select save file
$SaveFile = Save-FileName -initialDirectory "%USERDATA%\desktop\"

#Setting up csv and saving to disk
Write-Host -ForegroundColor cyan "Setting up $SaveFile to disk"
$csv = "Path,Owner,Group,Access`r`n"
$fso = new-object -comobject scripting.filesystemobject
$file = $fso.CreateTextFile($SaveFile,$true)
$file.write($csv)
$File.close()

#Gets SubFolders
Write-Host -ForegroundColor Cyan "Getting Subfolders of $RootFolder"
$SubFolders = Get-ChildItem $RootFolder -Recurse | ? {$_.psIscontainer -eq $true} | select fullname -ExpandProperty fullname

#Gets ACL information for each subfolder
Write-Host -ForegroundColor Cyan "Getting Subfolders ACL Information and Writing to disk..."
Foreach ($folder in $SubFolders){
   #Gets ACL info 
   $p = Get-Acl "$folder" | Select Path, Owner,Group,Access
   #formatting
   $path = $p.Path.Trim("Microsoft.PowerShell.Core\FileSystem")
   $owner = $p.Owner
   $group = $p.Group
   $access = $p.Access | Select IdentityReference,AccessControlType,FileSystemRights
   #more formatting for Access object
   $access_string =$null
   Foreach($a in $access){
        $IdentityReference = $a.IdentityReference 
        $AccessControlType = $a.AccessControlType
        $FileSystemRights = $a.FileSystemRights
        $access_string += "$IdentityReference $AccessControlType $FileSystemRights||"
   }

   #writing output
   $Output_String = "$path,$owner,$group,$access_string"
   $Output_String | Out-File $SaveFile -Append
   
}
#Complete
Write-Host -ForegroundColor Green "Complete. File saved at $savefile"

