#!/usr/bin/env bash
# append-trace.sh: 从 Claude 的响应中提取 TRACE 注释并追加到 trace 文件
# 用法: append-trace.sh --session <session_id> --trace-json '<json>'
# 或者从 stdin 读取包含 <!--TRACE:{...}--> 的响应文本

set -euo pipefail
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
STATE_FILE="$HARNESS_DIR/state.json"
TRACES_DIR="$HARNESS_DIR/traces"

# 读取参数
SESSION_ID=""
TRACE_JSON=""
RESPONSE_TEXT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --session) SESSION_ID="$2"; shift 2 ;;
        --trace-json) TRACE_JSON="$2"; shift 2 ;;
        --response) RESPONSE_TEXT="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# 如果没有提供 session，从 state.json 读取
if [[ -z "$SESSION_ID" ]]; then
    SESSION_ID=$(python3 -c "
import json, sys
with open('$STATE_FILE') as f:
    s = json.load(f)
print(s.get('current_session_id', '') or '')
")
fi

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: No active session. Run init-session.sh first." >&2
    exit 1
fi

# 如果提供了响应文本，从中提取 TRACE 注释
if [[ -n "$RESPONSE_TEXT" ]]; then
    EXTRACTED=$(printf '%s' "$RESPONSE_TEXT" | python3 -c "
import sys, re, json
text = sys.stdin.read()
match = re.search(r'<!--TRACE:(\{.*?\})-->', text, re.DOTALL)
if match:
    print(match.group(1))
")
    if [[ -n "$EXTRACTED" ]]; then
        TRACE_JSON="$EXTRACTED"
    fi
fi

if [[ -z "$TRACE_JSON" ]]; then
    # 没有找到 trace 注释，创建最小 trace
    TRACE_JSON='{}'
fi

# Fix #1: Write TRACE_JSON to temp file and pass path via env var (avoid shell interpolation into Python source)
# Fix #2: Use atomic write (temp file + os.replace) for state.json
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT
printf '%s' "$TRACE_JSON" > "$TMPFILE"

export STATE_FILE TRACES_DIR SESSION_ID TMPFILE

python3 - <<'PYEOF'
import json, os
from datetime import datetime

state_file = os.environ['STATE_FILE']
traces_dir = os.environ['TRACES_DIR']
session_id = os.environ['SESSION_ID']
tmpfile = os.environ['TMPFILE']

with open(state_file) as f:
    s = json.load(f)

seq = s.get('session_action_counter', 0)
# Use session_id from state if available, fall back to env
state_session_id = s.get('current_session_id') or session_id
trace_id = f"{state_session_id}-{str(seq).zfill(4)}"

# Read extra trace data from temp file (safe: no shell interpolation)
try:
    with open(tmpfile) as tf:
        extra = json.load(tf)
except Exception:
    extra = {}

entry = {
    "trace_id": trace_id,
    "session_id": state_session_id,
    "timestamp_utc": datetime.utcnow().isoformat() + 'Z',
    "sequence": seq,
    "outcome": None
}
entry.update(extra)

# Append to trace file
trace_file = f"{traces_dir}/{state_session_id}.jsonl"
with open(trace_file, 'a') as f:
    f.write(json.dumps(entry, ensure_ascii=False) + '\n')

# Atomic state update
s['session_action_counter'] = seq + 1
tmp_path = state_file + '.tmp'
with open(tmp_path, 'w') as f:
    json.dump(s, f, ensure_ascii=False, indent=2)
os.replace(tmp_path, state_file)

print(f"Trace appended: {trace_id}")
PYEOF
