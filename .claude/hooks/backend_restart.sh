#!/bin/bash
FILE=$(node -e "try{console.log(JSON.parse(process.env.CLAUDE_TOOL_INPUT||'{}').file_path||'')}catch(e){}")
[[ "$FILE" == *server.js* ]] || [[ "$FILE" == *routes* ]] || [[ "$FILE" == *middleware* ]] || exit 0
echo "[hook] Backend dosyası değişti, yeniden başlatılıyor..."
pkill -f 'node server.js' 2>/dev/null
sleep 1
cd "C:/Users/KULLANICI/Desktop/fizyoterapi/backend" && nohup node server.js > /tmp/backend.log 2>&1 &
echo "[hook] Backend yeniden başlatıldı (PID: $!)"
