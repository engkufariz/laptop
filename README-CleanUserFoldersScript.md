# ⚠️ Clean User Folders PowerShell Script

This PowerShell script permanently deletes **all files and subfolders** from the following user folders:

- Downloads
- Documents
- Pictures
- Videos
- Music

> 🛑 **USE WITH EXTREME CAUTION!**  
> This script **cannot be undone** and is intended for IT professionals or advanced users.

---

## 📜 Features

- Prompts for `"YES"` confirmation before proceeding
- Excludes hidden and system files by default
- Logs all deleted file paths and sizes to a log file (`delete-log.txt`)
- Calculates and displays total space freed for each folder
- Provides clean, user-friendly output with color coding

---

### 🔹 One-liner (no download needed):

```powershell
iwr 'https://raw.githubusercontent.com/engkufariz/laptop/main/clean-user-folders.ps1' | iex
