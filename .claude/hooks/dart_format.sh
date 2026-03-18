#!/bin/bash
FILE=$(node -e "try{console.log(JSON.parse(process.env.CLAUDE_TOOL_INPUT||'{}').file_path||'')}catch(e){}")
[[ "$FILE" == *.dart ]] || exit 0
echo "[hook] dart format: $FILE"
cd "C:/Users/KULLANICI/Desktop/fizyoterapi/mobile" && dart format "$FILE" 2>&1 | tail -3
