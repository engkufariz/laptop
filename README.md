# 🖥️ Display User & Laptop Information Script

This PowerShell script displays essential information about the current user and laptop, including:

- User login ID and full name
- Hostname, device model, and serial number
- IPv4 address (Ethernet only)
- Ping test to Azure AD server (10.32.240.20)

---

## 📥 Usage (Quick Run Without Download)

To run this script directly from PowerShell:

iwr 'https://raw.githubusercontent.com/engkufariz/laptop/main/display-details.ps1' | iex

# ⚠️ Clean User Folders Script (PowerShell)

This script **permanently deletes all files and folders** inside these directories for the **current Windows user**:

- Downloads  
- Documents  
- Pictures  
- Videos  
- Music

---

## ⚠️ WARNING

> ⚠️ This action is irreversible. Use this script only when you're 100% sure.
>
> Every folder is individually confirmed before deletion.

---

## 📥 How to Run (One-Liner)

```powershell
iwr 'https://raw.githubusercontent.com/yourusername/repo/main/clean-user-folders.ps1' | iex
