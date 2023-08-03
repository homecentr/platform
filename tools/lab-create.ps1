$ErrorActionPreference = "Stop"

$ExternalSwitchName = "Homecentr-Lab-External"
$StorageSwitchName = "Homecentr-Lab-Storage"
$ProxmoxIsoLink = "https://enterprise.proxmox.com/iso/proxmox-ve_8.0-2.iso"
$ProxmoxIsoPath = [System.IO.Path]::Join([System.Environment]::CurrentDirectory, "./.images/Proxmox-8-0.iso")

Function Create-ExternalSwitch()
{
    $Switch = Get-VMSwitch -Name $ExternalSwitchName -ErrorAction SilentlyContinue

    if($Switch -ne $null)
    {
        Write-Host "✔️ Hyper-V external switch found"
    }
    else
    {
        Write-Host "Creating external switch..."
        Get-NetAdapter

        $IfIndex = Read-Host "Please enter ifIndex of the NIC you want to use for the virtual switch"
        $IfDescription = (Get-NetAdapter -InterfaceIndex $IfIndex).InterfaceDescription
        
        New-VMSwitch -Name $ExternalSwitchName -NetAdapterInterfaceDescription $IfDescription -AllowManagementOS $true | Out-Null

        Write-Host "✔️ Hyper-V external switch created"
    }
}

Function Create-StorageSwitch()
{
    $Switch = Get-VMSwitch -Name $StorageSwitchName -ErrorAction SilentlyContinue

    if($Switch -ne $null)
    {
        Write-Host "✔️ Hyper-V internal switch found"
    }
    else
    {
        New-VMSwitch -Name $StorageSwitchName -SwitchType Private | Out-Null

        Write-Host "✔️ Hyper-V internal switch created"
    }
}

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
        # Note: Proxmox fails to start a VM if it has less than 4GB
        
        New-VM -Name $VMName `
            -Generation 2 `
            -NewVHDPath "$($HypervHost.VirtualHardDiskPath)\$($VMName)_RootDrive.vhdx" `
            -NewVHDSizeBytes 96GB `
            -MemoryStartupBytes 7GB `
            -SwitchName $ExternalSwitchName

        Add-VMNetworkAdapter -VMName $VMName -SwitchName $StorageSwitchName

        Write-Host "✔️ [$VMName] VM created"
    }

    
    Set-VMMemory -VMName $VMName `
                 -DynamicMemoryEnabled $false # Proxmox can't work with dynamic memory properly

    $DvdDrive = Get-VMDvdDrive -VMName $VMName -ErrorAction SilentlyContinue
    if($DvdDrive -ne $null)
    {
        Write-Host "✔️ [$VMName] DVD drive found"
    }
    else 
    {
        Add-VMDvdDrive -VMName $VMName -Path $ProxmoxIsoPath
        $DvdDrive = Get-VMDvdDrive -VMName $VMName
        
        Write-Host "✔️ [$VMName] DVD drive added"
    }

    Set-VMProcessor -VMName $VMName -Count 6
    Write-Host "✔️ [$VMName] CPU cores allocated"

    Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $true
    Write-Host "✔️ [$VMName] Nested virtualization enabled"

    $VMNetworkAdapters = Get-VMNetworkAdapter -VMName $VMName
    foreach($VMNIC in $VMNetworkAdapters)
    {
        Set-VMNetworkAdapter -VMName $VMName -Name $VMNIC.Name -MacAddressSpoofing On | Out-Null
        Write-Host "✔️ [$VMName] MAC address spoofing enabled on $($VMNIC.Name)"
    }

    Set-VMFirmware -VMName $VMName -EnableSecureBoot Off | Out-Null
    Write-Host "✔️ [$VMName] secure boot disabled"

    Set-VMFirmware -VMName $VMName -FirstBootDevice $DvdDrive | Out-Null
    Write-Host "✔️ [$VMName] DVD set as default boot device"   
}

Function Download-InstallationImage()
{   
    $IsoDir = [System.IO.Path]::GetDirectoryName($ProxmoxIsoPath)

    if((Test-Path $IsoDir) -ne $true) 
    {
        New-Item -Path $IsoDir -ItemType Directory | Out-Null
    }

    if((Test-Path $ProxmoxIsoPath) -ne $true) 
    {
        Write-Host "Downloading Proxmox Installation image..."
        Invoke-WebRequest -URI $ProxmoxIsoLink -OutFile $ProxmoxIsoPath
        Write-Host "✔️ Proxmox Installation image downloaded"
    }
    else
    {
        Write-Host "✔️ Proxmox Installation image found"
    }
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

Download-InstallationImage

Create-ExternalSwitch
Create-StorageSwitch

$VMCount = 3
$VMNumbers = [System.Linq.Enumerable]::Range(1, $VMCount)

$VMNumbers | ForEach-Object {
    Create-VM "Homecentr-Lab-Node$_"
}