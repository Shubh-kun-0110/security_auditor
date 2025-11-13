#!/bin/bash
FIX=$1

echo "[*] Checking for accounts with empty passwords..."
EMPTY_USERS=$(awk -F: '($2 == "") {print $1}' /etc/shadow)

if [[ -n "$EMPTY_USERS" ]]; then
  echo "⚠️  Accounts with empty passwords: $EMPTY_USERS"
  if [[ "$FIX" == "true" ]]; then
    for user in $EMPTY_USERS; do
      passwd -l "$user"
      echo "[+] Locked account: $user"
    done
  fi
else
  echo "✅ No empty-password accounts found."
fi
