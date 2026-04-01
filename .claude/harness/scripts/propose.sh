#!/usr/bin/env bash
# propose.sh: 收集全量上下文，生成 CLAUDE.md 改进提案
# 用法: propose.sh [--window-days 30] [--force]

set -euo pipefail
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$HARNESS_DIR/../.." && pwd)"
STATE_FILE="$HARNESS_DIR/state.json"
METRICS_FILE="$HARNESS_DIR/scores/metrics.json"
PROPOSALS_DIR="$HARNESS_DIR/proposals"
CANDIDATES_DIR="$HARNESS_DIR/candidates"
TRACES_DIR="$HARNESS_DIR/traces"
OUTCOMES_FILE="$HARNESS_DIR/scores/outcomes.jsonl"
TEMPLATE="$HARNESS_DIR/proposer-prompt-template.md"

WINDOW_DAYS=30
FORCE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --window-days) WINDOW_DAYS="$2"; shift 2 ;;
        --force) FORCE=true; shift ;;
        *) shift ;;
    esac
done

# Check threshold
export STATE_FILE FORCE
python3 - <<'PYEOF'
import json, os, sys
with open(os.environ['STATE_FILE']) as f:
    s = json.load(f)
outcomes_count = s.get('outcomes_since_last_proposal', 0)
force = os.environ.get('FORCE', 'false').lower() == 'true'
if not force and outcomes_count < 200:
    print(f"当前 outcomes 数量（{outcomes_count}）未达到阈值（200）。", file=sys.stderr)
    print("使用 --force 强制运行，或等待更多交互数据积累。", file=sys.stderr)
    sys.exit(1)
PYEOF

echo "正在收集全量上下文..."

# Refresh metrics
bash "$HARNESS_DIR/scripts/aggregate-metrics.sh" "$WINDOW_DAYS"

TODAY=$(date -u +%Y-%m-%d)
PROPOSAL_FILE="$PROPOSALS_DIR/${TODAY}-proposal.md"

# Collect traces (last WINDOW_DAYS days)
export TRACES_DIR WINDOW_DAYS
TRACES_CONTEXT=$(python3 - <<'PYEOF'
import os, json
from datetime import datetime, timedelta

cutoff = (datetime.now() - timedelta(days=int(os.environ['WINDOW_DAYS']))).strftime('%Y-%m-%d')
traces_dir = os.environ['TRACES_DIR']
output_parts = []

try:
    for fname in sorted(os.listdir(traces_dir)):
        if fname.endswith('.jsonl'):
            date_part = fname[:10]
            if date_part >= cutoff:
                fpath = os.path.join(traces_dir, fname)
                with open(fpath) as f:
                    content = f.read().strip()
                if content:
                    output_parts.append(f"=== {fname} ===\n{content}")
except FileNotFoundError:
    pass

print('\n\n'.join(output_parts))
PYEOF
)

echo "Traces 收集完成（$(echo "$TRACES_CONTEXT" | wc -l) 行）"

# Collect recent proposals (last 3)
RECENT_PROPOSALS=""
if ls "$PROPOSALS_DIR"/*.md 2>/dev/null | head -1 > /dev/null; then
    for f in $(ls -t "$PROPOSALS_DIR"/*.md 2>/dev/null | head -3); do
        RECENT_PROPOSALS="${RECENT_PROPOSALS}

=== $(basename $f) ===
$(cat "$f")"
    done
fi

# Collect candidate diffs (last 2 vs current)
CANDIDATE_DIFFS=""
LATEST_CANDIDATES=()
while IFS= read -r line; do
    LATEST_CANDIDATES+=("$line")
done < <(ls -t "$CANDIDATES_DIR"/*.md 2>/dev/null | head -3)
if [[ ${#LATEST_CANDIDATES[@]} -ge 2 ]]; then
    for ((i=${#LATEST_CANDIDATES[@]}-1; i>0; i--)); do
        PREV="${LATEST_CANDIDATES[$i]}"
        CURR="${LATEST_CANDIDATES[$((i-1))]}"
        CANDIDATE_DIFFS="${CANDIDATE_DIFFS}

=== diff: $(basename "$PREV") → $(basename "$CURR") ===
$(diff "$PREV" "$CURR" 2>/dev/null || true)"
    done
fi

# Read template and current files
TEMPLATE_CONTENT=$(cat "$TEMPLATE" 2>/dev/null || echo "Generate improvement proposals for CLAUDE.md based on trace evidence.")
CURRENT_CLAUDE=$(cat "$PROJECT_ROOT/CLAUDE.md")
METRICS_CONTENT=$(cat "$METRICS_FILE" 2>/dev/null || echo "{}")
OUTCOMES_CONTENT=$(cat "$OUTCOMES_FILE" 2>/dev/null || echo "")

echo "构建 proposer 提示..."

# Write prompt to temp file
TMPFILE=$(mktemp /tmp/harness_proposer_XXXXXX.txt)
trap 'rm -f "$TMPFILE"' EXIT

cat > "$TMPFILE" << PROMPT
${TEMPLATE_CONTENT}

---

## 当前 CLAUDE.md

${CURRENT_CLAUDE}

---

## metrics.json

${METRICS_CONTENT}

---

## Trace 历史（近 ${WINDOW_DAYS} 天）

${TRACES_CONTEXT}

---

## Outcomes 记录

${OUTCOMES_CONTENT}

---

## 最近提案历史

${RECENT_PROPOSALS}

---

## 候选版本演进差异

${CANDIDATE_DIFFS}

---

请生成改进提案，输出格式为完整的 Markdown，以 YAML frontmatter 开头。
PROMPT

echo "运行 proposer 代理..."
echo "（上下文大小: $(wc -c < "$TMPFILE") 字节）"

# Invoke Claude CLI - try different invocation methods
if command -v claude &>/dev/null; then
    claude -p "$(cat "$TMPFILE")" > "$PROPOSAL_FILE" 2>&1
else
    echo "⚠ claude CLI 未找到。提示已保存到: $TMPFILE" >&2
    echo "手动运行: claude -p \"\$(cat $TMPFILE)\" > $PROPOSAL_FILE" >&2
    cp "$TMPFILE" "$PROPOSALS_DIR/${TODAY}-prompt.txt"
    echo "提示已保存到: $PROPOSALS_DIR/${TODAY}-prompt.txt"
    exit 0
fi

echo ""
echo "✓ 提案已生成: $PROPOSAL_FILE"
echo ""
echo "请阅读提案后，如需采用，运行："
echo "  .claude/harness/scripts/install-candidate.sh --candidate <candidate_id>"
