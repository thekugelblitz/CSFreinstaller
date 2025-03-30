# CSFreinstaller v2
Reinstall CSF with backups and selective restoration options without hassle!

---

A powerful and safe shell script for fully **reinstalling ConfigServer Security & Firewall (CSF)** on cPanel/WHM servers. It includes automatic backups, interactive restoration options, and clean, controlled operations.

---

## 🔧 Features

- ✅ Automatically detects if CSF is installed
- 💾 It creates full backups of all important CSF configurations
- 🧼 Clean uninstallation of existing CSF installation
- 📥 Installs the latest CSF from ConfigServer
- 📂 Interactive backup restore options
- 🔐 Safe and failsafe logic with log output and no re-tries

---

## 🚀 Quick Install

Run this in your terminal (as root):

```bash
wget https://raw.githubusercontent.com/thekugelblitz/CSFreinstaller/main/CSFreinstaller_v2.sh -O CSFreinstaller.sh && chmod +x CSFreinstaller.sh && ./CSFreinstaller.sh
```

---

## 🧠 How It Works

1. Check if CSF is installed
2. If installed, backs up all config files into `/root/csfbackup-YYYY-MM-DD-HHMMSS`
3. Uninstalls CSF completely and cleanly
4. Installs the latest version from ConfigServer
5. Lists available backup folders in `/root/`
6. Offers interactive restore options:
    - Restore all components
    - Restore selected components
    - Skip restore
7. Restarts CSF and LFD
8. Logs everything to `/root/CSFreinstaller.log`

---

## 📂 Backup Components Supported

- `csf.conf`
- `csf.allow`, `csf.deny`, `csf.ignore`, `csf.pignore`, `csf.rignore`
- `csf.logfiles`, `csf.smtpauth`, `csf.syslogs`, `csf.suignore`
- UI-related files: `ui.allow`, messenger templates, etc.

---

## 📄 Logs

- Script Log: `/root/CSFreinstaller.log`
- CSF Install Output: `/root/CSF-install.log`

---

## 🛡️ License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for details.

---

## 👤 Author & Credits

Maintained & Developed by **Dhruval Joshi** from **[HostingSpell](https://hostingspell.com)**  
GitHub Profile: [@thekugelblitz](https://github.com/thekugelblitz) | 
This was created by Dhruval Joshi to use at HostingSpell and optimized with the help of GPT4 later.

If you want to contribute, feel free to fork and submit a PR! 🚀

Pull requests and contributions are welcome!

---
