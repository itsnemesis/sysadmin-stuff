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
 $OpenFileDialog.filter = “Text files (*.txt)|*.txt|All files (*.*)|*.*”
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

#Script Pause
Write-Host -ForegroundColor Yellow "`n`nSelect a folder to recurse from...`nFolder may be hidden by front window."
Read-host " Hit Enter to continue..." | Out-Null

#Opens FolderBroswerDialog to select Root Folder
$RootFolder = Get-FolderBrowserDialog

#Script Pause
Write-Host -ForegroundColor Yellow "`n`nSelect *.txt for output..."
Read-host " Hit Enter to continue..." | Out-Null

#Opens Open File Dialog to select save file
$SaveFile = Save-FileName -initialDirectory "%USERDATA%\desktop\"

#Gets SubFolders
Write-Host -ForegroundColor Cyan "Getting Subfolders of $RootFolder"
$SubFolders = Get-ChildItem $RootFolder -Recurse  | ? {$_.psIscontainer -eq $true} | select fullname -ExpandProperty fullname
#output
$output = @()
#Gets ACL infor for each subfolder
Write-Host -ForegroundColor Cyan "Getting Subfolders ACL Information..."
Foreach ($folder in $SubFolders){
   #Gets ACL info 
   $output += Get-Acl "$folder" | Format-List 
}
Write-Host -ForegroundColor Cyan "Writting output to $SaveFile "
$output | Out-file $SaveFile -Force
