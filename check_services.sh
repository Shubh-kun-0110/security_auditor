#!/bin/bash
# safer check_services.sh
# Usage:
#   ./check_services.sh          -> just list
#   ./check_services.sh --fix    -> attempt to stop/disable (asks confirmation)

FIX_ARG="$1"
FIX=false
if [[ "$FIX_ARG" == "--fix" || "$FIX_ARG" == "true" ]]; then
  FIX=true
fi

LOGFILE="/var/log/security_audit_services_fix.log"

echo "[*] Checking unnecessary running services..."

# Services/patterns we absolutely DON'T want to touch
SAFE_EXCLUDE="(^systemd|^dbus|^ssh|^NetworkManager|^cron|^rsyslog|^gdm\.service$|^user@|^polkit|^accounts-daemon|^udisks2|^upower|^systemd-journal|^systemd-logind|^dbus-broker|^sshd|^systemd-udevd)"

# List running services and exclude safe ones.
# Use column 1 (unit name). Skip header line(s).
SERVICES=$(systemctl list-units --type=service --state=running --no-pager --no-legend \
  | awk '{print $1}' \
  | grep -Ev "$SAFE_EXCLUDE" || true)

if [[ -n "$SERVICES" ]]; then
  echo "⚠️  Potentially unnecessary services detected:"
  echo "$SERVICES"
else
  echo "✅ No potentially unnecessary services detected (after exclusions)."
fi

# If fix requested, prompt and then stop/disable
if [[ "$FIX" == "true" ]]; then
  # require root
  if [[ $EUID -ne 0 ]]; then
    echo "❌ Remediation requires root. Re-run with sudo."
    exit 2
  fi

  if [[ -z "$SERVICES" ]]; then
    echo "Nothing to fix."
    exit 0
  fi

  echo
  echo "You are about to STOP and DISABLE the above services."
  echo "This can affect system behavior (do NOT proceed if you need GUI/login/networking)."
  echo -n "Type 'yes' to proceed: "
  read -r CONFIRM
  if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted remediation."
    exit 0
  fi

  # Ensure logfile exists and is appendable
  touch "$LOGFILE" 2>/dev/null || { echo "⚠️ Cannot write to $LOGFILE; continuing without logfile."; LOGFILE=""
  }
  echo "==== $(date -Iseconds) remediation run ====" >> "$LOGFILE"

  while IFS= read -r svc; do
    # Double-check service still exists/running
    if ! systemctl list-units --type=service --state=running --no-pager --no-legend | awk '{print $1}' | grep -xq "$svc"; then
      echo "[i] $svc is no longer running; skipping."
      echo "[i] $svc skipped (not running) at $(date -Iseconds)" >> "$LOGFILE"
      continue
    fi

    echo "[*] Stopping: $svc"
    if systemctl stop "$svc" 2>/dev/null; then
      echo "[+] Stopped: $svc"
      echo "[+] Stopped: $svc at $(date -Iseconds)" >> "$LOGFILE"
    else
      echo "⚠️ Failed to stop: $svc"
      echo "⚠️ Failed to stop: $svc at $(date -Iseconds)" >> "$LOGFILE"
    fi

    echo "[*] Disabling: $svc"
    if systemctl disable "$svc" 2>/dev/null; then
      echo "[+] Disabled: $svc"
      echo "[+] Disabled: $svc at $(date -Iseconds)" >> "$LOGFILE"
    else
      echo "⚠️ Failed to disable: $svc"
      echo "⚠️ Failed to disable: $svc at $(date -Iseconds)" >> "$LOGFILE"
    fi
  done <<< "$SERVICES"

  echo "✅ Remediation finished. See $LOGFILE for details (if writable)."
fi
