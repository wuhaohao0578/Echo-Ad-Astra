#!/usr/bin/env bash
# score-outcome.sh: 记录用户对某个行动的 outcome
# 用法: score-outcome.sh --verdict <accepted|modified|rejected> [--trace-id <id>]
#       [--quality <dim>:<score>] [--note "<text>"] [--mod-type <type>]

set -euo pipefail
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
STATE_FILE="$HARNESS_DIR/state.json"
TRACES_DIR="$HARNESS_DIR/traces"
OUTCOMES_FILE="$HARNESS_DIR/scores/outcomes.jsonl"

VERDICT=""
TRACE_ID=""
QUALITY_ARGS=()
NOTE=""
MOD_TYPE=""
MOD_DESC=""
WORKFLOW=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --verdict) VERDICT="$2"; shift 2 ;;
        --trace-id) TRACE_ID="$2"; shift 2 ;;
        --quality) QUALITY_ARGS+=("$2"); shift 2 ;;
        --note) NOTE="$2"; shift 2 ;;
        --mod-type) MOD_TYPE="$2"; shift 2 ;;
        --mod-desc) MOD_DESC="$2"; shift 2 ;;
        --workflow) WORKFLOW="$2"; shift 2 ;;
        *) shift ;;
    esac
done

if [[ -z "$VERDICT" ]]; then
    echo "ERROR: --verdict required (accepted|modified|rejected|no_response)" >&2
    exit 1
fi

# 如果没有提供 trace_id，使用最新的
if [[ -z "$TRACE_ID" ]]; then
    TRACE_ID=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    s = json.load(f)
session_id = s.get('current_session_id', '')
seq = max(s.get('session_action_counter', 1) - 1, 0)
print(f'{session_id}-{str(seq).zfill(4)}')
")
fi

# Write QUALITY_ARGS to a temp file as JSON to avoid shell/python quoting issues
QUALITY_TMPFILE=$(mktemp)
PARAMS_TMPFILE=$(mktemp)
trap 'rm -f "$QUALITY_TMPFILE" "$PARAMS_TMPFILE"' EXIT

# Serialize quality args to JSON array via python (last arg is the output file)
python3 -c "
import json, sys
outfile = sys.argv[-1]
args = sys.argv[1:-1]
with open(outfile, 'w') as f:
    json.dump(args, f)
" "${QUALITY_ARGS[@]+"${QUALITY_ARGS[@]}"}" "$QUALITY_TMPFILE"

# Write other params to a JSON file to avoid heredoc quoting issues
python3 -c "
import json, sys
params = {
    'verdict': sys.argv[1],
    'trace_id': sys.argv[2],
    'workflow': sys.argv[3],
    'note': sys.argv[4],
    'mod_type': sys.argv[5],
    'mod_desc': sys.argv[6],
}
with open(sys.argv[7], 'w') as f:
    json.dump(params, f)
" "$VERDICT" "$TRACE_ID" "$WORKFLOW" "$NOTE" "$MOD_TYPE" "$MOD_DESC" "$PARAMS_TMPFILE"

STATE_FILE="$STATE_FILE" OUTCOMES_FILE="$OUTCOMES_FILE" TRACES_DIR="$TRACES_DIR" QUALITY_TMPFILE="$QUALITY_TMPFILE" PARAMS_TMPFILE="$PARAMS_TMPFILE" python3 - <<'PYEOF'
import json, os, sys
from datetime import datetime

# Read params from temp files (injected via env)
state_file = os.environ['STATE_FILE']
outcomes_file = os.environ['OUTCOMES_FILE']
traces_dir = os.environ['TRACES_DIR']
quality_tmpfile = os.environ['QUALITY_TMPFILE']
params_tmpfile = os.environ['PARAMS_TMPFILE']

with open(params_tmpfile) as f:
    params = json.load(f)

verdict = params['verdict']
trace_id = params['trace_id']
workflow = params['workflow']
note = params['note']
mod_type = params['mod_type']
mod_desc = params['mod_desc']

with open(quality_tmpfile) as f:
    quality_args = json.load(f)

# 生成 outcome_id
today = datetime.utcnow().strftime('%Y-%m-%d')
os.makedirs(os.path.dirname(outcomes_file), exist_ok=True)
try:
    with open(outcomes_file) as f:
        count = sum(1 for _ in f)
except FileNotFoundError:
    count = 0

outcome_id = f"out-{today}-{str(count).zfill(4)}"

# 解析 quality 参数
quality = {}
for q in quality_args:
    if ':' in q:
        dim, score = q.split(':', 1)
        try:
            quality[dim.strip()] = int(score.strip())
        except ValueError:
            pass

# 构建 outcome record
record = {
    "outcome_id": outcome_id,
    "trace_id": trace_id,
    "session_id": '-'.join(trace_id.split('-')[:5]) if trace_id else "",
    "timestamp_utc": datetime.utcnow().isoformat() + 'Z',
    "workflow": workflow if workflow else None,
    "verdict": verdict,
    "quality": quality if quality else None,
    "scope": "action",
    "note": note if note else None
}

if mod_type:
    record["modification"] = {
        "type": mod_type,
        "description": mod_desc
    }

# 追加到 outcomes.jsonl
with open(outcomes_file, 'a') as f:
    f.write(json.dumps(record, ensure_ascii=False) + '\n')

# 更新 state.json
with open(state_file) as f:
    s = json.load(f)
s['outcomes_since_last_proposal'] = s.get('outcomes_since_last_proposal', 0) + 1
with open(state_file, 'w') as f:
    json.dump(s, f, ensure_ascii=False, indent=2)

# 更新对应 trace 的 outcome 字段
parts = trace_id.split('-')
# trace_id format: YYYY-MM-DD-session-NNN-NNNN
# session_id is first 5 parts: YYYY-MM-DD-session-NNN
if len(parts) >= 6:
    session_id = '-'.join(parts[:5])
    trace_file = f"{traces_dir}/{session_id}.jsonl"
    try:
        lines = []
        with open(trace_file) as f:
            for line in f:
                if line.strip():
                    entry = json.loads(line)
                    if entry.get('trace_id') == trace_id:
                        entry['outcome'] = outcome_id
                    lines.append(json.dumps(entry, ensure_ascii=False))
        with open(trace_file, 'w') as f:
            f.write('\n'.join(lines) + '\n')
    except FileNotFoundError:
        pass

print(f"Outcome recorded: {outcome_id} (verdict: {verdict})")

# 提示是否需要运行 proposer
threshold = 50
outcomes_count = s['outcomes_since_last_proposal']
if outcomes_count >= threshold:
    print(f"\n⚡ 已累积 {outcomes_count} 个 outcomes，建议运行改进提案：输入 '/propose'")
PYEOF
