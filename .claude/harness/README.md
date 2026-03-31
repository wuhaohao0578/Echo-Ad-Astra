# Echo Ad Astra Meta-Harness

这是一个自我进化的 AI harness 系统，基于 Meta-Harness 论文的设计哲学构建。

## 核心理念

**CLAUDE.md 不是一个静态文档——它是一个正在被持续优化的候选。**

每次 Claude 与用户交互：
1. 行动被记录为结构化 trace（`traces/`）
2. 用户反馈转化为 outcome score（`scores/`）
3. 每 7 天或 50 个 outcome 后，proposer 读取全量历史
4. Proposer 生成新的 CLAUDE.md 候选（`candidates/`）
5. 用户审批候选 → 安装为新的活跃 harness

## 关键原则

- **全量上下文而非摘要**：proposer 读取所有 trace 文件，不做压缩
- **可追溯因果**：每个 trace 包含 `harness_rule_ref`，失败可追溯到具体的 CLAUDE.md 章节
- **数据驱动改进**：所有 CLAUDE.md 修改必须有 trace 证据支持

## 文件说明

| 目录/文件 | 说明 |
|-----------|------|
| `traces/` | 会话 trace 文件（JSONL），不纳入 git |
| `scores/` | Outcome 评分记录，不纳入 git |
| `candidates/` | 历史 CLAUDE.md 版本，纳入 git |
| `proposals/` | 改进提案，纳入 git |
| `scripts/` | 基础设施脚本 |
| `state.json` | 当前系统状态 |
| `proposer-prompt-template.md` | Proposer 提示模板 |

## 快速命令

- `/propose` 或 `运行改进提案`：触发 proposer
- `[✓]` 或 `确认`：标记上个行动为 accepted
- `[✗]` 或 `不对`：标记上个行动为 rejected
- `/score 4`：给上个行动打分（1-5）
- `结束会话`：关闭会话并记录整体评分
