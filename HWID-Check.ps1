# Self-elevate if not running as admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'powershell.exe'
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`""
    $psi.Verb = 'runas'
    try {
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } catch {
        exit
    }
    exit
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# Hide console window
$consolePtr = (Get-Process -Id $PID).MainWindowHandle
if ($consolePtr -ne 0) {
    Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public class Win32 {
            [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        }
"@
    [Win32]::ShowWindow($consolePtr, 0) # 0 = hide
}

function Format-Value([string]$s) {
    if ([string]::IsNullOrWhiteSpace($s)) { return '<none>' }
    ($s.Trim().ToUpper())
}

function Get-HWIDInfo {
    $rows = @()
    $macs = @()
    try { $macs += Get-NetAdapter -Physical | Where-Object { $_.MacAddress } | Select-Object -ExpandProperty MacAddress } catch {}
    try { $macs += Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter -and $_.MACAddress } | Select-Object -ExpandProperty MACAddress } catch {}
    $macs = $macs | Where-Object { $_ } | Sort-Object -Unique
    if ($macs.Count -eq 0) { $rows += @{ Field = 'MAC_0'; Value = '<none>' } } else { $i = 0; foreach ($m in $macs) { $rows += @{ Field = "MAC_$i"; Value = (Format-Value $m) }; $i++ } }

    $disks = Get-CimInstance Win32_DiskDrive
    $media = Get-CimInstance Win32_PhysicalMedia
    $phys  = $null; try { $phys = Get-PhysicalDisk } catch {}
    foreach ($d in ($disks | Sort-Object Index)) {
        $serial = $null
        try { $pm = $media | Where-Object { $_.Tag -eq $d.DeviceID }; if ($pm) { $serial = $pm.SerialNumber } } catch {}
        if (-not $serial) { try { $serial = $d.SerialNumber } catch {} }
        if (-not $serial -and $phys) { try { $pd = $phys | Where-Object { $_.DeviceId -eq $d.Index }; if ($pd) { $serial = $pd.SerialNumber } } catch {} }
        $serial = ($serial -replace '\\s','')
        $rows += @{ Field = "PhysicalDrive$($d.Index)"; Value = (Format-Value $serial) }
    }

    $cs = Get-CimInstance Win32_ComputerSystemProduct
    $rows += @{ Field = 'System Serial'; Value = (Format-Value $cs.IdentifyingNumber) }
    $rows += @{ Field = 'System UUID'; Value = (Format-Value $cs.UUID) }
    return $rows
}

function Export-HWIDInfo($info) {
    $timestamp = Get-Date -Format "HH.mm.ss_dd.MM.yyyy"
    $path = Join-Path (Split-Path -Parent $PSCommandPath) "$timestamp.txt"
    ($info | ForEach-Object { "{0,-$fieldWidth} | {1}" -f $_.Field, $_.Value }) | Out-File -FilePath $path -Encoding UTF8
    [System.Windows.MessageBox]::Show("Exported to:\n$path","Export Complete")
}

$infoData = Get-HWIDInfo
$fieldWidth = ($infoData | ForEach-Object { $_.Field.Length } | Measure-Object -Maximum).Maximum
$fieldWidth = [Math]::Max($fieldWidth,5) + 2

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="HWID Info" Height="500" Width="600" WindowStartupLocation="CenterScreen" Background="#1E1E1E" Foreground="White" FontFamily="Consolas">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <Border Grid.Row="0" Background="#0C0C0C" CornerRadius="6" Padding="10">
            <ScrollViewer VerticalScrollBarVisibility="Auto">
                <TextBlock Name="InfoBlock" FontSize="14" TextWrapping="NoWrap" />
            </ScrollViewer>
        </Border>
        <StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,10,0,0">
            <Button Name="ExportBtn" Content="Export" Padding="15,5" Background="#007ACC" Foreground="White" BorderThickness="0" FontWeight="Bold" Cursor="Hand" Margin="0,0,5,0"/>
            <Button Name="CloseBtn" Content="Close" Padding="15,5" Background="#444" Foreground="White" BorderThickness="0" Cursor="Hand"/>
        </StackPanel>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$infoBlock = $window.FindName('InfoBlock')
$exportBtn = $window.FindName('ExportBtn')
$closeBtn  = $window.FindName('CloseBtn')

$header = "{0,-$fieldWidth} | {1}" -f 'Field','Current Value'
$separator = ('=' * $header.Length)
$body = $infoData | ForEach-Object { "{0,-$fieldWidth} | {1}" -f $_.Field, $_.Value }
$infoBlock.Text = $header + "`n" + $separator + "`n" + ($body -join "`n")

$exportBtn.Add_Click({ Export-HWIDInfo $infoData })
$closeBtn.Add_Click({ $window.Close() })

$window.ShowDialog() | Out-Null