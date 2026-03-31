#!/usr/bin/env bash
# validate-harness.sh: 验证 harness 数据完整性
# 退出码: 0=健康, 1=有警告, 2=有错误

set -uo pipefail
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$HARNESS_DIR/../.." && pwd)"
STATE_FILE="$HARNESS_DIR/state.json"
TRACES_DIR="$HARNESS_DIR/traces"

WARNINGS=0
ERRORS=0

echo "=== Harness 完整性检查 ==="

# Check state.json
if python3 -c "
import json, sys
try:
    with open('$STATE_FILE') as f:
        s = json.load(f)
    required = ['harness_version', 'active_candidate', 'total_sessions_lifetime']
    missing = [k for k in required if k not in s]
    if missing:
        print(f'缺少字段: {missing}', file=sys.stderr)
        sys.exit(1)
except json.JSONDecodeError as e:
    print(f'JSON 解析失败: {e}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null; then
    echo "✓ state.json 格式有效"
else
    echo "✗ state.json 无效"
    ERRORS=$((ERRORS+1))
fi

# Check CLAUDE.md
if [[ -f "$PROJECT_ROOT/CLAUDE.md" ]]; then
    echo "✓ CLAUDE.md 存在"
else
    echo "✗ CLAUDE.md 不存在"
    ERRORS=$((ERRORS+1))
fi

# Check active candidate is archived
ACTIVE=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    s = json.load(f)
print(s.get('active_candidate',''))
" 2>/dev/null || echo "")

if [[ -n "$ACTIVE" ]]; then
    if [[ -f "$HARNESS_DIR/candidates/${ACTIVE}.md" ]]; then
        echo "✓ 活跃候选 ${ACTIVE} 已归档"
    else
        echo "⚠ 活跃候选 ${ACTIVE} 尚未归档（首次运行时正常）"
        WARNINGS=$((WARNINGS+1))
    fi
fi

# Check trace files JSONL validity
FOUND_TRACES=false
for f in "$TRACES_DIR"/*.jsonl; do
    [[ -f "$f" ]] || continue
    FOUND_TRACES=true
    FNAME="$(basename "$f")"
    if TRACE_PATH="$f" python3 - <<'PYEOF' 2>/dev/null
import json, sys, os
fpath = os.environ['TRACE_PATH']
with open(fpath) as file:
    for i, line in enumerate(file):
        if line.strip():
            try:
                json.loads(line)
            except json.JSONDecodeError as e:
                print(f'行 {i+1}: {e}', file=sys.stderr)
                sys.exit(1)
PYEOF
    then
        echo "✓ ${FNAME} 格式有效"
    else
        echo "✗ trace 文件损坏: ${FNAME}"
        ERRORS=$((ERRORS+1))
    fi
done
if [[ "$FOUND_TRACES" == "false" ]]; then
    echo "✓ 无 trace 文件（首次运行正常）"
fi

echo ""
echo "检查完成: ${WARNINGS} 个警告, ${ERRORS} 个错误"
[[ $ERRORS -eq 0 ]] && exit 0 || exit 2
