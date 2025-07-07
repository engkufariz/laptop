# 🖥️ Display User & Laptop Information Script

This PowerShell script displays essential information about the current user and laptop, including:

- User login ID and full name
- Hostname, device model, and serial number
- IPv4 address (Ethernet only)
- Ping test to Azure AD server (10.32.240.20)

---

### 🔹 One-liner (no download needed):

To run this script directly from PowerShell:

```powershell
iwr 'https://raw.githubusercontent.com/engkufariz/laptop/main/display-details.ps1' | iex
