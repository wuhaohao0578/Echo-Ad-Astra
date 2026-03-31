#!/usr/bin/env bash
# close-session.sh: 关闭当前会话，标记未评分的行动，可选记录整体评分

set -euo pipefail
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
STATE_FILE="$HARNESS_DIR/state.json"
TRACES_DIR="$HARNESS_DIR/traces"
OUTCOMES_FILE="$HARNESS_DIR/scores/outcomes.jsonl"

OVERALL_SCORE="${1:-}"  # 可选：1-5 整体评分

python3 - <<PYEOF
import json, os
from datetime import datetime

with open('$STATE_FILE') as f:
    s = json.load(f)

session_id = s.get('current_session_id')
if not session_id:
    print("没有活跃的会话")
    exit()

trace_file = f"$TRACES_DIR/{session_id}.jsonl"
try:
    with open(trace_file) as f:
        entries = [json.loads(line) for line in f if line.strip()]
except FileNotFoundError:
    entries = []

# 统计
total = len(entries)
unscored = [e for e in entries if e.get('outcome') is None]

# 将未评分的标记为 no_response
today = datetime.utcnow().strftime('%Y-%m-%d')
os.makedirs(os.path.dirname('$OUTCOMES_FILE'), exist_ok=True)
try:
    with open('$OUTCOMES_FILE') as f:
        count = sum(1 for _ in f)
except FileNotFoundError:
    count = 0

outcome_ids_map = {}
for entry in unscored:
    outcome_id = f"out-{today}-{str(count).zfill(4)}"
    count += 1
    record = {
        "outcome_id": outcome_id,
        "trace_id": entry['trace_id'],
        "session_id": session_id,
        "timestamp_utc": datetime.utcnow().isoformat() + 'Z',
        "verdict": "no_response",
        "scope": "action"
    }
    with open('$OUTCOMES_FILE', 'a') as f:
        f.write(json.dumps(record, ensure_ascii=False) + '\n')
    s['outcomes_since_last_proposal'] = s.get('outcomes_since_last_proposal', 0) + 1
    outcome_ids_map[entry['trace_id']] = outcome_id

# 更新 trace 文件中的 outcome 字段
if outcome_ids_map:
    try:
        lines = []
        with open(trace_file) as f:
            for line in f:
                if line.strip():
                    entry = json.loads(line)
                    if entry.get('trace_id') in outcome_ids_map:
                        entry['outcome'] = outcome_ids_map[entry['trace_id']]
                    lines.append(json.dumps(entry, ensure_ascii=False))
        with open(trace_file, 'w') as f:
            f.write('\n'.join(lines) + '\n')
    except FileNotFoundError:
        pass

# 如果提供了整体评分，记录 session-level outcome
overall = '$OVERALL_SCORE'.strip()
if overall:
    overall_record = {
        "outcome_id": f"out-{today}-{str(count).zfill(4)}",
        "session_id": session_id,
        "timestamp_utc": datetime.utcnow().isoformat() + 'Z',
        "verdict": "accepted",
        "quality": {"overall": int(overall)},
        "scope": "session"
    }
    with open('$OUTCOMES_FILE', 'a') as f:
        f.write(json.dumps(overall_record, ensure_ascii=False) + '\n')

# 清空当前会话
s['current_session_id'] = None
s['session_action_counter'] = 0
with open('$STATE_FILE', 'w') as f:
    json.dump(s, f, ensure_ascii=False, indent=2)

print(f"会话 {session_id} 已关闭")
print(f"  总行动数: {total}")
print(f"  未评分（标记为 no_response）: {len(unscored)}")
if overall:
    print(f"  整体评分: {overall}/5")
PYEOF
