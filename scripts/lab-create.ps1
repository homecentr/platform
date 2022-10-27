Function Create-VM([string]$VMName)
{
    $VM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    $HypervHost = Get-VMHost

    if($VM -ne $null)
    {
        Write-Host "✔️ [$VMName] VM found"
    }
    else
    {
        New-VM -Name $VMName `
            -MemoryStartupBytes 8GB `
            -Generation 2 `
            -SwitchName $SwitchName `
            -NewVHDPath "$($HypervHost.VirtualHardDiskPath)\$($VMName)_RootDrive.vhdx" `
            -NewVHDSizeBytes 192GB

        Write-Host "✔️ [$VMName] VM created"
    }

    $DvdDrive = Get-VMDvdDrive -VMName $VMName -ErrorAction SilentlyContinue
    if($DvdDrive -ne $null)
    {
        Write-Host "✔️ [$VMName] DVD drive found"
    }
    else 
    {
        $DvdDrive = Add-VMDvdDrive -VMName $VMName
        Write-Host "✔️ [$VMName] DVD drive added"
    }

    Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $true
    Write-Host "✔️ [$VMName] Nested virtualization enabled"

    $VMNIC = Get-VMNetworkAdapter -VMName $VMName
    Set-VMNetworkAdapter -VMName $VMName -Name $VMNIC.Name -MacAddressSpoofing On | Out-Null
    Write-Host "✔️ [$VMName] MAC address spoofing enabled"

    Set-VMFirmware -VMName $VMName -EnableSecureBoot Off | Out-Null
    Write-Host "✔️ [$VMName] secure boot disabled"

    Set-VMFirmware -VMName $VMName -FirstBootDevice $DvdDrive | Out-Null
    Write-Host "✔️ [$VMName] DVD set as default boot device"   
}

$HyperV = Get-WindowsOptionalFeature -FeatureName "Microsoft-Hyper-V-All" -Online
if($HyperV.State -eq "Enabled") 
{
    Write-Host "✔️ Hyper-V is installed"
}
else
{
    Write-Host "Installing Hyper-V..."
    Enable-WindowsOptionalFeature -FeatureName "Microsoft-Hyper-V-All" -Online
    Write-Host "Installation complete, please restart your PC and rerun the scripts..."
    return
}

$SwitchName = "Homecentr-Lab"
$Switch = Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue

if($Switch -ne $null)
{
    Write-Host "✔️ Hyper-V switch found"
}
else
{
    Write-Host "Creating switch..."
    Get-NetAdapter

    $IfIndex = Read-Host "Please enter ifIndex of the NIC you want to use for the virtual switch:"
    $IfDescription = (Get-NetAdapter -InterfaceIndex $IfIndex).InterfaceDescription
    
    New-VMSwitch -Name $SwitchName -NetAdapterInterfaceDescription $IfDescription -AllowManagementOS $true | Out-Null

    Write-Host "✔️ Hyper-V switch created"
}

Create-VM "Homecentr-Lab-Node1"
Create-VM "Homecentr-Lab-Node2"