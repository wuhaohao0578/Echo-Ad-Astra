#!/usr/bin/env bash
# init-session.sh: 在每次新会话开始时初始化 trace 文件
# 幂等性：同一会话内多次调用只执行一次

set -euo pipefail
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
STATE_FILE="$HARNESS_DIR/state.json"
TRACES_DIR="$HARNESS_DIR/traces"

# 获取今天的日期
TODAY=$(date -u +%Y-%m-%d)

# 读取当前状态
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

# 计算今天的会话序号
SESSION_NUM=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    s = json.load(f)
counter = s.get('daily_session_counter', {})
today_count = counter.get('$TODAY', 0) + 1
print(str(today_count).zfill(3))
")

SESSION_ID="${TODAY}-session-${SESSION_NUM}"

# 创建空 trace 文件
touch "$TRACES_DIR/${SESSION_ID}.jsonl"

# 更新 state.json
python3 - <<PYEOF
import json
from datetime import datetime

with open('$STATE_FILE') as f:
    s = json.load(f)

s['current_session_id'] = '$SESSION_ID'
s['session_start_utc'] = datetime.utcnow().isoformat() + 'Z'
s['session_action_counter'] = 0
counter = s.get('daily_session_counter', {})
counter['$TODAY'] = counter.get('$TODAY', 0) + 1
s['daily_session_counter'] = counter
s['total_sessions_lifetime'] = s.get('total_sessions_lifetime', 0) + 1

with open('$STATE_FILE', 'w') as f:
    json.dump(s, f, ensure_ascii=False, indent=2)
PYEOF

echo "HARNESS_SESSION_ID=$SESSION_ID"
