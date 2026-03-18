#!/bin/bash
echo "[hook] Claude durdu. Özet kontrol:"
echo "--- Backend:"
curl -s http://localhost:3000/health 2>/dev/null && echo " ✓ Çalışıyor" || echo " ✗ Çalışmıyor"
echo "--- Flutter analyze:"
cd "C:/Users/KULLANICI/Desktop/fizyoterapi/mobile" && flutter analyze --no-pub 2>&1 | tail -2
