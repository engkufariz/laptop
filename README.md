# 🛠️ TCMY Toolkit (PowerShell Menu Script)

This PowerShell script provides a graphical-like menu interface for performing common administrative tasks on Windows machines. It is designed to assist IT support staff in quickly gathering system/user info, performing cleanup tasks, or uninstalling software interactively.

---

## 📦 Features

### 1. **Show User + Laptop Info**
- Displays:
  - Logged-in user ID and full name
  - Hostname, model, and serial number of the laptop
  - Ethernet IPv4 address (excluding APIPA)
- Performs a ping test to Azure AD DNS (`10.32.240.20`)

### 2. **Delete All User Personal Folders**
- Deletes content in the **Downloads, Documents, Pictures, Videos, and Music** folders of the current user.
- A log of all deleted files (with size) is saved in the user's profile as `delete-log.txt`.

### 3. **Delete All User Profiles in C:\Users**
- Deletes all folders in `C:\Users` **except**:
  - `Administrator`
  - `user-PC`
  - `itadmin`
- Creates a deletion log in: `C:\Users\Public\delete_folders_log_<timestamp>.txt`

### 4. **Uninstall Installed Software**
- Lists all installed software (from both 32-bit and 64-bit registries)
- Allows the user to select software by number for batch uninstallation
- Launches the uninstallers one by one

### 5. **Exit**
- Exits the script.

---

## ⚠️ Warnings

- **Deletion operations are irreversible.** Use with extreme caution.
- Prompts are built-in for confirmation, and the script logs actions where applicable.
- For accurate results, run this script with **administrative privileges**.

---

### 🔹 One-liner (no download needed):

To run this script directly from PowerShell:

```powershell
iwr 'https://raw.githubusercontent.com/engkufariz/laptop/main/tcmy-toolkit.ps1' | iex
