# 🛠️ PowerShell Utility Toolkit

A PowerShell-based utility script designed to simplify **system maintenance**, **network troubleshooting**, and **user profile cleanup** for IT support and system administrators.

> ⚠️ Use responsibly. Some features perform irreversible actions (e.g., deleting user folders).

---

## 📌 Main Menu Features

```
1. Show User + Laptop Info
2. Basic Network Troubleshooting Tools
3. Delete All Users Folders in C:\Users
4. Delete Personal Folders (Downloads, Documents, etc.)
5. Uninstall Installed Software (select manually)
6. Toggle Seconds In Taskbar Clock
```

---

## 🌐 Basic Network Troubleshooting Tools

When selecting option 2, you'll see the following submenu:

```
1. Check Network Adapter Status
2. View IP Configuration
3. Check Default Gateway
4. DNS Resolution Test
5. Ping Test (custom or 8.8.8.8)
6. Traceroute Test (custom or 8.8.8.8)
7. Perform All Maintenance Tasks (FlushDNS + RegisterDNS + ReleaseIP + RenewIP)
```

These tools help identify network issues quickly with minimal user input.

---

## 🚀 How to Run the Script via PowerShell

Copy and paste below command (no need to download anything)

```
iwr 'https://tinyurl.com/tcmy-toolkit' | iex
```

> 🔒 For full functionality (e.g., uninstalling apps or flushing DNS), run PowerShell as **Administrator**.

---

## 🧹 Cleanup Tools

- **Delete All Users in `C:\Users`**  
  Removes all non-system user profiles. Useful for reimaging or reissuing laptops.

- **Delete Personal Folders**  
  Clears Downloads, Documents, Pictures, Music, and Videos folders for the current user account.

---

## 📡 Network Tools Summary

- **Adapter Status** – Check if network interfaces are up/down
- **IP Config** – Get current IP address, gateway, and DNS
- **Ping & Traceroute** – Custom or default to 8.8.8.8
- **FlushDNS / Renew IP** – Clear cached entries and refresh IP

---

## 📁 Project Structure

```
PowerShell-Toolkit/
│
├── tcmy-toolkit.ps1              # Main PowerShell script
├── README.md                # This file
├── LICENSE                  # MIT License

```

---

## ✍️ Author

Developed by **Engku Ahmad Fariz**  
📧 For support, bug reports, or improvements — please open a GitHub issue.

---

## ⭐️ Like it?

If you find this script helpful, give it a ⭐ on GitHub and share with your team!
