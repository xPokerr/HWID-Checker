# PowerShell HWID Checker

A lightweight, GUI-based tool written in PowerShell to retrieve and verify Hardware IDs (HWIDs). This tool uses Windows Presentation Foundation (WPF) to display data in a modern, dark-themed interface.

## 🚀 Features
- **GUI Interface**: Clean WPF-based window (no console spam).
- **Auto-Elevation**: Automatically requests Administrator privileges to access SMBIOS and physical disk data.
- **Deep Retrieval**: Fetches:
  - MAC Addresses (Physical & Virtual).
  - Disk Serial Numbers (via `Win32_PhysicalMedia`, `Win32_DiskDrive`, and `Get-PhysicalDisk`).
  - System Serial & UUID (`Win32_ComputerSystemProduct`).
- **Export Function**: Save results to a timestamped `.txt` file with one click.

## 📋 Requirements
- Windows 10 or Windows 11
- PowerShell 5.1 or newer

## 📦 Installation & Usage
1. Download the `HWID-Check.ps1` file.
2. Right-click the file and select **Run with PowerShell**.
3. Accept the UAC prompt (Admin rights are required to read hardware serials).

## 🔧 Troubleshooting

### "File is not digitally signed" Error
If you encounter an error message similar to this when running the script:
> `...HWID-Check.ps1 is not digitally signed. The script will not execute on the system.`

This is a standard Windows security feature that blocks scripts downloaded from the internet. You can fix this easily using one of the methods below.

#### Method 1: Unblock the File (Recommended)
This removes the "Mark of the Web" restriction from the file.
1. Open PowerShell in the folder where the script is located.
2. Run the following command:
   ```powershell
   Unblock-File -Path .\HWID-Check.ps1
3. Run the script again normally.

#### Method 2: Bypass Execution Policy
If you prefer not to unblock the file, you can launch it with a temporary policy bypass:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\HWID-Check.ps1
```

## ⚠️ Privacy & Security
This script runs entirely locally. No data is sent to any server. You can audit the code directly in any text editor.

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.
