# TCMY Toolkit (PowerShell Utility)
> Created by Fariz

TCMY Toolkit is an all-in-one PowerShell utility designed to assist IT administrators and support personnel in managing Windows endpoints efficiently. It offers a simple interactive menu to perform common administrative tasks like viewing system info, deleting user data, and uninstalling software.

---

## 🔧 Features

### 1. **Show User + Laptop Info**
Displays details including:
- Logged-in user ID and full name
- Hostname, model, serial number
- Ethernet IPv4 address
- Connectivity test to Azure AD DNS (10.32.240.20)

---

### 2. **Delete All Users Folders in `C:\Users`**
Deletes all user profile folders except the following:
- `Administrator`
- `user-PC`
- `itadmin`

⚠️ **Use with caution.** This is a destructive action.

---

### 3. **Delete Personal Folders**
Permanently deletes contents from:
- Downloads
- Documents
- Pictures
- Videos
- Music

A log file is created in the user's profile (`delete-log.txt`).

---

### 4. **Uninstall Installed Software**
Lists all installed programs and allows batch uninstall via selection. Supports both EXE and MSI uninstallers.

---

### 5. **Enable/Disable Seconds in Taskbar Clock**
Toggles visibility of seconds in the Windows taskbar clock.

---

### 6. **Exit**
Closes the script.

---

## ✅ Requirements
- Windows 10 or later
- Administrator privileges (recommended for full functionality)
- PowerShell 5.1 or newer

---

### 🔹 How to Use via One-liner (no download needed):

To run this script directly from PowerShell:

```powershell
iwr 'https://raw.githubusercontent.com/engkufariz/laptop/main/tcmy-toolkit.ps1' | iex
