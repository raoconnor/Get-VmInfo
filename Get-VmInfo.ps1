<# 
Get-vm-details

.Description
    Get virtual machine info
	russ 02/05/2016

    
.Example
    ./Get-VmInfo -VM <vmname>
#>

# Set variables for vm input - this must be at the top
[CmdletBinding()]
param (
[string]$vmname = " "
)		
$vm = Get-VM $vmname
write-output "Collecting info for: $($vm.Name)"
		
# Create empty results array to hold values
$resultsarray =@()
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
	   			
# output to gridview
$resultsarray | Out-GridView
 
