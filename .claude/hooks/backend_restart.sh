#!/bin/bash
FILE=$(node -e "try{console.log(JSON.parse(process.env.CLAUDE_TOOL_INPUT||'{}').file_path||'')}catch(e){}")
[[ "$FILE" == *server.js* ]] || [[ "$FILE" == *routes* ]] || [[ "$FILE" == *middleware* ]] || exit 0
echo "[hook] Backend dosyası değişti, yeniden başlatılıyor..."
pkill -f 'node server.js' 2>/dev/null
sleep 1
LOG_DIR="C:/Users/KULLANICI/Desktop/fizyoterapi/.claude/logs"
mkdir -p "$LOG_DIR"
cd "C:/Users/KULLANICI/Desktop/fizyoterapi/backend" && nohup node server.js > "$LOG_DIR/backend.log" 2>&1 &
echo "[hook] Backend yeniden başlatıldı (PID: $!)"
