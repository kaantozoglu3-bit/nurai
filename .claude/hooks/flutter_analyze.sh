#!/bin/bash
FILE=$(node -e "try{console.log(JSON.parse(process.env.CLAUDE_TOOL_INPUT||'{}').file_path||'')}catch(e){}")
[[ "$FILE" == *.dart ]] || exit 0
echo "[hook] dart analyze: $FILE"
dart analyze "$FILE" 2>&1 | grep -E '(error|warning|hint|No issues found)' | head -10
