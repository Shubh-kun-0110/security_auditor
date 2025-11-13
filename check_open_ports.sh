#!/bin/bash
FIX=$1

echo "[*] Checking open network ports..."
ss -tuln | awk 'NR>1 {print $1, $5}' | column -t

echo "✅ Open ports listed above. Review manually for suspicious entries."
