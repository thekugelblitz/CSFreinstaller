#!/bin/bash
# Filename: CSFreinstaller_v2.sh
# Author: Dhruval Joshi from HostingSpell.com
# Avout: Reinstall CSF with backups and selective restoration options without hassle!

set -euo pipefail

TIMESTAMP=$(date +%F-%H%M%S)
BACKUP_DIR="/root/csfbackup-${TIMESTAMP}"
LOGFILE="/root/CSFreinstaller.log"
INSTALL_LOG="/root/CSF-install.log"

# Log function
log() {
    echo -e "[`date '+%Y-%m-%d %H:%M:%S'`] $*" | tee -a "$LOGFILE"
}

# Check if CSF is installed
check_csf_installed() {
    command -v csf >/dev/null 2>&1
}

# Backup CSF configuration
backup_csf() {
    mkdir -p "$BACKUP_DIR"
    cp -a /etc/csf/* "$BACKUP_DIR" 2>/dev/null || true
    log "✅ CSF configuration backed up to $BACKUP_DIR"
}

# Uninstall CSF
uninstall_csf() {
    if [ -f "/etc/csf/uninstall.sh" ]; then
        bash /etc/csf/uninstall.sh >/dev/null 2>&1
        log "✅ CSF uninstalled successfully."
    else
        log "❌ CSF uninstall script not found."
        exit 1
    fi
}

# Install CSF
install_csf() {
    cd /usr/src || exit 1
    rm -rf csf csf.tgz
    wget -q https://download.configserver.com/csf.tgz || { log "❌ Failed to download CSF."; exit 1; }
    tar -xzf csf.tgz
    cd csf
    sh install.sh > "$INSTALL_LOG" 2>&1 || { log "❌ CSF installation failed. See $INSTALL_LOG"; exit 1; }
    log "✅ CSF installed successfully."
}

# Select backup folder
select_backup_folder() {
    mapfile -t backups < <(find /root -maxdepth 1 -type d -name "csfbackup-*" | sort)
    if [ ${#backups[@]} -eq 0 ]; then
        echo "❌ No CSF backups found."
        read -rp "Do you want to proceed with a fresh CSF install? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            return 1
        else
            echo "Exiting..."
            exit 0
        fi
    fi

    echo -e "\n📂 Available CSF backups:"
    select folder in "${backups[@]}" "Skip restore and keep fresh CSF"; do
        if [[ "$REPLY" -gt 0 && "$REPLY" -le "${#backups[@]}" ]]; then
            SELECTED_BACKUP="$folder"
            return 0
        elif [[ "$REPLY" -eq $((${#backups[@]} + 1)) ]]; then
            echo "⚠️ Skipping restore. Using fresh CSF install."
            return 1
        else
            echo "❌ Invalid choice. Try again."
        fi
    done
}

# Restore component options
restore_components() {
    local files=(
        "csf.conf" "csf.allow" "csf.deny" "csf.ignore" "csf.rignore" "csf.tempban" \
        "csf.pignore" "csf.fignore" "csf.suignore" "csf.logfiles" "csf.resellers" "ui/ui.allow"
    )

    echo -e "\n📦 Select components to restore:"
    select option in "Restore All" "Select Individually" "Skip Restore"; do
        case $option in
            "Restore All")
                for file in "${files[@]}"; do
                    if [ -f "$SELECTED_BACKUP/$file" ]; then
                        cp -f "$SELECTED_BACKUP/$file" "/etc/csf/$file"
                        log "✔️ Restored: $file"
                    fi
                done
                break
                ;;
            "Select Individually")
                for file in "${files[@]}"; do
                    if [ -f "$SELECTED_BACKUP/$file" ]; then
                        read -rp "Restore $file? [y/N]: " confirm
                        if [[ "$confirm" =~ ^[Yy]$ ]]; then
                            cp -f "$SELECTED_BACKUP/$file" "/etc/csf/$file"
                            log "✔️ Restored: $file"
                        fi
                    fi
                done
                break
                ;;
            "Skip Restore")
                echo "⚠️ Skipped restoring configurations."
                break
                ;;
            *)
                echo "❌ Invalid choice. Try again."
                ;;
        esac
    done
}

# Start CSF and LFD
start_csf() {
    csf -r || true
    systemctl restart lfd || {
        echo "❌ LFD failed to start. Check: systemctl status lfd.service";
        exit 1
    }
    log "🚀 CSF and LFD restarted."
}

# ================= MAIN ==================
log "🚀 Starting CSF Reinstaller..."

if check_csf_installed; then
    log "📌 CSF is currently installed."
    backup_csf
    uninstall_csf
else
    log "⚠️ CSF is not currently installed."
fi

install_csf

if select_backup_folder; then
    restore_components
else
    log "ℹ️ Using fresh CSF install without restoring old configurations."
fi

start_csf
log "✅ Script completed. CSF is ready."
exit 0
