Import-Module ActiveDirectory

Function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

$file = Get-FileName -initialDirectory "c:\"
$ComputerList = gc $file

foreach ($Computer in $ComputerList){
    
    "##################################################################################################################`n"
    "Begin $Computer`n"

    if (Test-Connection -Count 2 $Computer -Quiet){
        try{

            $Programs = Get-WmiObject Win32reg_AddRemovePrograms -ComputerName $Computer | where Displayname -match "java" | select DisplayName, Version -ErrorAction Stop

            "Java Versions Installed:"

            foreach ($P in $Programs){

                "DisplayName: " + $P.DisplayName + "  Version: " + $P.Version

            }

            "`nTo remove Java from the reistery open regedit as administrator. File-->Connect Network Registry. Enter in computername and click OK."
            "Open HKLM\SOFTWARE\Microsoft\Windows\CurrentVerrion\Uninstall `nOpen HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVerrion\Uninstall " 
            "Delete the registry key that has a DisplayName value you wish to remove."

            #Pause
            Read-Host "`nPress Enter to continue..." | Out-Null

            $Java64bit = Get-ChildItem -path "\\$Computer\c$\Program Files\Java"

            "`nFolders within \\$Computer\c$\Program Files\Java\`n"
            Foreach($j64b in $Java64bit){

               $j64b.name 

            }
            #Pause
            Read-Host "`nPress Enter to continue..." | Out-Null

            Foreach($j64b in $Java64bit){
                do{
                    #User Action to Remove. Yes or No
                    Write-Host "`n`nDo you want to Remove: `n"
                        $j64b | Select Name
                        $answer = ""
                        $answer = Read-Host "`n`n(Y)es or (N)o?"

                    switch($answer.ToLower()) {
                        #If the user chooses Yes
                        {($_ -eq "y") -or ($_ -eq "yes")} { 
                            "Removing Folder"
                            remove-item "\\$Computer\c$\Program Files\Java\$J64b" -Recurse -Force
                            #Pause
                            Read-Host '`nPress Enter to continue...' | Out-Null
                        }
                        #If the user Chooses No 
                        {($_ -eq "n") -or ($_ -eq "no")} { "You entered No.The Folder will not be Removed.`n" }
                        #input error
                        default { "You did not enter yes or no. No action will be taken.`n" } 
                    }
                }until($answer.ToLower() -eq "y" -or $answer.ToLower() -eq "yes" -or $answer.ToLower() -eq "n" -or $answer.ToLower() -eq "no")
            }
            $Java32bit = Get-ChildItem -path "\\$Computer\c$\Program Files (x86)\Java"

            "`nFolders within \\$Computer\c$\Program Files (x86)\Java\`n"
            Foreach($j32b in $Java32bit){

               $j32b.name 

            }
            #Pause
            Read-Host "`nPress Enter to continue..." | Out-Null

            Foreach($j32b in $Java32bit){
                do{
                    #User Action to Remove. Yes or No
                    Write-Host "`n`nDo you want to Remove: `n"
                        $j32b | Select Name
                        $answer = ""
                        $answer = Read-Host "`n`n(Y)es or (N)o?"

                    switch($answer.ToLower()) {
                        #If the user chooses Yes
                        {($_ -eq "y") -or ($_ -eq "yes")} { 
                            "Removing Folder"
                            remove-item "\\$Computer\c$\Program Files (x86)\Java\$J32b" -Recurse -Force
                            #Pause
                            Read-Host "`nPress Enter to continue..." | Out-Null
                        }
                        #If the user Chooses No 
                        {($_ -eq "n") -or ($_ -eq "no")} { "You entered No.The Folder will not be Removed.`n" }
                        #input error
                        default { "You did not enter yes or no. No action will be taken.`n" } 
                    }
                }until($answer.ToLower() -eq "y" -or $answer.ToLower() -eq "yes" -or $answer.ToLower() -eq "n" -or $answer.ToLower() -eq "no")


            }


        } Catch [Exception] {
        
            if ($_.Exception.GetType().name -eq "COMException"){
                    $note = "RPC Error" 
                    }else{
                    $note =$_.Exception.GetType()
                    }
                [pscustomobject]@{
                    ComputerName = $Computer
                    DisplayName = $Program.DisplayName
                    Version = $Program.Version
                    ADEnabled = $ADComputer.Enabled
                    Note = $note
                }
        
        }
    }else {

        "Connection timeout"
    }


}
