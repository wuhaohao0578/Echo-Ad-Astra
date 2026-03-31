#!/usr/bin/env bash
# aggregate-metrics.sh: 从 outcomes.jsonl 计算聚合指标，写入 metrics.json
# 用法: aggregate-metrics.sh [window_days]

set -euo pipefail
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
STATE_FILE="$HARNESS_DIR/state.json"
OUTCOMES_FILE="$HARNESS_DIR/scores/outcomes.jsonl"
METRICS_FILE="$HARNESS_DIR/scores/metrics.json"
WINDOW_DAYS="${1:-30}"

export STATE_FILE OUTCOMES_FILE METRICS_FILE WINDOW_DAYS

python3 - <<'PYEOF'
import json, os, sys
from datetime import datetime, timedelta, timezone
from collections import defaultdict

state_file = os.environ['STATE_FILE']
outcomes_file = os.environ['OUTCOMES_FILE']
metrics_file = os.environ['METRICS_FILE']
window_days = int(os.environ['WINDOW_DAYS'])

window_start = (datetime.now(timezone.utc) - timedelta(days=window_days)).isoformat()

try:
    with open(outcomes_file) as f:
        outcomes = [json.loads(line) for line in f if line.strip()]
except FileNotFoundError:
    outcomes = []

# Filter to time window, action-scope only
recent = [o for o in outcomes
          if o.get('timestamp_utc', '') >= window_start
          and o.get('scope') == 'action']

total = len(recent)
scored = [o for o in recent if o.get('verdict') != 'no_response']
total_scored = len(scored)

# By workflow
by_workflow = defaultdict(lambda: {
    'accepted': 0, 'modified': 0, 'rejected': 0, 'no_response': 0,
    'quality_sums': defaultdict(list)
})
VALID_VERDICTS = {'accepted', 'modified', 'rejected', 'no_response'}
for o in recent:
    wf = o.get('workflow') or 'unknown'
    verdict = o.get('verdict', 'no_response')
    if verdict not in VALID_VERDICTS:
        verdict = 'no_response'
    by_workflow[wf][verdict] += 1
    if o.get('quality'):
        for dim, score in o['quality'].items():
            if score is not None:
                by_workflow[wf]['quality_sums'][dim].append(score)

# By quality dimension
dim_scores = defaultdict(list)
for o in recent:
    if o.get('quality'):
        for dim, score in o['quality'].items():
            if score is not None:
                dim_scores[dim].append(score)

# Modification type counts
mod_types = defaultdict(int)
for o in recent:
    mod = o.get('modification') or {}
    if mod.get('type'):
        mod_types[mod['type']] += 1

# Load harness state
with open(state_file) as f:
    state = json.load(f)

# Targets
targets = {
    "file_placement_accuracy": 0.95,
    "terminology_accuracy": 0.90,
    "overall_acceptance": 0.90,
    "user_correction_rate": 0.10
}

# Compute rates
accepted_count = sum(1 for o in scored if o.get('verdict') == 'accepted')
modified_count = sum(1 for o in scored if o.get('verdict') == 'modified')
acceptance_rate = accepted_count / total_scored if total_scored > 0 else None
correction_rate = modified_count / total_scored if total_scored > 0 else None

fp_outcomes = [o for o in scored if o.get('workflow') == 'file_placement']
fp_accepted = sum(1 for o in fp_outcomes if o.get('verdict') == 'accepted')
fp_accuracy = fp_accepted / len(fp_outcomes) if fp_outcomes else None

def check_target(actual, target, higher_is_better=True):
    if actual is None:
        return "no_data"
    if higher_is_better:
        return "met" if actual >= target else "below"
    else:
        return "met" if actual <= target else "below"

metrics = {
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "harness_version": state.get('harness_version', 'unknown'),
    "window_days": window_days,
    "total_actions": total,
    "total_scored": total_scored,
    "coverage_pct": round(total_scored / total * 100, 1) if total > 0 else 0,
    "by_workflow": {
        wf: {
            "accepted": data['accepted'],
            "modified": data['modified'],
            "rejected": data['rejected'],
            "no_response": data['no_response'],
            "acceptance_rate": round(
                data['accepted'] / max(data['accepted'] + data['modified'] + data['rejected'], 1), 3
            ),
            "avg_quality": {
                dim: round(sum(scores) / len(scores), 1)
                for dim, scores in data['quality_sums'].items() if scores
            }
        }
        for wf, data in by_workflow.items()
    },
    "by_quality_dimension": {
        dim: {"avg": round(sum(scores) / len(scores), 2), "n": len(scores)}
        for dim, scores in dim_scores.items()
    },
    "common_modification_types": dict(mod_types),
    "harness_targets": {
        "overall_acceptance": {
            "target": targets["overall_acceptance"],
            "actual": acceptance_rate,
            "status": check_target(acceptance_rate, targets["overall_acceptance"])
        },
        "user_correction_rate": {
            "target": targets["user_correction_rate"],
            "actual": correction_rate,
            "status": check_target(correction_rate, targets["user_correction_rate"], higher_is_better=False)
        },
        "file_placement_accuracy": {
            "target": targets["file_placement_accuracy"],
            "actual": fp_accuracy,
            "status": check_target(fp_accuracy, targets["file_placement_accuracy"])
        }
    }
}

# Atomic write
import os as _os
tmp_path = metrics_file + '.tmp'
os.makedirs(os.path.dirname(metrics_file), exist_ok=True)
with open(tmp_path, 'w') as f:
    json.dump(metrics, f, ensure_ascii=False, indent=2)
_os.replace(tmp_path, metrics_file)

print(f"指标已更新: {metrics_file}")
print(f"  总行动数: {total}（近 {window_days} 天）")
print(f"  已评分: {total_scored}（{metrics['coverage_pct']}%）")
if acceptance_rate is not None:
    print(f"  整体接受率: {acceptance_rate:.1%}（目标: {targets['overall_acceptance']:.0%}）")
PYEOF
