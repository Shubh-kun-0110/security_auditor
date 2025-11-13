#!/bin/bash
# Basic Linux Security Auditor
# Run: sudo ./audit.sh [--fix]

FIX_MODE=false
if [[ "$1" == "--fix" ]]; then
  FIX_MODE=true
fi

MODULES_DIR="./modules"

echo "🔍 Running Basic Security Audit..."
echo "==================================="

bash "$MODULES_DIR/check_world_writable.sh" "$FIX_MODE"
bash "$MODULES_DIR/check_empty_passwords.sh" "$FIX_MODE"
bash "$MODULES_DIR/check_services.sh" "$FIX_MODE"
bash "$MODULES_DIR/check_open_ports.sh" "$FIX_MODE"

echo "==================================="
echo "✅ Audit complete."
