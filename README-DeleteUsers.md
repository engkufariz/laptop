# 🔐 Remove Local Users and User Folders (PowerShell Script)

This PowerShell script **permanently deletes** local user accounts and their corresponding profile folders in `C:\Users`, **excluding** protected accounts.

---

## ⚠️ WARNING

> This script performs **irreversible actions**:
> - Deletes local user accounts.
> - Deletes user folders (e.g., `C:\Users\username`).
> - Cannot be undone.

Use this script **with extreme caution** and only if you're fully aware of its consequences.

---

## ✅ Features

- Skips protected accounts:
  - `Administrator`
  - `user-PC`
  - `itadmin`
- Deletes:
  - Local user accounts
  - Profile folders
- Logs:
  - Deleted accounts
  - Deleted folders
  - Errors
  - Size of each deleted folder
- Confirmation prompt before execution

---

### 🔹 One-liner (no download needed):

```powershell
iwr 'https://raw.githubusercontent.com/engkufariz/laptop/main/delete-users.ps1' | iex
