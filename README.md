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

## ⚠️ Privacy & Security
This script runs entirely locally. No data is sent to any server. You can audit the code directly in any text editor.

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.