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
iwr 'https://raw.githubusercontent.com/engkufariz/laptop/main/clean-user-folders.ps1' | iex
