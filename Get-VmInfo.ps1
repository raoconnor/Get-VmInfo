<# 
Get-vm-details

.Description
    Get virtual machine info
	russ 02/05/2016

    
.Example
    ./Get-VmInfo
#>



# Pre-code saves to path with unique name
$datacenter = get-datacenter
$filepath = "C:\vSpherePowerCLI\Output\"
if (!(Test-path $filepath)){ New-Item -Path $filepath -ItemType Directory}
else { Write-host "ok, path exists"} 
$filename = "vmInfo"
$initalTime = Get-Date
$date = Get-Date ($initalTime) -uformat %Y%m%d
$time = Get-Date ($initalTime) -uformat %H%M
Write-Host "---------------------------------------------------------" -ForegroundColor DarkYellow
Write-Host "Output will be saved to:"  								   -ForegroundColor Yellow
Write-Host $filepath$datacenter-$filename-$date$time".csv"  			-ForegroundColor White
Write-Host "---------------------------------------------------------" -ForegroundColor DarkYellow

# Create empty results array to hold values
# $resultsarray =@()





# Option to run script against a single vm or specific cluster
# Remove the Get Cluster section and replace with $vms = Get-VM to run on all vms in vcenter

# Get Cluster info and populate $vms  
$Cluster = Get-Cluster  
$countCL = 0  
Write-Output " "  
Write-Output "Clusters: "  
Write-Output " "  
	foreach($oC in $Cluster){  
       Write-Output "[$countCL] $oc"  
       $countCL = $countCL+1  
       }  
$choice = Read-Host "Which Cluster do you want to review?"  
Write-Output " "  
Write-host "please wait for script to finish, it may take a while...." -ForegroundColor Yellow
$cluster = get-cluster $cluster[$choice] 
	
#Filter only powered on vms
$answer = Read-Host "Get only powered on vms (Y/N)" 
if ($answer -ne "N"){$vms = Get-Cluster $cluster | Get-VM | where {$_.powerstate -eq "PoweredOn"}}

else{ $vms = Get-Cluster $cluster | Get-VM}

	
# Create empty results array to hold values
$resultsarray =@()
	
# Iterates each vm in the $vms variable
foreach ($vm in $vms){ 
	          
        write-output "Collecting info for: $($vm.Name)"
					
		# Create an array object to hold results, and add data as attributes using the add-member commandlet
		$resultObject = new-object PSObject
        $resultObject | add-member -membertype NoteProperty -name "Folder" -Value $vm.Folder.Name
		$resultObject | add-member -membertype NoteProperty -name "Host" -Value $vm.VMHost
		$resultObject | add-member -membertype NoteProperty -name "Name" -Value $vm.Name
		$resultObject | add-member -membertype NoteProperty -name "PowerState" -Value $vm.PowerState
		$resultObject | add-member -membertype NoteProperty -name "NumCpus" -Value $vm.NumCpu
		$resultObject | add-member -membertype NoteProperty -name "CPU Limit" -Value $vm.ExtensionData.Config.CpuAllocation.Limit
		$resultObject | add-member -membertype NoteProperty -name "CPU Shares" -Value $vm.ExtensionData.Config.CpuAllocation.Shares.shares
		$resultObject | add-member -membertype NoteProperty -name "MemGB" -Value $vm.MemoryGB
		$resultObject | add-member -membertype NoteProperty -name "Version" -Value $vm.ExtensionData.Config.version
		$resultObject | add-member -membertype NoteProperty -name "Tools" -Value $vm.ExtensionData.Config.Tools.ToolsVersion
		$resultObject | add-member -membertype NoteProperty -name "Guest OS" -Value $vm.ExtensionData.Config.GuestFullName
		$resultObject | add-member -membertype NoteProperty -name "Datastore" -Value $vm.ExtensionData.Config.DatastoreUrl.Name
		$UsedSpace  = $vm.UsedSpaceGB -as [int]
		$resultObject | add-member -membertype NoteProperty -name "Used Disk" -Value $UsedSpace
		$ProvisionedSpace  = $vm.ProvisionedSpaceGB -as [int]
		$resultObject | add-member -membertype NoteProperty -name "Provisioned Space" -Value $ProvisionedSpace
		#Removed following line that collect rdm mode because it slows the script down
		#$resultObject | add-member -membertype NoteProperty -name "RDM Disk Type" -Value (get-vm -Name $vm).ExtensionData.Config.Hardware.Device.Backing.CompatibilityMode
	
		# Write array output to results 
		$resultsarray += $resultObject						            
	   	
}

		
# output to gridview
$resultsarray | Out-GridView
 
# export to csv 
$resultsarray | Export-Csv $filepath$filename"-"$datacenter$cluster"-"$date$time".csv" -NoType	