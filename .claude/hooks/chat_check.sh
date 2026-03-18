#!/bin/bash
FILE=$(node -e "try{console.log(JSON.parse(process.env.CLAUDE_TOOL_INPUT||'{}').file_path||'')}catch(e){}")
[[ "$FILE" == *chat_screen* ]] || [[ "$FILE" == *openai.service* ]] || exit 0
echo "[hook] AI chat dosyası değişti, backend kontrol ediliyor..."
RESPONSE=$(curl -s http://localhost:3000/health 2>/dev/null)
if [ -z "$RESPONSE" ]; then
  echo "[hook] ✗ Backend çalışmıyor"
else
  echo "[hook] ✓ Backend çalışıyor"
fi
