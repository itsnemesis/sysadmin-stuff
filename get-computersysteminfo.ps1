Function Get-ComputerSystemInfo {

    Param
	(
		[Alias('Computer','ComputerName','HostName')]
		[Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$true,Position=1)]
		[string[]]$Name = $env:COMPUTERNAME
	)

    $Results = @()
    $Count = $name.Count
    $i = 1
    
    foreach ($computer in $name){
        Write-host "Starting $computer ($i of $count)"

        $computerInfo = [pscustomobject]@{
                            Computername = $Computer.ToUpper()
                            Make = $NULL
                            Model = $NULL
                            SN = $NULL
                            IP = $NULL
                            MAC = $NULL
                            LastLogonUser = $NULL
                            Note = $NULL
        }

        Write-Host "Pinging host"
        If((test-connection -ComputerName $computer -Count 1 -Quiet)){

            Write-host "Getting Make and Model"
            $win32computersystem = get-wmiobject win32_computersystem -ComputerName $computer -ErrorAction SilentlyContinue
            if(($win32computersystem)){
                $computerInfo.Computername = $win32computersystem.Computername.ToUpper()
                $computerInfo.Make = $win32computersystem.Manufacturer
                $computerInfo.Model = $win32computersystem.Model
            }else{Write-Host -ForegroundColor Red "Unable to retreive win32_Computersystem"}

            ############################################################################################
            Write-Host "Getting Serial Number"
            $win32BIOS = get-wmiobject win32_BIOS -ComputerName $computer -ErrorAction SilentlyContinue
            if(($win32BIOS)){
                $computerInfo.SN = $win32BIOS.SerialNumber
            }else{Write-Host -ForegroundColor Red "Unable to retreive win32_BIOS"}

            ############################################################################################
            Write-Host "Getting IP and MAC Info"
            $win32NetAdaptConfig = get-wmiobject Win32_NetworkAdapterConfiguration -ComputerName $computer | Select IPAddress, MACAddress | Where IPaddress -GT 1 -ErrorAction SilentlyContinue
            if(($win32BIOS)){
                $computerInfo.IP = $win32NetAdaptConfig.IPAddress
                $ComputerInfo.MAC = $win32NetAdaptConfig.MACAddress
            }else{Write-Host -ForegroundColor Red "Unable to retreive win32_BIOS"}

            ############################################################################################
            Write-Host "Getting Last 3 Loged on Users"
            $LastLogonUser = get-wmiobject Win32_UserProfile -ComputerName $computer -Filter "NOT SID = 'S-1-5-18' AND NOT SID = 'S-1-5-19' AND NOT SID = 'S-1-5-20'" | sort lastUseTime -Descending | select -First 3
            
            if(($LastLogonUser)){

                $users = @()
                
                Foreach ( $u in $LastLogonUser){

                    $User = [pscustomobject] @{
                                User = $NULL
                                Date = $NULL
                            }
                    $Script:UserSID = New-Object System.Security.Principal.SecurityIdentifier($u.SID) 

                    $user.User = $Script:UserSID.Translate([System.Security.Principal.NTAccount]) 
                    $user.Date = ([WMI]'').ConvertToDateTime($u.LastUseTime)

                    $Users += $user
                }
                $computerInfo.LastLogonUser = $users
                
            }else{Write-Host -ForegroundColor Red "Unable to retreive Win32_UserProfile"}

            ############################################################################################

        }else{
            Write-Host -ForegroundColor red "$computer Offline"
            $computerInfo.Note = "Offline"    
        }
        #increase counter
        $i++

        $Results += $computerInfo


    }

    $Results

}
