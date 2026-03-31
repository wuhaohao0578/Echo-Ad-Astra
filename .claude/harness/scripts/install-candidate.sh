#!/usr/bin/env bash
# install-candidate.sh: 将候选版本安装为活跃 CLAUDE.md
# 用法: install-candidate.sh --candidate <candidate_id>

set -euo pipefail
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$HARNESS_DIR/../.." && pwd)"
STATE_FILE="$HARNESS_DIR/state.json"
CANDIDATES_DIR="$HARNESS_DIR/candidates"

CANDIDATE_ID=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --candidate) CANDIDATE_ID="$2"; shift 2 ;;
        *) shift ;;
    esac
done

if [[ -z "$CANDIDATE_ID" ]]; then
    echo "ERROR: --candidate required" >&2
    echo "用法: install-candidate.sh --candidate <candidate_id>" >&2
    exit 1
fi

CANDIDATE_FILE="$CANDIDATES_DIR/${CANDIDATE_ID}.md"
if [[ ! -f "$CANDIDATE_FILE" ]]; then
    echo "ERROR: 候选文件不存在: $CANDIDATE_FILE" >&2
    exit 1
fi

# Archive current CLAUDE.md if not already done
export STATE_FILE PROJECT_ROOT CANDIDATES_DIR
CURRENT_VERSION=$(python3 - <<'PYEOF'
import json, os
with open(os.environ['STATE_FILE']) as f:
    s = json.load(f)
print(s.get('active_candidate', 'v-unknown'))
PYEOF
)

ARCHIVE_PATH="$CANDIDATES_DIR/${CURRENT_VERSION}.md"
if [[ ! -f "$ARCHIVE_PATH" ]]; then
    cp "$PROJECT_ROOT/CLAUDE.md" "$ARCHIVE_PATH"
    echo "✓ 当前 CLAUDE.md 已归档为 ${CURRENT_VERSION}"
fi

# Strip YAML frontmatter and install
export CANDIDATE_FILE PROJECT_ROOT
python3 - <<'PYEOF'
import re, os

candidate_file = os.environ['CANDIDATE_FILE']
project_root = os.environ['PROJECT_ROOT']
claude_md = os.path.join(project_root, 'CLAUDE.md')

with open(candidate_file) as f:
    content = f.read()

# Remove YAML frontmatter (--- ... ---)
content_clean = re.sub(r'^---\n.*?\n---\n', '', content, flags=re.DOTALL).lstrip()

tmp_path = claude_md + '.tmp'
with open(tmp_path, 'w') as f:
    f.write(content_clean)
os.replace(tmp_path, claude_md)
print("✓ CLAUDE.md 已更新")
PYEOF

# Update state.json
export STATE_FILE CANDIDATE_ID
python3 - <<'PYEOF'
import json, os
from datetime import datetime

state_file = os.environ['STATE_FILE']
candidate_id = os.environ['CANDIDATE_ID']

with open(state_file) as f:
    s = json.load(f)

s['active_candidate'] = candidate_id
s['last_proposal_date'] = datetime.utcnow().strftime('%Y-%m-%d')
s['outcomes_since_last_proposal'] = 0

tmp_path = state_file + '.tmp'
with open(tmp_path, 'w') as f:
    json.dump(s, f, ensure_ascii=False, indent=2)
os.replace(tmp_path, state_file)
PYEOF

# Run validation
bash "$HARNESS_DIR/scripts/validate-harness.sh" || true

# Commit
cd "$PROJECT_ROOT"
git add CLAUDE.md .claude/harness/
git commit -m "meta-harness: 安装候选 ${CANDIDATE_ID}"

echo ""
echo "✓ 候选 ${CANDIDATE_ID} 已安装为活跃 harness"
echo "✓ 已提交到 git"
