#!/bin/bash
FIX=$1

echo "[*] Checking for world-writable files..."
FILES=$(find / -xdev -type f -perm -0002 2>/dev/null)

if [[ -n "$FILES" ]]; then
  echo "⚠️  Found world-writable files:"
  echo "$FILES"
  if [[ "$FIX" == "true" ]]; then
    echo "[+] Removing world-writable permissions..."
    echo "$FILES" | xargs chmod o-w
    echo "✅ Fixed."
  fi
else
  echo "✅ No world-writable files found."
fi
