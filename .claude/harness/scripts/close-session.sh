#!/usr/bin/env bash
# close-session.sh: 关闭当前会话，标记未评分的行动，可选记录整体评分

set -euo pipefail
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
STATE_FILE="$HARNESS_DIR/state.json"
TRACES_DIR="$HARNESS_DIR/traces"
OUTCOMES_FILE="$HARNESS_DIR/scores/outcomes.jsonl"

OVERALL_SCORE="${1:-}"  # 可选：1-5 整体评分

# Fix #7: Validate overall score is a digit 1-5 if provided
if [[ -n "$OVERALL_SCORE" ]]; then
    if ! [[ "$OVERALL_SCORE" =~ ^[1-5]$ ]]; then
        echo "ERROR: overall score must be a digit 1-5 (got: '$OVERALL_SCORE')" >&2
        exit 1
    fi
fi

# Fix #1: Use export + single-quoted <<'PYEOF' delimiter, access vars via os.environ
# Fix #2: Atomic write for state.json
# Fix #3: Atomic rewrite for trace file
# Fix #4: Use uuid for outcome_id to avoid collision
export STATE_FILE TRACES_DIR OUTCOMES_FILE OVERALL_SCORE
python3 - <<'PYEOF'
import json, os, uuid
from datetime import datetime

state_file = os.environ['STATE_FILE']
traces_dir = os.environ['TRACES_DIR']
outcomes_file = os.environ['OUTCOMES_FILE']
overall_score_str = os.environ['OVERALL_SCORE'].strip()

with open(state_file) as f:
    s = json.load(f)

session_id = s.get('current_session_id')
if not session_id:
    print("没有活跃的会话")
    exit()

trace_file = f"{traces_dir}/{session_id}.jsonl"
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
os.makedirs(os.path.dirname(outcomes_file), exist_ok=True)

outcome_ids_map = {}
for entry in unscored:
    # Fix #4: Use uuid-based outcome_id to avoid collision
    outcome_id = f"out-{today}-{uuid.uuid4().hex[:8]}"
    record = {
        "outcome_id": outcome_id,
        "trace_id": entry['trace_id'],
        "session_id": session_id,
        "timestamp_utc": datetime.utcnow().isoformat() + 'Z',
        "verdict": "no_response",
        "scope": "action"
    }
    with open(outcomes_file, 'a') as f:
        f.write(json.dumps(record, ensure_ascii=False) + '\n')
    s['outcomes_since_last_proposal'] = s.get('outcomes_since_last_proposal', 0) + 1
    outcome_ids_map[entry['trace_id']] = outcome_id

# Fix #3: Atomic rewrite for trace file
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
        tmp_trace = trace_file + '.tmp'
        with open(tmp_trace, 'w') as f:
            f.write('\n'.join(lines) + '\n')
        os.replace(tmp_trace, trace_file)
    except FileNotFoundError:
        pass

# 如果提供了整体评分，记录 session-level outcome
if overall_score_str:
    # Fix #4: uuid-based outcome_id
    overall_outcome_id = f"out-{today}-{uuid.uuid4().hex[:8]}"
    overall_record = {
        "outcome_id": overall_outcome_id,
        "session_id": session_id,
        "timestamp_utc": datetime.utcnow().isoformat() + 'Z',
        "verdict": "accepted",
        "quality": {"overall": int(overall_score_str)},
        "scope": "session"
    }
    with open(outcomes_file, 'a') as f:
        f.write(json.dumps(overall_record, ensure_ascii=False) + '\n')

# 清空当前会话
s['current_session_id'] = None
s['session_action_counter'] = 0

# Fix #2: Atomic write for state.json
tmp_path = state_file + '.tmp'
with open(tmp_path, 'w') as f:
    json.dump(s, f, ensure_ascii=False, indent=2)
os.replace(tmp_path, state_file)

print(f"会话 {session_id} 已关闭")
print(f"  总行动数: {total}")
print(f"  未评分（标记为 no_response）: {len(unscored)}")
if overall_score_str:
    print(f"  整体评分: {overall_score_str}/5")
PYEOF
