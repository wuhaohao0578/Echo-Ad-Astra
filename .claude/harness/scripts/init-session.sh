#!/usr/bin/env bash
# init-session.sh: 在每次新会话开始时初始化 trace 文件
# 幂等性：同一会话内多次调用只执行一次

set -euo pipefail
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
STATE_FILE="$HARNESS_DIR/state.json"
TRACES_DIR="$HARNESS_DIR/traces"

# 获取今天的日期
TODAY=$(date -u +%Y-%m-%d)

# 读取当前状态（检查幂等性）
CURRENT_SESSION=$(python3 -c "
import json, sys
with open('$STATE_FILE') as f:
    s = json.load(f)
print(s.get('current_session_id', '') or '')
")

# 如果当前会话已经是今天的，检查是否需要新建
if [[ "$CURRENT_SESSION" == "${TODAY}-session-"* ]]; then
    # 会话已存在，幂等返回
    echo "HARNESS_SESSION_ID=$CURRENT_SESSION"
    exit 0
fi

# Fix #5: Combine both Python subprocesses into one to avoid TOCTOU race on session counter
# Fix #1: Use export + single-quoted <<'PYEOF' delimiter, access vars via os.environ
# Fix #2: Use atomic write (temp file + os.replace) for state.json
export STATE_FILE TRACES_DIR TODAY

SESSION_ID=$(python3 - <<'PYEOF'
import json, os, tempfile
from datetime import datetime

state_file = os.environ['STATE_FILE']
traces_dir = os.environ['TRACES_DIR']
today = os.environ['TODAY']

with open(state_file) as f:
    s = json.load(f)

# Compute session number atomically in the same process
counter = s.get('daily_session_counter', {})
today_count = counter.get(today, 0) + 1
session_num = str(today_count).zfill(3)
session_id = f"{today}-session-{session_num}"

# Create empty trace file
os.makedirs(traces_dir, exist_ok=True)
trace_path = f"{traces_dir}/{session_id}.jsonl"
open(trace_path, 'a').close()

# Update state
s['current_session_id'] = session_id
s['session_start_utc'] = datetime.utcnow().isoformat() + 'Z'
s['session_action_counter'] = 0
counter[today] = today_count
s['daily_session_counter'] = counter
s['total_sessions_lifetime'] = s.get('total_sessions_lifetime', 0) + 1

# Atomic write
tmp_path = state_file + '.tmp'
with open(tmp_path, 'w') as f:
    json.dump(s, f, ensure_ascii=False, indent=2)
os.replace(tmp_path, state_file)

print(session_id)
PYEOF
)

echo "HARNESS_SESSION_ID=$SESSION_ID"
