$VMCount = 3
$VMNumbers = [System.Linq.Enumerable]::Range(1, $VMCount)

$VMNumbers | ForEach-Object -Parallel {
    $VMName = "Homecentr-Lab-Node$_"

    $VM = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if($VM) {
        Stop-VM $VMName -Force -TurnOff
        Write-Host "✔️ [$VMName] Stopped"

        $VMDrives = Get-VMHardDiskDrive -VMName $VMName | ForEach-Object -Parallel {
            Remove-VMHardDiskDrive  -VMName $using:VMName `
                                    -ControllerType $_.ControllerType `
                                    -ControllerNumber $_.ControllerNumber `
                                    -ControllerLocation $_.ControllerLocation
            
            Write-Host "✔️ [$using:VMName] Disk $($_.ControllerType)/$($_.ControllerNumber)/$($_.ControllerLocation) removed"

            if(Test-Path $_.Path)
            {
                Remove-Item $_.Path -Force
                Write-Host "✔️ [$using:VMName] Vhdx file $($_.Path) removed"
            }
        }

        Remove-VM $VMName -Force
        Write-Host "✔️ [$VMName] Removed"
    }
    else {
        Write-Host "✔️ [$VMName] Already removed"
    }
}