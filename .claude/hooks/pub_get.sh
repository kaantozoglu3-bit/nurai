#!/bin/bash
FILE=$(node -e "try{console.log(JSON.parse(process.env.CLAUDE_TOOL_INPUT||'{}').file_path||'')}catch(e){}")
[[ "$FILE" == *pubspec.yaml* ]] || exit 0
echo "[hook] pubspec.yaml değişti, flutter pub get çalışıyor..."
cd "C:/Users/KULLANICI/Desktop/fizyoterapi/mobile" && flutter pub get 2>&1 | tail -5
