# Implementation Plan: Echo Ad Astra Frontend Tool (EAA Frontend)

## 1. Requirements Restatement

### 1.1 Project Objectives

Build a visual companion tool for the Echo Ad Astra TRPG creation project that:

1. **Translates human intent to structured instructions** - Converts user UI interactions into structured commands for Claude Code execution
2. **Reduces cognitive load** - Visual interface replaces memorization of file paths and command syntax
3. **Ensures quality** - Real-time consistency checking and terminology alignment
4. **Accelerates workflows** - Harness management automation reduces manual script calls
5. **Maintains creative continuity** - Idea library stores fragmented thoughts for free exploration

### 1.1 Key Constraints

- **Local-first execution** - All data remains on user device, no cloud storage
- **Electron-ready architecture** - Backend must be portable to desktop app wrapper
- **AI dependency** - Claude Pro (API Key) for AI operations; multi-provider support deferred to v2.0
- **Harness workflow fidelity** - Strict adherence to Harness workflow semantics defined in CLAUDE.md
- **Single executable delivery** - Final product as standalone application without requiring command-line startup

### 1.2 Functional Requirements Summary

| Module | P0 (Must Have) | P1 (Should Have) | P2 (Nice to Have) |
|--------|----------------|------------------|-------------------|
| A - Rule Editor | Add/Edit rules, Consistency check | Terminology hints, Preview | Version diff |
| B - Novel Assistant | Chapter nav, AI续写, Term alignment, Style analysis | Inspiration drag, Worldview lookup | Revision history |
| C - Harness Panel | Proposal trigger, Score recording, Trace history, Candidate mgmt | Session stats, Trend charts | - |
| D - Balance Tool | Weapon table, DPS calc, Price ratio chart, Anomaly detection | Batch adjust | - |
| E - Terminology Editor | Table view, Add term, Impact analysis, Batch replace | Alias mgmt | - |
| F - Version Release | Pre-check, Changelog draft, Step confirm, Error prevention, Execution feedback | - | - |
| G - Quality Dashboard | Acceptance rate cards, Trend charts, Workflow comparison | Recent errors, Performance metrics | - |
| H - Worldview Lookup | Hover definitions, Related entries, Quick search, Floating window, Cross-refs | - | - |

### 1.3 Non-Functional Requirements

| Category | Metric | Target |
|----------|--------|--------|
| Performance | Initial load time | < 2 seconds |
| Performance | Page response time | < 100ms |
| Performance | File upload support | 10MB max |
| Performance | Concurrent queue execution | Serial execution, < 5s per command |
| Reliability | System availability | 99%+ |
| Reliability | Data persistence | All state stored locally |
| Reliability | Error recovery | Failed commands retryable |
| Reliability | Logging | All critical operations traceable |
| Security | Data privacy | All processing local, no cloud upload |
| Security | API Key security | Claude API Key stored locally only |
| Security | File permissions | Respect EAA repo existing permissions |
| Maintainability | Code coverage | > 80% |
| Maintainability | Documentation | All APIs documented |
| Maintainability | Component reuse | > 70% core component reuse rate |

---

## 2. Technical Architecture

### 2.1 Technology Stack

#### Frontend Stack
- **React 18+** - UI framework with Hooks and concurrent features
- **TypeScript 5+** - Type safety and developer experience
- **TailwindCSS 3+** - Utility-first styling with JIT compilation
- **React Query 5+** - Server state management and data fetching
- **Zustand 4+** - Client state management for UI state
- **Monaco Editor 0.40+** - Code/Markdown editing with syntax highlighting
- **Recharts 2+** - Chart visualization for balance and quality data
- **Vite 5+** - Fast build tool with HMR

#### Backend Stack
- **Node.js 18+** - Runtime environment
- **Express 4+** - REST API server
- **ws 8+** - WebSocket for real-time communication
- **js-yaml 4+** - YAML parsing for terminology files
- **chokidar 3+** - File system watching for EAA repo changes
- **openai 4+** - Claude API client (configured with custom baseUrl)

#### Electron Stack (v1.1+)
- **Electron 28+** - Desktop application framework with Chromium and Node.js

#### Development Tools
- **ESLint 8+** - Linting and code quality checks
- **Prettier 3+** - Code formatting
- **Vitest 1+** - Unit testing framework
- **Playwright 1+** - E2E testing framework

### 2.2 Project Structure

```
eaa-frontend/
├── frontend/                          # React frontend
│   ├── src/
│   │   ├── components/                # React components
│   │   │   ├── common/               # Shared components
│   │   │   │   ├── Button.tsx
│   │   │   │   ├── Input.tsx
│   │   │   │   ├── Modal.tsx
│   │   │   │   ├── Toast.tsx
│   │   │   │   └── Tooltip.tsx
│   │   │   ├── layout/               # Layout components
│   │   │   │   ├── AppShell.tsx
│   │   │   │   ├── Sidebar.tsx
│   │   │   │   ├── FileTree.tsx
│   │   │   │   └── WorkModeSwitcher.tsx
│   │   │   ├── modules/              # Feature modules
│   │   │   │   ├── RuleEditor/      # Module A
│   │   │   │   ├── NovelAssistant/   # Module B
│   │   │   │   ├── HarnessPanel/    # Module C
│   │   │   │   ├── BalanceTool/     # Module D
│   │   │   │   ├── TerminologyEditor/# Module E
│   │   │   │   ├── VersionRelease/   # Module F
│   │   │   │   ├── QualityDashboard/# Module G
│   │   │   │   └── WorldviewLookup/  # Module H
│   │   │   └── idea-library/         # Inspiration canvas
│   │   │       ├── IdeaCanvas.tsx
│   │   │       ├── IdeaNote.tsx
│   │   │       └── IAClassifier.tsx
│   │   ├── hooks/                     # Custom React hooks
│   │   │   ├── useIdeaLibrary.ts
│   │   │   ├── useCommandQueue.ts
│   │   │   ├── useFileTree.ts
│   │   │   └── useWorkMode.ts
│   │   ├── stores/                    # Zustand stores
│   │   │   ├── uiStore.ts
│   │   │   ├── commandQueueStore.ts
│   │   │   └── ideaLibraryStore.ts
│   │   ├── services/                  # API clients
│   │   │   ├── apiClient.ts
│   │   │   ├── fileService.ts
│   │   │   ├── claudeService.ts
│   │   │   └── harnessService.ts
│   │   ├── types/                     # TypeScript types
│   │   │   ├── commands.ts
│   │   │   ├── harness.ts
│   │   │   ├── ideaLibrary.ts
│   │   │   └── api.ts
│   │   ├── utils/                     # Utility functions
│   │   │   ├── commandBuilder.ts
│   │   │   ├── terminologyScanner.ts
│   │   │   ├── styleAnalyzer.ts
│   │   │   └── balanceCalculator.ts
│   │   ├── `App.tsx`
│   │   └── `main.tsx`
│   ├── public/
│   ├── index.html
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   └── tsconfig.json
```

```
├── backend/                           # Node.js backend
│   ├── src/
│   │   ├── api/                       # Express routes
│   │   │   ├── files.ts
│   │   │   ├── claude.ts
│   │   │   ├── harness.ts
│   │   │   ├── ideas.ts
│   │   │   └── terminology.ts
│   │   ├── services/                  # Business logic
│   │   │   ├── FileService.ts
│   │   │   ├── ClaudeBridge.ts
│   │   │   ├── HarnessManager.ts
│   │   │   ├── AIClassifier.ts
│   │   │   └── BalanceCalculator.ts
│   │   ├── ws/                        # WebSocket handlers
│   │   │   ├── commandQueue.ts
│   │   │   └── fileWatcher.ts
│   │   ├── types/                     # TypeScript types
│   │   │   ├── commands.ts
│   │   │   └── harness.ts
│   │   ├── utils/                     # Utility functions
│   │   │   ├── commandParser.ts
│   │   │   ├── traceParser.ts
│   │   │   └── yamlParser.ts
│   │   ├── config/                    # Configuration
│   │   │   └── app.config.ts
│   │   └── server.ts
│   ├── package.json
│   └── tsconfig.json
```

```
├── electron/                          # Electron wrapper (Phase 5)
│   ├── main.ts
│   ├── preload.ts
│   ├── package.json
│   └── build/
│       ├── icons/
│       └── config.json
```

```
├── shared/                            # Shared types and utilities
│   ├── types/
│   │   ├── commands.ts
│   │   ├── harness.ts
│   │   └── common.ts
│   └── constants/
│       └── workflows.ts
```

```
├── tests/                             # Test files
│   ├── unit/
│   │   ├── frontend/
│   │   └── backend/
│   ├── integration/
│   └── e2e/
│       ├── flows/
│       └── fixtures/
```

```
├── docs/                              # Documentation
│   ├── api/
│   ├── architecture.md
│   └── user-guide.md
```

```
├── package.json                       # Root package
├── tsconfig.json                      # Root tsconfig
├── vitest.config.ts                   # Test config
├── playwright.config.ts              # E2E test config
├── .eslintrc.js
├── .prettierrc
└── README.md
```

### 2.3 Key Data Structures

#### Command Structure
```typescript
interface Command {
  id: string;                          // UUID
  type: 'rule_modification' | 'novel_update' | 'harness_command';
  action: string;
  payload: Record<string, unknown>;
  status: 'pending' | 'executing' | 'success' | 'failed';
  affected_files: string[];
  error: string | null;
  created_at: string;                  // ISO8601
  executed_at?: string;                // ISO8601
}

interface RuleModificationPayload {
  workflow: 'rule_modification';
  step: 'generate_plan' | 'execute_edit';
  target_path: string;
  content: Record<string, unknown>;
  pre_checks: Array<{
    check: string;
    result: 'pass' | 'warn' | 'fail';
    findings: string[];
  }>;
}

interface NovelUpdatePayload {
  workflow: 'novel_update';
  step: 'style_check' | 'file_write';
  target_path: string;
  content: string;
  style_metrics?: {
    sentence_rhythm: number;
    narrative_distance: number;
    technical_density: number;
    structure_pattern: number;
  };
}
```

#### Idea Library Structure
```typescript
interface IdeaNote {
  id: string;                          // UUID
  content: string;
  tags: string[];                      // 支持多维标签（如同时包含 'rule' 和 'novel'）
  status: 'active' | 'classified' | 'ai_generated';
  confidence: number;                   // 0.0-1.0
  isHybrid?: boolean;                   // P1-7: 是否包含规则和小说双标签
  created_at: string;                  // ISO8601
  last_modified: string;               // ISO8601
  position: { x: number; y: number };   // Canvas position
}

interface ClassificationRequest {
  content: string;
  available_tags: string[];
}

interface ClassificationResponse {
  suggested_tag: string;
  confidence: number;
  alternative_tags: Array<{
    tag: string;
    confidence: number;
  }>;
}
```

#### Harness Data Structures
```typescript
interface Trace {
  workflow: string;
  step: string;
  harness_rule_ref: string;
  confidence: number;
  pre_checks: Array<{
    check: string;
    result: 'pass' | 'warn' | 'fail';
    findings: string[];
  }>;
  timestamp: string;                    // ISO8601
}

interface Outcome {
  verdict: 'accepted' | 'rejected' | 'modified';
  quality?: {
    overall?: number;
    [dimension: string]: number;
  };
  mod_type?: 'tone_adjust' | 'content_edit' | 'placement_change' | 'factual_correction';
  timestamp: string;                    // ISO8601
}

interface Proposal {
  id: string;                          // candidate_id
  harness_version: string;
  active_since: string;                // ISO8601
  changes: Array<{
    rule_ref: string;
    description: string;
  }>;
  rationale: string;
}
```

---

## 3. Implementation Phases

### Phase 1: MVP - Core Functionality (4 weeks)

**Objective:** Establish basic rule editing and novel creation capabilities with functional Claude Code communication.

#### Week 1: Project Setup & Foundation (5 days)

##### Day 1: Project Initialization
1. **Initialize monorepo structure**
   - Create root `package.json` with workspaces
   - Set up `frontend/`, `backend/`, `shared/`, `tests/` directories
   - Configure TypeScript with project references
   - File: `package.json`
     - Action: Add workspaces configuration for frontend, backend, shared
     - Why: Enable monorepo management with shared types
     - Dependencies: None
     - Risk: Low

2. **Configure build tools**
   - Set up Vite for frontend with TypeScript
   - Configure TailwindCSS with custom theme
   - File: `frontend/vite.config.ts`
     - Action: Configure dev server proxy to backend, HMR settings
     - Why: Enable hot module reload and API proxying
     - Dependencies: Step 1
     - Risk: Low

3. **Set up linting and formatting**
   - Configure ESLint with React and TypeScript rules
   - Set up Prettier with consistent formatting
   - File: `.eslintrc.js`, `.prettierrc`
     - Action: Configure ESLint/ Prettier rules
     - Why: Maintain code quality consistency
     - Dependencies: None
     - Risk: Low

##### Day 2: Backend Foundation
1. **Initialize Express server**
   - `backend/src/server.ts` - Main server entry point
   - File: `backend/src/server.ts`
     - Action: Create Express app with CORS, JSON parsing, error handling
     - Why: HTTP API foundation for frontend communication
     - Dependencies: None
     - Risk: Low

2. **Create health check endpoint**
   - `backend/src/api/health.ts` - Simple GET /health endpoint
   - File: `backend/src/api/health.ts`
     - Action: Implement health check returning server status and version
     - Why: Verify backend is running and accessible
     - Dependencies: Step 1
     - Risk: Low

3. **Configure WebSocket server**
   - `backend/src/ws/server.ts` - WebSocket initialization
   - File: `backend/src/ws/server.ts`
     - Action: Create ws Server with connection handling
     - Why: Enable real-time communication for command execution
     - Dependencies: Step 1
     - Risk: Medium - Ensure proper cleanup on disconnect

##### Day 3: Frontend Foundation
1. **Create React app shell**
   - `frontend/src/App.tsx` - Main app component
   - File: `frontend/src/App.tsx`
     - Action: Create app shell with routing placeholder
     - Why: Foundation for all UI components
     - Dependencies: None
     - Risk: Low

2. **Implement base layout**
   - `frontend/src/components/layout/AppShell.tsx`
   - File: `frontend/src/components/layout/AppShell.tsx`
     - Action: Create shell with header, main content area, footer
     - Why: Consistent layout across all pages
     - Dependencies: Step 1
     - Risk: Low

3. **Set up state management**
   - `frontend/src/stores/uiStore.ts`
   - File: `frontend/src/stores/uiStore.ts`
     - Action: Create Zustand store for UI state (theme, sidebar state, etc.)
     - Why: Centralized UI state management
     - Dependencies: None
     - Risk: Low

##### Day 4: Shared Types & Utilities
1. **Define shared TypeScript types**
   - `shared/types/commands.ts` - Command interfaces
   - File: `shared/types/commands.ts`
     - Action: Define Command, RuleModificationPayload, NovelUpdatePayload interfaces
     - Why: Type safety across frontend/backend boundary
     - Dependencies: None
     - Risk: Low

2. **Create harness types**
   - `shared/types/harness.ts` - Harness-related interfaces
   - File: `shared/types/harness.ts`
     - Action: Define Trace, Outcome, Proposal interfaces
From the design document, I need to create a comprehensive implementation plan for the Echo Ad Astra Frontend Tool. Let me analyze the design document and create a detailed, structured plan.

The design document outlines:
1. 8 functional modules (A-H)
2. 5 implementation phases
3. Specific tech stack
4. Data structures
5. UI layouts
6. API contracts

I'll create a comprehensive implementation plan following the structure requested by the user.</think># Implementation Plan: Echo Ad Astra Frontend Tool

## 1. Requirements Restatement

### 1.1 Project Objectives

Build a visual companion tool for Echo Ad Astra TRPG creation that:

- **Translates human intent to structured commands** - User UI interactions become structured instructions for Claude Code execution
- **Reduces cognitive load** - Visual interface replaces memorization of file paths and command syntax
- **Ensures quality** - Real-time consistency checking and terminology alignment before commands are generated
- **Accelerates workflows** - Harness management automation reduces manual script calls
- **Maintains creative continuity** - Idea library stores fragmented thoughts for free exploration

### 1.2 Key Constraints

| Constraint | Description | Impact |
|-----------|-------------|--------|
| Local-first execution | All data remains on user device | No cloud storage, no external APIs except Claude |
| Electron-ready architecture | Backend must be portable to desktop wrapper | Clean separation of concerns |
| AI dependency | Claude Pro (API Key) required for AI features | Multi-provider support deferred to v2.0 |
| Harness workflow fidelity | Strict adherence to CLAUDE.md workflow semantics | Command structures must match exactly |
| Single executable delivery | Final product as standalone app | Electron packaging requirement |

### 1.3 Functional Requirements Summary

| Module | P0 Features | P1 Features | P2 Features |
|--------|------------|-------------|--------------|
| **A. Rule Editor** | Add/Edit rules, Consistency check | Terminology hints, Preview | Version diff |
| **B. Novel Assistant** | Chapter nav, AI续写, Term alignment, Style analysis | Inspiration drag, Worldview lookup | Revision history |
| **C. Harness Panel** | Proposal trigger, Score recording, Trace history, Candidate mgmt | Session stats, Trend charts | - |
| **D. Balance Tool** | Weapon table, DPS calc, Price ratio chart, Anomaly detection | Batch adjust | - |
| **E. Terminology Editor** | Table view, Add term, Impact analysis, Batch replace | Alias mgmt | - |
| **F. Version Release** | Pre-check, Changelog draft, Step confirm, Error prevention, Execution feedback | - | - |
| **G. Quality Dashboard** | Acceptance rate cards, Trend charts, Workflow comparison | Recent errors, Performance metrics | - |
| **H. Worldview Lookup** | Hover definitions, Related entries, Quick search, Floating window, Cross-refs | - | - |

### 1.4 Non-Functional Requirements

| Category | Metric | Target |
|----------|--------|--------|
| **Performance** | Initial load time | < 2 seconds |
| | Page response time | < 100ms |
| | File upload support | 10MB max |
| | Concurrent queue execution | Serial execution, < 5s per command |
| **Reliability** | System availability | 99%+ |
| | Data persistence | All state stored locally |
| | Error recovery | Failed commands retryable |
| | Logging | All critical operations traceableable |
| **Security** | Data privacy | All processing local, no cloud upload |
| | API Key security | Claude API Key stored locally only |
| | File permissions | Respect EAA repo existing permissions |
| **Maintainability** | Code coverage | > 80% |
| | Documentation | All APIs documented |
| | Component reuse | > 70% core component reuse rate |

---

## 2. Technical Architecture

### 2.1 Technology Stack

#### Frontend Stack
| Technology | Version | Purpose |
|------------|---------|---------|
| React | 18+ | UI framework with Hooks and concurrent features |
| TypeScript | 5+ | Type safety and developer experience |
| TailwindCSS | 3+ | Utility-first styling with JIT compilation |
| React Query | 5+ | Server state management and data fetching |
| Zustand | 4+ | Client state management for UI state |
| Monaco Editor | 0.40+ | Code/Markdown editing with syntax highlighting |
| Recharts | 2+ | Chart visualization for balance and quality data |
| Vite | 5+ | Fast build tool with HMR |

#### Backend Stack
| Technology | Version | Purpose |
|------------|---------|---------|
| Node.js | 18+ | Runtime environment |
| Express | 4+ | REST API server |
| ws | 8+ | WebSocket for real-time communication |
| js-yaml | 4+ | YAML parsing for terminology files |
| chokidar | 3+ | File system watching for EAA repo changes |
| openai | 4+ | Claude API client (configured with custom baseUrl) |

#### Electron Stack (v1.1+)
| Technology | Version | Purpose |
|------------|---------|---------|
| Electron | 28+ | Desktop application framework with Chromium and Node.js |

#### Development Tools
| Tool | Version | Purpose |
|------|---------|--------|
| ESLint | 8+ | Linting and code quality checks |
| Prettier | 3+ | Code formatting |
| Vitest | 1+ | Unit testing framework |
| Playwright | 1+ | E2E testing framework |

### 2.2 Project File Structure

```
eaa-frontend/
├── frontend/                                    # React frontend application
│   ├── src/
│   │   ├── components/
│   │   │   ├── common/                          # Shared UI components
│   │   │   │   ├── Button.tsx
│   │   │   │   ├── Input.tsx
│   │   │   │   ├── Modal.tsx
│   │   │   │   ├── Toast.tsx
│   │   │   │   └── Tooltip.tsx
│   │   │   ├── layout/                         # Layout components
│   │   │   │   ├── AppShell.tsx
│   │   │   │   ├── Sidebar.tsx
│   │   │   │   ├── FileTree.tsx
│   │   │   │   └── WorkModeSwitcher.tsx
│   │   │   ├── modules/                        # Feature modules
│   │   │   │     ├── RuleEditor/              # Module A
│   │   │   │   │   ├── components/
│   │   │   │   │   │   ├── RuleForm.tsx
│   │   │   │   │   │   ├── ConsistencyChecker.tsx
│   │   │   │   │   │   └── TermHighlighter.tsx
│   │   │   │   │   ├── hooks/
│   │   │   │   │   │   └── useRuleValidation.ts
│   │   │   │   │   └── index.tsx
│   │   │   │   ├── NovelAssistant/           # Module B
│   │   │   │   │   ├── components/
│   │   │   │   │   │   ├── ChapterNav.tsx
│   │   │   │   │   │   ├── AIGenerator.tsx
│   │   │   │   │   │   ├── StyleMetrics.tsx
│   │   │   │   │   │   └── TermAligner.tsx
│   │   │   │   │   ├── hooks/
│   │   │   │   │   │   └── useStyleAnalysis.ts
│   │   │   │   │   └── index.tsx
│   │   │   │   ├── HarnessPanel/            # Module C
│   │   │   │   │   ├── components/
│   │   │   │   │   │   ├── ProposalTrigger.tsx
│   │   │   │   │   │   ├── ScoreButtons.tsx
│   │   │   │   │   │   ├── TraceTimeline.tsx
│   │   │   │   │   │   └── CandidateManager.tsx
│   │   │   │   │   └── index.tsx
│   │   │   │   ├── BalanceTool/             # Module D
│   │   │   │   │   ├── components/
│   │   │   │   │   │   ├── WeaponTable.tsx
│   │   │   │   │   │   ├── DPSChart.tsx
│   │   │   │   │   │   └── AnomalyDetector.tsx
│   │   │   │   │   └── index.tsx
│   │   │   │   ├── TerminologyEditor/       # Module E
│   │   │   │   │   ├── components/
│   │   │   │   │   │   ├── TermTable.tsx
│   │   │   │   │   │   ├── ImpactAnalyzer.tsx
│   │   │   │   │   │   └── BatchReplacer.tsx
│   │   │   │   │   └── index.tsx
│   │   │   │   ├── VersionRelease/          # Module F
│   │   │   │   │   ├── components/
│   │   │   │   │   │   ├── PreReleaseChecks.tsx
│   │   │   │   │   │   ├── ChangelogDraft.tsx
│   │   │   │   │   │   └── ReleaseWizard.tsx
│   │   │   │   │   └── index.tsx
│   │   │   │   ├── QualityDashboard/        # Module G
│   │   │   │   │   ├── components/
│   │   │   │   │   │   ├── AcceptanceRateCards.tsx
│   │   │   │   │   │   ├── TrendChart.tsx
│   │   │   │   │   │   └── WorkflowComparison.tsx
│   │   │   │   │   └── index.tsx
│   │   │   │   └── WorldviewLookup/         # Module H
│   │   │   │       ├── components/
│   │   │   │       │   ├── TermTooltip.tsx
│   │   │   │       │   ├── RelatedEntries.tsx
│   │   │   │       │   └── FloatingWindowRef.tsx
│   │   │   │       └── index.tsx
│   │   │   └── idea-library/                    # Inspiration canvas
│   │   │       ├── IdeaCanvas.tsx
│   │   │       ├── IdeaNote.tsx
│   │   │       ├── IAClassifier.tsx
│   │   │       └── MiniCanvas.tsx
│   │   ├── hooks/                               # Custom React hooks
│   │   │   ├── useIdeaLibrary.ts
│   │   │   ├── useCommandQueue.ts
│   │   │   ├── useFileTree.ts
│   │   │   ├── useWorkMode.ts
│   │   │   └── useWebSocket.ts
│   │   ├── stores/                              # Zustand stores
│   │   │   ├── uiStore.ts
│   │   │   ├── commandQueueStore.ts
│   │   │   ├── ideaLibraryStore.ts
│   │   │   └── harnessDataStore.ts
│   │   ├── services/                            # API clients
│   │   │   ├── apiClient.ts
│   │   │   ├── fileService.ts
│   │   │   ├── claudeService.ts
│   │   │   └── harnessService.ts
│   │   ├── types/                               # TypeScript types
│   │   │   ├── commands.ts
│   │   │   ├── harness.ts
│   │   │   ├── ideaLibrary.ts
│   │   │   └── api.ts
│   │     ├── utils/                              # Utility functions
│   │   │   ├── commandBuilder.ts
│   │   │   ├── terminologyScanner.ts
│   │   │   ├── styleAnalyzer.ts
│   │   │   └── balanceCalculator.ts
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── public/
│   ├── index.html
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   ├── tsconfig.json
│   └── package.json
├── backend/                                      # Node.js backend
│   ├── src/
│   │   ├── api/                                 # Express routes
│   │   │   ├── files.ts
│   │   │   ├── claude.ts
│   │   │   ├── harness.ts
│   │   │   ├── ideas.ts
│   │   │   └── terminology.ts
│   │   ├── services/                            # Business logic
│   │   │   ├── FileService.ts
│   │   │   ├── ClaudeBridge.ts
│   │   │   ├── HarnessManager.ts
│   │   │   ├── AIClassifier.ts
│   │   │   └── BalanceCalculator.ts
│   │   ├── ws/                                  # WebSocket handlers
│   │   │   ├── commandQueue.ts
│   │   │   └── fileWatcher.ts
│   │   ├── types/                               # TypeScript types
│   │   │   ├── commands.ts
│   │   │   └── harness.ts
│   │   ├── utils/                              # Utility functions
│   │   │   ├── commandParser.ts
│   │   │   ├── traceParser.ts
│   │   │   └── yamlParser.ts
│   │   ├── config/                             # Configuration
│   │   │   └── app.config.ts
│   │   └── server.ts
│   ├── package.json
│   └── tsconfig.json
├── electron/                                     # Electron wrapper (Phase 5)
│   ├── main.ts
│   ├── preload.ts
│   ├── package.json
│   └── build/
│       ├── icons/
│       └── config.json
├── shared/                                       # Shared types and utilities
│   ├── types/
│   │   ├── commands.ts
│   │   ├── harness.ts
│   │   └── common.ts
│   └── constants/
│       └── workflows.ts
├── tests/                                        # Test files
│   ├── unit/
│   │   ├── frontend/
│   │   └── backend/
│   ├── integration/
│   └── e2e/
│       ├── flows/
│       └── fixtures/
├── docs/                                         # Documentation
│   ├── api/
│   ├── architecture.md
│   └── user-guide.md
├── package.json                                  # Root package
├── tsconfig.json                                 # Root tsconfig
├── vitest.config.ts                              # Test config
├── playwright.config.ts                         # E2E test config
├── .eslintrc.js
├── .prettierrc
└── README.md
```

### 2.3 Core Data Structures

#### Command Structure
```typescript
interface Command {
  id: string;                                     // UUID
  type: 'rule_modification' | 'novel_update' | 'harness_command';
  action: string;
  payload: Record<string, unknown>;
  status: 'pending' | 'executing' | 'success' | 'failed';
  affected_files: string[];
  error: string | null;
  created_at: string;                            // ISO8601
  executed_at?: string;                           // ISO8601
}

interface RuleModificationPayload {
  workflow: 'rule_modification';
  step: 'generate_plan' | 'execute_edit';
  target_path: string;
  content: Record<string, unknown>;
  pre_checks: Array<{
    check: string;
    result: 'pass' | 'warn' | 'fail';
    findings: string[];
  }>;
}

interface NovelUpdatePayload {
  workflow: 'novel_update';
  step: 'style_check' | 'file_write';
  target_path: string;
  content: string;
  style_metrics?: {
    sentence_rhythm: number;
    narrative_distance: number;
    technical_density: number;
    structure_pattern: number;
  };
}
```

#### Idea Library Structure
```typescript
interface IdeaNote {
  id: string;                                     // UUID
  content: string;
  tags: string[];                                  // 支持多维标签（如同时包含 'rule' 和 'novel'）
  status: 'active' | 'classified' | 'ai_generated';
  confidence: number;                              // 0.0-1.0
  isHybrid?: boolean;                              // P1-7: 是否包含规则和小说双标签
  created_at: string;                             // ISO8601
  last_modified: string;                           // ISO8601
  position: { x: number; y: number };              // Canvas position
}

interface ClassificationRequest {
  content: string;
  available_tags: string[];
}

interface ClassificationResponse {
  suggested_tag: string;
  confidence: number;
  alternative_tags: Array<{
    tag: string;
    confidence: number;
  }>;
}
```

#### Harness Data Structures
```typescript
interface Trace {
  workflow: string;
  step: string;
  harness_rule_ref: string;
  confidence: number;
  pre_checks: Array<{
    check: string;
    result: 'pass' | 'warn' | 'fail';
    findings: string[];
  }>;
  timestamp: string;                               // ISO8601
}

interface Outcome {
  verdict: 'accepted' | 'rejected' | 'modified';
  quality?: {
    overall?: number;
    [dimension: string]: number;
  };
  mod_type?: 'tone_adjust' | 'content_edit' | 'placement_change' | 'factual_correction';
  timestamp: string;                               // ISO8601
}

interface Proposal {
  id: string;                                      // candidate_id
  harness_version: string;
  active_since: string;                           // ISO8601
  changes: Array<{
    rule_ref: string;
    description: string;
  }>;
  rationale: string;
}
```

---

## 3. Implementation Phases

### Phase 1: MVP - Core Functionality (4 weeks)

**Objective:** Establish basic rule editing and novel creation capabilities with functional Claude Code communication.

**Deliverables:**
- Frontend and backend skeleton
- Module A (Rule Editor) - P0 features
- Module B (Novel Assistant) - P0 features
- Basic command queue
- Claude Code Bridge (one-way)
- Basic file tree navigation

**Acceptance Criteria:**
- User can add new weapon through UI
- User can use AI to continue chapter
- Generated commands can be transmitted to Claude Code

#### Week 1: Project Setup & Foundation (5 days)

##### Day 1: Project Initialization
1. **Initialize monorepo structure** (File: `package.json`)
   - Action: Create root `package.json` with workspaces for frontend, backend, shared
   - Why: Enable monorepo management with shared types and dependencies
   - Dependencies: None
   - Risk: Low

2. **Configure build tools** (File: `frontend/vite.config.ts`)
   - Action: Set up Vite with dev server proxy to backend, HMR, TypeScript support
   - Why: Fast development with hot module reload and API proxying
   - Dependencies: Step 1
   - Risk: Low

3. **Configure linting and formatting** (File: `.eslintrc.js`, `.prettierrc`)
   - Action: Set up ESLint with React/TypeScript rules, Prettier with consistent formatting
   - Why: Maintain code quality and consistency across team
   - Dependencies: None
   - Risk: Low

##### Day 2: Backend Foundation
1. **Initialize Express server** (File: `backend/src/server.ts`)
   - Action: Create Express app with CORS, JSON parsing, error handling middleware
   - Why: HTTP API foundation for frontend communication
   - Dependencies: None
   - Risk: Low

2. **Create health check endpoint** (File: `backend/src/api/health.ts`)
   - Action: Implement GET /health returning server status and version
   - Why: Verify backend is running and accessible
   - Dependencies: Day 2, Step 1
   - Risk: Low

3. **Configure WebSocket server** (File: `backend/src/ws/server.ts`)
   - Action: Create ws Server with connection handling, heartbeat mechanism
   - Why: Enable real-time communication for command execution
   - Dependencies: Day 2, Step 1
   - Risk: Medium - Ensure proper cleanup on disconnect

##### Day 3: Frontend Foundation
1. **Create React app shell** (File: `frontend/src/App.tsx`)
   - Action: Create app component with routing placeholder
   - Why: Foundation for all UI components
   - Dependencies: None
   - Risk: Low

2. **Implement base layout** (File: `frontend/src/components/layout/AppShell.tsx`)
   - Action: Create shell with header, main content area, footer
   - Why: Consistent layout across all pages
   - Dependencies: Day 3, Step 1
   - Risk: Low

3. **Set up state management** (File: `frontend/src/stores/uiStore.ts`)
   - Action: Create Zustand store for UI state (theme, sidebar state, current mode)
   - Why: Centralized UI state management
   - Dependencies: None
   - Risk: Low

##### Day 4: Shared Types & Utilities
1. **Define shared TypeScript types** (File: `shared/types/commands.ts`)
   - Action: Define Command, RuleModificationPayload, NovelUpdatePayload interfaces
   - Why: Type safety across frontend/backend boundary
   - Dependencies: None
   - Risk: Low

2. **Create harness types** (File: `shared/types/harness.ts`)
   - Action: Define Trace, Outcome, Proposal interfaces
   - Why: Consistent Harness data structures
   - Dependencies: None
   - Risk: Low

3. **Create common utilities** (File: `shared/utils/idGenerator.ts`)
   - Action: Implement UUID generator for command and note IDs
   - Why: Unique identifiers for all entities
   - Dependencies: None
   - Risk: Low

##### Day 5: Initial Testing Setup
1. **Configure Vitest** (File: `vitest.config.ts`)
   - Action: Set up unit test configuration with TypeScript support
   - Why: Enable automated testing from day one
   - Dependencies: None
   - Risk: Low

2. **Write first unit tests** (File: `tests/unit/backend/api/health.test.ts`)
   - Action: Test health check endpoint returns correct status
   - Why: Verify foundation is working
   - Dependencies: Day 2, Step 2, Day 5, Step 1
   - Risk: Low

3. **Set up CI pipeline** (File: `.github/workflows/ci.yml`)
   - Action: Configure GitHub Actions to run tests on push
   - Why: Prevent regressions from merging to main
   - Dependencies: Day 5, Step 1
   - Risk: Low

#### Week 2: Module A - Rule Editor (P0 Features)

##### Day 1: File Service Implementation
1. **Create FileService** (File: `backend/src/services/FileService.ts`)
   - Action: Implement file read/write/list operations for EAA repo
   - Why: Backend layer for all file operations
   - Dependencies: Week 1, Day 2, Step 1
   - Risk: Medium - File permission handling

2. **Create file API endpoints** (File: `backend/src/api/files.ts`)
   - Action: Implement GET /files, GET /files/:path, PUT /files/:path
   - Why: REST API for frontend file operations
   - Dependencies: Week 2, Day 1, Step 1
   - Risk: Medium - Path traversal vulnerability prevention

3. **Implement file tree endpoint** (File: `backend/src/api/files.ts`)
   - Action: Add GET /files/tree endpoint returning recursive tree structure
   - Why: Populate sidebar file tree
   - Dependencies: Week 2, Day 1, Step 1
   - Risk: Low

##### Day 2: Rule Form Component
1. **Create RuleForm component** (File: `frontend/src/components/modules/RuleEditor/components/RuleForm.tsx`)
   - Action: Build form with fields for rule name, content, type selector
   - Why: User interface for adding/editing rules
   - Dependencies: Week 1, Day 3, Step 1
   - Risk: Low

2. **Implement form validation** (File: `frontend/src/components/modules/RuleEditor/hooks/useRuleValidation.ts`)
   - Action: Create validation rules for required fields, format checks
   - Why: Prevent invalid data submission
   - Dependencies: Week 2, Day 2, Step 1
   - Risk: Low

3. **Add type selector** (File: `frontend/src/components/modules/RuleEditor/components/RuleForm.tsx`)
   - Action: Implement dropdown for rule type (判定机制/世界观/角色创建/战斗/装备/GM指导/核心规则)
   - Why: Automatic file path determination
   - Dependencies: Week 2, Day 2, Step 1
   - Risk: Low

##### Day 3: Consistency Checking (A.3)
1. **Create terminology scanner** (File: `frontend/src/utils/terminologyScanner.ts`)
   - Action: Implement scanner to detect terms not in terminology.yaml
   - Why: Highlight consistency issues before submission
   - Dependencies: None
   - Risk: Low

2. **Create ConsistencyChecker component** (File: `frontend/src/components/modules/RuleEditor/components/ConsistencyChecker.tsx`)
   - Action: Build UI showing list of non-canonical terms with suggested replacements
   - Why: Visual feedback for consistency issues
   - Dependencies: Week 2, Day 3, Step 1
   - Risk: Low

3. **Integrate with rule form** (File: `frontend/src/components/modules/RuleEditor/components/RuleForm.tsx`)
   - Action: Add real-time consistency checking on form input changes
   - Why: Immediate feedback reduces error rate
   - Dependencies: Week 2, Day 2, Step 1, Week 2, Day 3, Step 2
   - Risk: Low

##### Day 4: Command Builder (A.1, A.2)
1. **Create command builder** (File: `frontend/src/utils/commandBuilder.ts`)
   - Action: Implement function to convert rule form data to RuleModificationPayload
   - Why: Generate structured commands for Claude Code
   - Dependencies: Week 1, Day 4, Step 1
   - Risk: Low

2. **Implement placement decision tree** (File: `frontend/src/utils/commandBuilder.ts`)
   - Action: Add logic to determine target file path based on rule type
   - Why: Automate file placement per CLAUDE.md Section 4.4
   - Dependencies: Week 2, Day 4, Step 1
   - Risk: Medium - Must exactly match CLAUDE.md decision tree

3. **Add command to queue action** (File: `frontend/src/stores/commandQueueStore.ts`)
   - Action: Create store to manage pending commands with add/remove/update
   - Why: Centralized queue management
   - Dependencies: None
   - Risk: Low

##### Day 5: Rule Editor Integration
1. **Create CommandQueue component** (File: `frontend/src/components/common/CommandQueue.tsx`)
   - Action: Build UI showing pending commands with status indicators
   - Why: User visibility into queued operations
   - Dependencies: Week 2, Day 4, Step 3
   - Risk: Low

2. **Integrate RuleEditor with AppShell** (File: `frontend/src/App.tsx`)
   - Action: Add routing to show RuleEditor in main content area
   - Why: Navigation to rule editing functionality
   - Dependencies: Week 1, Day 3, Step 2, Week 2, Day 2, Step 1
   - Risk: Low

3. **Write integration tests** (File: `tests/integration/ruleEditor.test.ts`)
   - Action: Test end-to-end rule creation flow from form to command
   - Why: Verify feature works as expected
   - Dependencies: All Week 2 steps
   - Risk: Low

#### Week 3: Module B - Novel Assistant (P0 Features)

##### Day 1: Chapter Navigation (B.1)
1. **Create ChapterNav component** (File: `frontend/src/components/modules/NovelAssistant/components/ChapterNav.tsx`)
   - Action: Build tree view of fiction/ directory with expand/collapse
   - Why: Navigate novel chapters
   - Dependencies: Week 2, Day 1, Step 3
   - Risk: Low

2. **Implement chapter selection** (File: `frontend/src/components/modules/NovelAssistant/components/ChapterNav.tsx`)
   - Action: Add click handler to load chapter content into editor
   - Why: Load selected chapter for editing
   - Dependencies: Week 3, Day 1, Step 1
   - Risk: Low

3. **Create Monaco Editor wrapper** (File: `frontend/src/components/common/MonacoEditor.tsx`)
   - Action: Wrap Monaco Editor with React integration and markdown support
   - Why: Rich editing experience for novel content
   - Dependencies: Week 1, Day 3, Step 1
   - Risk: Medium - Monaco configuration can be complex

##### Day 2: Style Analysis (B.4)
1. **Create style analyzer utility** (File: `frontend/src/utils/styleAnalyzer.ts`)
   - Action: Implement four-axis analysis (sentence rhythm, narrative distance, technical density, structure)
   - Why: Per CLAUDE.md Section 4.3, measure style matching
   - Dependencies: None
   - Risk: Medium - Analysis algorithms need calibration

2. **Create StyleMetrics component** (File: `frontend/src/components/modules/NovelAssistant/components/StyleMetrics.tsx`)
   - Action: Build UI displaying four-axis scores with visual indicators
   - Why: Visual feedback on style matching
   - Dependencies: Week 3, Day 2, Step 1
   - Risk: Low

3. **Implement sample extraction** (File: `frontend/src/components/modules/NovelAssistant/components/NovelEditor.tsx`)
   - Action: Extract last 200 characters from loaded chapter as style sample
   - Why: Per CLAUDE.md Section 4.3, base analysis on existing content
   - Dependencies: Week 3, Day 1, Step 2
   - Risk: Low

##### Day 3: AI Generation (B.2)
1. **Create Claude API service** (File: `backend/src/services/ClaudeBridge.ts`)
   - Action: Implement Claude API client with custom baseUrl (for Anthropic-compatible)
   - Why: Backend layer for AI operations
   - Dependencies: None
   - Risk: Medium - API key management and error handling

2. **Create AIGenerator component** (File: `frontend/src/components/modules/NovelAssistant/components/AIGenerator.tsx`)
   - Action: Build UI with "Generate Continuation" button and prompt input
   - Why: User interface for triggering AI generation
   - Dependencies: Week 3, Day 3, Step 1
   - Risk: Low

3. **Implement generation flow** (File: `backend/src/services/ClaudeBridge.ts`)
   - Action: Add method to generate continuation with style constraints
   - Why: Ensure generated content matches four-axis style requirements
   - Dependencies: Week 3, Day 3, Step 1, Week 3, Day 2, Step 1
   - Risk: High - Must enforce style matching with retry logic
   - P1-4 Enhancement: Generated continuation creates NEW IdeaNote (marked 'ai_generated'), does NOT overwrite original note

##### Day 4: Term Alignment (B.3)
1. **Create TermAligner component** (File: `frontend/src/components/modules/NovelAssistant/components/TermAligner.tsx`)
   - Action: Build UI highlighting non-canonical terms in editor with replacement suggestions
   - Why: Visual feedback for terminology issues
   - Dependencies: Week 2, Day 3, Step 1
   - Risk: Low

2. **Implement auto-replacement** (File: `frontend/src/components/modules/NovelAssistant/components/TermAligner.tsx`)
   - Action: Add one-click replacement of highlighted terms with canonical versions
   - Why: Quick correction of terminology issues
   - Dependencies: Week 3, Day 4, Step 1
   - Risk: Low

3. **Add term conflict detection** (File: `frontend/src/utils/terminologyScanner.ts`)
   - Action: Extend scanner to work with editor content and provide inline highlighting
   - Why: Real-time terminology checking during editing
   - Dependencies: Week 2, Day 3, Step 1
   - Risk: Low

##### Day 5: Novel Assistant Integration
1. **Create NovelEditor component** (File: `frontend/src/components/modules/NovelAssistant/components/NovelEditor.tsx`)
   - Action: Integrate Monaco Editor with StyleMetrics, TermAligner, and AIGenerator
   - Why: Complete novel editing interface
   - Dependencies: Week 3, Day 1, Step 3, Week 3, Day 2, Step 2, Week 3, Day 3, Step 2, Week 3, Day 4, Step 1
   - Risk: Low

2. **Integrate with AppShell** (File: `frontend/src/App.tsx`)
   - Action: Add routing to show NovelAssistant in main content area
   - Why: Navigation to novel editing functionality
   - Dependencies: Week 1, Day 3, Step 2, Week 3, Day 5, Step 1
   - Risk: Low

3. **Write integration tests** (File: `tests/integration/novelAssistant.test.ts`)
   - Action: Test end-to-end AI generation flow from prompt to content
   - Why: Verify feature works as expected
   - Dependencies: All Week 3 steps
   - Risk: Low

#### Week 4: Command Queue & Claude Code Bridge

##### Day 1: Command Queue Backend
1. **Create command queue WebSocket handler** (File: `backend/src/ws/commandQueue.ts`)
   - Action: Implement WebSocket endpoint for command execution with status updates
   - Why: Real-time command execution feedback
   - Dependencies: Week 1, Day 2, Step 3
   - Risk: Medium - WebSocket connection management

2. **Implement queue execution logic** (File: `backend/src/ws/commandQueue.ts`)
   - Action: Add serial execution of pending commands with error handling
   - Why: Per design doc Section 6.1, execute commands sequentially
   - Dependencies: Week 4, Day 1, Step 1
   - Risk: Medium - Command failure handling and retry logic

3. **Create command persistence** (File: `backend/src/services/CommandQueueService.ts`)
   - Action: Save queued commands to local storage for recovery after restart
   - Why: Prevent data loss on server restart
   - Dependencies: Week 4, Day 1, Step 2
   - Risk: Low

##### Day 2: Claude Code Bridge
1. **Create Claude Code Bridge** (File: `backend/src/services/ClaudeCodeBridge.ts`)
   - Action: Implement file-based communication with Claude Code via /tmp/eaa-command.json
   - Why: Per design doc Section 6.2, communicate with Claude Code CLI
   - Dependencies: None
   - Risk: High - File I/O reliability and Claude Code integration

2. **Implement command execution** (File: `backend/src/services/ClaudeCodeBridge.ts`)
   - Action: Add method to write command file and trigger Claude Code execution
   - Why: Execute structured commands via Claude Code
   - Dependencies: Week 4, Day 2, Step 1
   - Risk: High - Depends on Claude Code CLI behavior

3. **Parse Claude Code response** (File: `backend/src/services/ClaudeCodeBridge.ts`)
   - Action: Read and parse /tmp/eaa-result.json with error handling
   - Why: Extract execution results from Claude Code
   - Dependencies: Week 4, Day 2, Step 2
   - Risk: High - Response format validation

##### Day 3: Command Queue Frontend
1. **Create WebSocket client hook** (File: `frontend/src/hooks/useWebSocket.ts`)
   - Action: Implement React hook for WebSocket connection with auto-reconnect
   - Why: Maintain connection to backend for real-time updates
   - Dependencies: None
   - Risk: Medium - Connection stability and reconnection logic

2. **Create CommandQueuePanel component** (File: `frontend/src/components/common/CommandQueuePanel.tsx`)
   - Action: Build UI showing queued commands with execute/cancel actions and status   - P2-10 Enhancement: Add command editing (click to edit parameters), drag-drop reordering, undo button, and queue templates for common command sequences
   - Why: User control over command queue
   - Dependencies: Week 4, Day 3, Step 1, Week 2, Day 4, Step 3
   - Risk: Low

3. **Implement queue UI updates** (File: `frontend/src/stores/commandQueueStore.ts`)
   - Action: Add WebSocket message handlers to update command status in store
   - Why: Real-time UI updates based on command execution
   - Dependencies: Week 4, Day 3, Step 1, Week 2, Day 4, Step 3
   - Risk: Low

##### Day 4: File Tree Implementation
1. **Create FileTree component** (File: `frontend/src/components/layout/FileTree.tsx`)
   - Action: Build recursive tree view of EAA repo with expand/collapse
   - Why: Sidebar navigation for rule and fiction files
   - Dependencies: Week 2, Day 1, Step 3
   - Risk: Low

2. **Implement file filtering** (File: `frontend/src/components/layout/FileTree.tsx`)
   - Action: Filter tree based on work mode (rules for Rule Editor, fiction for Novel Assistant)
   - Why: Show relevant files per context
   - Dependencies: Week 4, Day 4, Step 1
   - Risk: Low

3. **Add search functionality** (File: `frontend/src/components/layout/FileTree.tsx`)
   - Action: Implement search box to filter tree by file name
   - Why: Quick navigation in large repositories
   - Dependencies: Week 4, Day 4, Step 1
   - Risk: Low

##### Day 5: MVP Completion
1. **Integrate FileTree with AppShell** (File: `frontend/src/components/layout/AppShell.tsx`)
   - Action: Add FileTree to sidebar with work mode context
   - Why: Complete main layout
   - Dependencies: Week 4, Day 4, Step 1
   - Risk: Low

2. **Write E2E tests** (File: `tests/e2e/flows/mvp.test.ts`)
   - Action: Create Playwright tests for rule creation and novel generation flows
   - Why: Verify complete user journeys
   - Dependencies: All MVP steps
   - Risk: Medium - Test environment setup

3. **Create deployment documentation** (File: `docs/deployment/mvp.md`)
   - Action: Document dev/prod setup, API endpoints, troubleshooting
   - Why: Enable local testing and deployment
   - Dependencies: All MVP steps
   - Risk: Low

#### Phase 1 Summary

| Metric | Target | Notes |
|--------|--------|-------|
| Duration | 4 weeks | 20 working days |
| Files Created | ~60 | Frontend and backend |
| Lines of Code | ~5,000 | Estimated |
| Test Coverage | > 70% | Unit and integration tests |
| Completion Criteria | User can add weapon via UI, use AI to continue chapter, commands transmit to Claude Code | Core functionality working |

---

### Phase 2: Harness Integration (3 weeks)

**Objective:** Complete support for all Harness workflows including proposal management, outcome scoring, and trace history.

**Deliverables:**
- Module C (Harness Management Panel)
- Module F (Version Release Wizard)
- Bidirectional command queue feedback
- Execution log panel
- TRACE parsing and display

**Acceptance Criteria:**
- User can trigger `propose.sh` from UI
- User can view TRACE history
- Command execution shows affected_files

#### Week 1: Module C - Harness Management Panel

##### Day 1: Harness Data Service
1. **Create HarnessManager service** (File: `backend/src/services/HarnessManager.ts`)
   - Action: Implement methods to read traces/ and scores/ directories
   - Why: Backend layer for Harness data access
   - Dependencies: None
   - Risk: Low

2. **Parse TRACE files** (File: `backend/src/utils/traceParser.ts`)
   - Action: Implement parser to extract TRACE comments from HTML/MD files
   - Why: Extract structured data from TRACE annotations
   - Dependencies: None
   - Risk: Medium - Comment extraction regex reliability

3. **Parse OUTCOME files** (File: `backend/src/utils/traceParser.ts`)
   - Action: Implement parser for score JSON files in .claude/harness/scores/
   - Why: Extract outcome data for quality tracking
   - Dependencies: None
   - Risk: Low

##### Day 2: Proposal Trigger (C.1)
1. **Create ProposalTrigger component** (File: `frontend/src/components/modules/HarnessPanel/components/ProposalTrigger.tsx`)
   - Action: Build UI with "Run Improvement Proposal" button and force toggle
   - Why: User interface for triggering propose.sh script
   - Dependencies: None
   - Risk: Low

2. **Implement propose.sh call** (File: `backend/src/services/HarnessManager.ts`)
   - Action: Add method to execute bash ".claude/harness/scripts/propose.sh"
   - Why: Execute Harness proposal generation
   - Dependencies: None
   - Risk: Medium - Shell execution security

3. **Add progress display** (File: `frontend/src/components/modules/HarnessPanel/components/ProposalTrigger.tsx`)
   - Action: Show proposal generation progress with loading indicator
   - Why: User feedback during long-running operation
   - Dependencies: Week 2, Day 2, Step 2
   - Risk: Low

##### Day 3: Score Recording (C.2)
1. **Create ScoreButtons component** (File: `frontend/src/components/modules/HarnessPanel/components/ScoreButtons.tsx`)
   - Action: Build UI with Accept/Reject buttons and 1-5 rating slider
   - Why: User interface for outcome recording
   - Dependencies: None
   - Risk: Low

2. **Implement score-outcome.sh call** (File: `backend/src/services/HarnessManager.ts`)
   - Action: Add method to execute bash ".claude/harness/scripts/score-outcome.sh"
   - Why: Record user feedback to Harness system
   - Dependencies: None
   - Risk: Medium - Shell execution with parameters

3. **Add verdict selection** (File: `frontend/src/components/modules/HarnessPanel/components/ScoreButtons.tsx`)
   - Action: Implement dropdown for modified type (tone_adjust/content_edit/placement_change/factual_correction)
   - Why: Capture detailed feedback when user modifies content
   - Dependencies: Week 2, Day 3, Step 1
   - Risk: Low

##### Day 4: Trace History (C.3)
1. **Create TraceTimeline component** (File: `frontend/src/components/modules/HarnessPanel/components/TraceTimeline.tsx`)
   - Action: Build timeline UI showing all TRACE entries with workflow filtering
   - Why: Visual display of Harness action history
   - Dependencies: Week 2, Day 1, Step 2
   - Risk: Low

2. **Implement workflow filter** (File: `frontend/src/components/modules/HarnessPanel/components/TraceTimeline.tsx`)
   - Action: Add dropdown to filter traces by workflow type
   - Why: Focus on specific workflows during review
   - Dependencies: Week 2, Day 4, Step 1
   - Risk: Low

3. **Add trace detail view** (File: `frontend/src/components/modules/HarnessPanel/components/TraceTimeline.tsx`)
   - Action: Show expanded view with pre_checks findings and confidence score
   - Why: Detailed inspection of individual traces
   - Dependencies: Week 2, Day 4, Step 1
   - Risk: Low

##### Day 5: Candidate Management (C.4)
1. **Create CandidateManager component** (File: `frontend/src/components/modules/HarnessPanel/components/CandidateManager.tsx`)
   - Action: Build UI listing available proposals with install button
   - Why: User interface for proposal approval
   - Dependencies: Week 2, Day 1, Step 1
   - Risk: Low

2. **Implement install-candidate.sh call** (File: `backend/src/services/HarnessManager.ts`)
   - Action: Add method to execute bash ".claude/harness/scripts/install-candidate.sh"
   - Why: Install selected Harness candidate
   - Dependencies: None
   - Risk: Medium - Shell execution with candidate ID

3. **Add candidate comparison** (File: `frontend/src/components/modules/HarnessPanel/components/CandidateManager.tsx`)
   - Action: Show diff between current CLAUDE.md and proposed candidate
   - Why: User visibility into proposed changes
   - Dependencies: Week 2, Day 5, Step 2
   - Risk: Low

#### Week 2: Module F - Version Release Wizard

##### Day 1: Pre-Release Checks (F.1)
1. **Create PreReleaseChecks component** (File: `frontend/src/components/modules/VersionRelease/components/PreReleaseChecks.tsx`)
   - Action: Build UI showing checklist: commits, conflicts, tests
   - Why: Visual confirmation of release readiness
   - Dependencies: None
   - Risk: Low

2. **Implement git status check** (File: `backend/src/services/GitService.ts`)
   - Action: Add method to check for uncommitted changes and conflicts
   - Why: Verify repository state before release
   - Dependencies: None
   - Risk: Low

3. **Implement test status check** (File: `backend/src/services/TestService.ts`)
   - Action: Add method to run test suite and return results
   - Why: Ensure all tests passing before release
   - Dependencies: None
   - Risk: Medium - Test execution reliability

##### Day 2: Changelog Draft (F.2)
1. **Create ChangelogDraft component** (File: `frontend/src/components/modules/VersionRelease/components/ChangelogDraft.tsx`)
   - Action: Build UI showing auto-generated changelog with edit capability
   - Why: User can review and modify changelog before release
   - Dependencies: Week 3, Day 1, (from Phase 2), Step 2
   - Risk: Low

2. **Implement changelog generation** (File: `backend/src/services/ChangelogService.ts`)
   - Action: Parse traces/ and existing CHANGELOG to generate draft
   - Why: Automate changelog creation from Harness data
   - Dependencies: Week 2, Day 1, Step 2
   - Risk: Medium - TRACE data aggregation logic
   - P1-9 Enhancement: Auto-reads .claude/harness/traces/ and CHANGELOG, generates draft with proper format; Supports release type filtering (hotfix/minor/major) with dynamic check adjustment

3. **Add version suggestion** (File: `backend/src/services/ChangelogService.ts`)
   - Action: Calculate next version number based on change types
   - Why: Per CLAUDE.md version management rules
   - Dependencies: Week 3, Day 2, Step 2
   - Risk: Low

##### Day 3: Step Confirmation (F.3)
1. **Create ReleaseWizard component** (File: `frontend/src/components/modules/VersionRelease/components/ReleaseWizard.tsx`)
   - Action: Build multi-step wizard with progress indicator
   - Why: Guide user through release process
   - Dependencies: None
   - Risk: Low

2. **Implement step navigation** (File: `frontend/src/components/modules/VersionRelease/components/ReleaseWizard.tsx`)
   - Action: Add next/back buttons with step validation
   - Why: Ensure each step completed before proceeding
   - Dependencies: Week 3, Day 3, Step 1
   - Risk: Low

3. **Add confirmation dialogs** (File: `frontend/src/components/modules/VersionRelease/components/ReleaseWizard.tsx`)
   - Action: Show confirmation before executing destructive operations
   - Why: Prevent accidental data loss
   - Dependencies: Week 3, Day 3, Step 1
   - Risk: Low

##### Day 4: Error Prevention (F.4)
1. **Implement dangerous operation highlighting** (File: `frontend/src/components/modules/VersionRelease/components/ReleaseWizard.tsx`)
   - Action: Highlight operations like "delete file" in red with warning icon
   - Why: Visual indication of high-risk actions
   - Dependencies: Week 3, Day 3, Step 1
   - Risk: Low

2. **Add rollback confirmation** (File: `frontend/src/components/modules/VersionRelease/components/ReleaseWizard.tsx`)
   - Action: Double confirmation for operations like git reset
   - Why: Extra protection for destructive git operations
   - Dependencies: Week 3, Day 4, Step 1
   - Risk: Low

3. **Create operation log** (File: `frontend/src/components/modules/VersionRelease/components/ReleaseWizard.tsx`)
   - Action: Log all release steps with timestamps and results
   - Why: Audit trail for release process
   - Dependencies: Week 3, Day 4, Step 1
   - Risk: Low

##### Day 5: Execution Feedback (F.5)
1. **Implement release execution** (File: `backend/src/services/ReleaseService.ts`)
   - Action: Execute release steps: move PDF, create tag, update README
   - Why: Perform actual release operations
   - Dependencies: Week 3, Day 1, Step 3
   - Risk: High - Release operations are critical and destructive

2. **Add step-by-step feedback** (File: `frontend/src/components/modules/VersionRelease/components/ReleaseWizard.tsx`)
   - Action: Update UI with success/failure status for each step
   - Why: Real-time visibility into release progress
   - Dependencies: Week 3, Day 5, Step 1
   - Risk: Low

3. **Handle execution errors** (File: `backend/src/services/ReleaseService.ts`)
   - Action: Implement error handling with rollback option
   - Why: Graceful handling of partial failures
   - Dependencies: Week 3, Day 5, Step 1
   - Risk: High - Rollback logic complexity

#### Week 3: Bidirectional Feedback & Integration

##### Day 1: Command Response Handling
1. **Extend ClaudeCodeBridge response parsing** (File: `backend/src/services/ClaudeCodeBridge.ts`)
   - Action: Parse affected_files, trace_id, confidence from response
   - Why: Capture detailed execution results
   - Dependencies: Phase 1, Week 4, Day 2
   - Risk: Medium - Response format validation

2. **Update command queue status** (File: `backend/src/ws/commandQueue.ts`)
   - Action: Update command status with execution results and push to
   - Why: Frontend receives detailed execution feedback
   - Dependencies: Week 3, Day 1, Step 1
   - Risk: Low

3. **Store TRACE data locally** (File: `backend/src/services/HarnessManager.ts`)
   - Action: Save parsed TRACE data to in-memory store for quick access
   - Why: Reduce file I/O for frequent TRACE queries
   - Dependencies: Phase 2, Week 1, Day 1, Step 2
   - Risk: Low

##### Day 2: Execution Log Panel
1. **Create ExecutionLogPanel component** (File: `frontend/src/components/common/ExecutionLogPanel.tsx`)
   - Action: Build UI showing detailed execution logs with expand/collapse
   - Why: User visibility into command execution details
   - Dependencies: Week 3, Day 1, Step 2
   - Risk: Low

2. **Implement log filtering** (File: `frontend/src/components/common/ExecutionLogPanel.tsx`)
   - Action: Add filters for success/failed commands and time range
   - Why: Focus on relevant log entries
   - Dependencies: Week 3, Day 2, Step 1
   - Risk: Low

3. **Add log export** (File: `frontend/src/components/common/ExecutionLogPanel.tsx`)
   - Action: Implement download button to export logs as JSON
   - Why: Enable offline analysis of execution history
   - Dependencies: Week 3, Day 2, Step 1
   - Risk: Low

##### Day 3: WebSocket Enhancements
1. **Implement heartbeat mechanism** (File: `backend/src/ws/commandQueue.ts`)
   - Action: Add ping/pong messages to detect dead connections
   - Why: Detect and clean up stale WebSocket connections
   - Dependencies: Phase 1, Week 4, Day 1, Step 1
   - Risk: Low

2. **Add connection status indicator** (File: `frontend/src/hooks/useWebSocket.ts`)
   - Action: Show connected/disconnected status in UI
   - Why: User awareness of backend connectivity
   - Dependencies: Phase 1, Week 4, Day 3, Step 1
   - Risk: Low

3. **Implement reconnection logic** (File: `frontend/src/hooks/useWebSocket.ts`)
   - Action: Auto-reconnect with exponential backoff on disconnect
   - Why: Improve reliability of WebSocket connections
   - Dependencies: Week 3, Day 3, Step 2
   - Risk: Medium - Reconnection timing and state management

##### Day 4: Harness Panel Integration
1. **Integrate HarnessPanel with AppShell** (File: `frontend/src/App.tsx`)
   - Action: Add routing to show HarnessPanel in main content area
   - Why: Navigation to Harness management functionality
   - Dependencies: Week 1, Day 3, Step 2, Phase 2, Week 1, Day 2, Step 1
   - Risk: Low

2. **Integrate VersionRelease with AppShell** (File: `frontend/src/App.tsx`)
   - Action: Add routing to show VersionRelease in main content area
   - Why: Navigation to version release functionality
   - Dependencies: Week 1, Day 3, Step 2, Phase 2, Week 2, Day 3, Step 1
   - Risk: Low

3. **Add work mode switching** (File: `frontend/src/components/layout/WorkModeSwitcher.tsx`)
`)
   - Action: Implement dropdown to switch between Rule Design, Novel Creation, Balance Adjustment, Harness Management modes
   - Why: Per design doc Section 3.4, optimize layout per task
   - Dependencies: Week 1, Day 3, Step 1
   - Risk: Low
   - P1-8 Enhancement: Implement 「灵感模式」vs「执行模式」dual track; Inspiration mode only records ideas without generating plans; Execution mode enters plan generation and confirmation flow; Supports async confirmation for creative flow

##### Day 5: Testing & Documentation
1. **Write integration tests** (File: `tests/integration/harness.test.ts`)
   - Action: Test proposal trigger, score recording, and candidate installation flows
   - Why: Verify Harness integration works as expected
   - Dependencies: All Phase 2 steps
   - Risk: Low

2. **Write E2E tests** (File: `tests/e2e/flows/harness.test.ts`)
   - Action: Create Playwright tests for complete Harness management flow
   - Why: Verify end-to-end Harness workflows
   - Dependencies: Week 3, Day 5, Step 1
   - Risk: Medium - Test environment setup

3. **Create API documentation** (File: `docs/api/harness.md`)
   - Action: Document Harness API endpoints and data structures
   - Why: Reference for frontend developers
   - Dependencies: All Phase 2 steps
   - Risk: Low

#### Phase 2 Summary

| Metric | Target | Notes |
|--------|--------|-------|
| Duration | 3 weeks | 15 working days |
| Files Created | ~30 | Harness and release components |
| Lines of Code | ~3,000 | Estimated |
| Test Coverage | > 75% | Integration and E2E tests |
| Completion Criteria | User can trigger propose.sh, view TRACE history, command execution shows affected_files | Full Harness workflow support |

---

### Phase 3: Enhanced Features (4 weeks)

**Objective:** Complete implementation of all P0/P1 features across remaining modules.

**Deliverables:**
- Module D (Numerical Balance Tool)
- Module E (Terminology Table Editor)
- Module G (Harness Quality Dashboard)
- Module H (Worldview Quick Lookup Panel)
- Idea Library automatic classification
- Work mode switching

**Acceptance Criteria:**
- All 8 modules P0 features usable
- User can switch between work modes
- Idea library automatic classification confidence indicator correct

#### Week 1: Module D - Numerical Balance Tool

##### Day 1: Weapon Table (D.1)
1. **Create WeaponTable component** (File: `frontend/src/components/modules/BalanceTool/components/WeaponTable.tsx`)
   - Action: Build sortable, filterable table of weapons with columns: name, damage, price, type
   - Why: Per design doc, display weapon data for balance analysis
   - Dependencies: None
   - Risk: Low

2. **Implement sorting** (File: `frontend/src/components/modules/BalanceTool/components/WeaponTable.tsx`)
   - Action: Add click handlers to sort by any column with ascending/descending toggle
   - Why: Enable comparison of weapons by any metric
   - Dependencies: Week 4, Day 1, Step 1
   - Risk: Low

3. **Implement filtering** (File: `frontend/src/components/modules/BalanceTool/components/WeaponTable.tsx`)
   - Action: Add search box to filter by name and dropdown for weapon type
   - Why: Focus on specific weapons during analysis
   - Dependencies: Week 4, Day 1, Step 1
   - Risk: Low

##### Day 2: DPS Calculator (D.2)
1. **Create BalanceCalculator utility** (File: `backend/src/services/BalanceCalculator.ts`)
   - Action: Implement DPS calculation: floor(D * (Y+1)/2) + Z for XdY+Z format
   - Why: Per design doc Section 4.4, calculate expected damage
   - Dependencies: None
   - Risk: Low

2. **Create DPSChart component** (File: `frontend/src/components/modules/BalanceTool/components/DPSChart.tsx`)
   - Action: Build bar chart showing DPS for each weapon using Recharts
   - Why: Visual comparison of weapon damage potential
   - Dependencies: Week 4, Day 2, Step 1
   - Risk: Medium - Chart configuration and responsiveness

3. **Add damage formula input** (File: `frontend/src/components/modules/BalanceTool/components/DPSChart.tsx`)
   - Action: Add input field for custom damage formula (XdY+Z) with preview
   - Why: Test damage formulas before committing
   - Dependencies: Week 4, Day 2, Step 1
   - Risk: Low

##### Day 3: Price Ratio Chart (D.3)
1. **Create PriceRatioChart component** (File: `frontend/src/components/modules/BalanceTool/components/PriceRatioChart.tsx`)
   - Action: Build scatter plot comparing price vs DPS with trend line
   - Why: Visual identification of price/performance outliers
   - Dependencies: Week 4, Day 2, Step 1
   - Risk: Medium - Chart configuration

2. **Implement ratio calculation** (File: `backend/src/services/BalanceCalculator.ts`)
   - Action: Add method to calculate damage per gold: damage / price
   - Why: Per design doc Section 4.4, quantify efficiency
   - Dependencies: Week 4, Day 2, Step 1
   - Risk: Low

3. **Add ratio display** (File: `frontend/src/components/modules/BalanceTool/components/WeaponTable.tsx`)
   - Action: Add column showing damage per gold for each weapon
   - Why: Quick reference for efficiency comparison
   - Dependencies: Week 4, Day 3, Step 2
   - Risk: Low

##### Day 4: Anomaly Detection (D.4)
1. **Create AnomalyDetector component** (File: `frontend/src/components/modules/BalanceTool/components/AnomalyDetector.tsx`)
   - Action: Build UI highlighting weapons deviating >30% from category average
   - Why: Per design doc Section 4.4, flag unbalanced equipment
   - Dependencies: Week 4, Day 2, Step 1
   - Risk: Low

2. **Implement anomaly detection logic** (File: `backend/src/services/BalanceCalculator.ts`)
   - Action: Add method to calculate category averages and flag outliers
   - Why: Identify statistically significant deviations
   - Dependencies: Week 4, Day 4, Step 1
   - Risk: Low

3. **Add adjustment suggestions** (File: `frontend/src/components/modules/BalanceTool/components/AnomalyDetector.tsx`)
   - Action: Show suggested price adjustments to bring weapons within 10% of average
   - Why: Provide actionable recommendations
   - Dependencies: Week 4, Day 4, Step 2
   - Risk: Low

##### Day 5: Balance Tool Integration
1. **Create BalanceTool component** (File: `frontend/src/components/modules/BalanceTool/index.tsx`)
   - Action: Integrate WeaponTable, DPSChart, PriceRatioChart, AnomalyDetector
   - Why: Complete balance analysis interface
   - Dependencies: Week 4, Day 1, Step 1, Week 4, Day 2, Step 2, Week 4, Day 3, Step 1, Week 4, Day 4, Step 1
   - Risk: Low

2. **Integrate with AppShell** (File: `frontend/src/App.tsx`)
   - Action: Add routing to show BalanceTool in main content area
   - Why: Navigation to balance analysis functionality
   - Dependencies: Week 1, Day 3, Step 2, Week 4, Day 5, Step 1
   - Risk: Low

3. **Write integration tests** (File: `tests/integration/balanceTool.test.ts`)
   - Action: Test balance calculation and anomaly detection
   - Why: Verify accuracy of balance analysis
   - Dependencies: All Week 4 steps
   - Risk: Low

#### Week 2: Module E - Terminology Table Editor

##### Day 1: Term Table (E.1)
1. **Create TermTable component** (File: `frontend/src/components/modules/TerminologyEditor/components/TermTable.tsx`)
   - Action: Build tabbed interface showing terms grouped by category (阵营/科技/地点/机制/角色)
   - Why: Per design doc, display terminology.yaml with category grouping
   - Dependencies: None
   - Risk: Low

2. **Implement table columns** (File: `frontend/src/components/modules/TerminologyEditor/components/TermTable.tsx`)
   - Action: Add columns: canonical name, aliases (comma-separated), context, actions
   - Why: Match YAML structure with intuitive UI
   - Dependencies: Week 5, Day 1, Step 1
   - Risk: Low

3. **Add category tabs** (File: `frontend/src/components/modules/TerminologyEditor/components/TermTable.tsx`)
   - Action: Implement tab navigation between terminology categories
   - Why: Organize large terminology set
   - Dependencies: Week 5, Day 1, Step 1
   - Risk: Low

##### Day 2: Add Term (E.2)
1. **Create AddTermDialog component** (File: `frontend/src/components/modules/TerminologyEditor/components/AddTermDialog.tsx`)
   - Action: Build modal form with fields: canonical name, aliases, context, category
   - Why: User interface for adding new terminology
   - Dependencies: None
   - Risk: Low

3. **Implement form validation** (File: `frontend/src/components/modules/TerminologyEditor/components/AddTermDialog.tsx`)
   - Action: Validate required fields, check for duplicate canonical names, validate alias format
   - Why: Prevent invalid terminology entries
   - Dependencies: Week 5, Day 2, Step 1
   - Risk: Low

4. **Add to terminology.yaml** (File: `backend/src/services/TerminologyService.ts`)
   - Action: Implement method to add term to YAML file with proper formatting
   - Why: Persist terminology changes
   - Dependencies: None
   - Risk: Medium - YAML structure preservation

##### Day 3: Impact Analysis (E.3)
1. **Create ImpactAnalyzer component** (File: `frontend/src/components/modules/TerminologyEditor/components/ImpactAnalyzer.tsx`)
   - Action: Build UI showing affected files count before delete/modify actions
   - Why: Per design doc Section 4.5, show consequences of terminology changes
   - Dependencies: None
   - Risk: Low

2. **Implement file scanning** (File: `backend/src/services/TerminologyService.ts`)
   - Action: Add method to scan all rules/ and fiction/ files for term usage
   - Why: Identify files affected by terminology changes
   - Dependencies: None
   - Risk: Medium - File I/O performance on large repos

3. **Show affected file list** (File: `frontend/src/components/modules/TerminologyEditor/components/ImpactAnalyzer.tsx`)
   - Action: Display list of affected files with usage count
   - Why: Detailed impact visibility
   - Dependencies: Week 5, Day 3, Step 2
   - Risk: Low

##### Day 4: Batch Replacement (E.4)
1. **Create BatchReplacer component** (File: `frontend/src/components/modules/TerminologyEditor/components/BatchReplacer.tsx`)
   - Action: Build UI with term selection, new canonical name input, preview, and confirm buttons
   - Why: Per design doc Section 4.5, enable bulk terminology updates
   - Dependencies: None
   - Risk: Low

2. **Generate replacement preview** (File: `backend/src/services/TerminologyService.ts`)
   - Action: Create method to preview changes without applying
   - Why: User verification before destructive changes
   - Dependencies: None
   - Risk: Low

3. **Execute replacement** (File: `backend/src/services/TerminologyService.ts`)
   - Action: Implement method to apply replacements across all affected files
   - Why: Perform bulk terminology updates
   - Dependencies: Week 5, Day 4, Step 2
   - Risk: High - Bulk file modification requires error handling and rollback

##### Day 5: Terminology Editor Integration
1. **Create TerminologyEditor component** (File: `frontend/src/components/modules/TerminologyEditor/index.tsx`)
   - Action: Integrate TermTable, AddTermDialog, ImpactAnalyzer, BatchReplacer
   - Why: Complete terminology management interface
   - Dependencies: Week 5, Day 1, Step 1, Week 5, Day 2, Step 1, Week 5, Day 3, Step 1, Week 5, Day 4, Step 1
   - Risk: Low

2. **Integrate with AppShell** (File: `frontend/src/App.tsx`)
   - Action: Add routing to show TerminologyEditor in main content area
   - Why: Navigation to terminology management functionality
   - Dependencies: Week 1, Day 3, Step 2, Week 5, Day 5, Step 1
   - Risk: Low

3. **Write integration tests** (File: `tests/integration/terminologyEditor.test.ts`)
   - Action: Test term addition, impact analysis, and batch replacement
   - Why: Verify terminology management correctness
   - Dependencies: All Week 5 steps
   - Risk: Low

#### Week 3: Module G - Harness Quality Dashboard

##### Day 1: Acceptance Rate Cards (G.1)
1. **Create AcceptanceRateCards component** (File: `frontend/src/components/modules/QualityDashboard/components/AcceptanceRateCards.tsx`)
   - Action: Build card grid showing: total actions, acceptance rate, rejection rate, modification rate, average quality
   - Why: Per design doc Section 4.7, display aggregate statistics
   - Dependencies: Phase 2, Week 1, Day 1, Step 3
   - Risk: Low

2. **Implement aggregation logic** (File: `backend/src/services/HarnessManager.ts`)
   - Action: Add method to calculate statistics from outcome data
   - Why: Generate dashboard metrics from raw Harness data
   - Dependencies: Phase 2, Week 1, Day 1, Step 3
   - Risk: Low

3. **Add workflow breakdown** (File: `frontend/src/components/modules/QualityDashboard/components/AcceptanceRateCards.tsx`)
   - Action: Show acceptance rate by workflow type
   - Why: Identify high/low performing workflows
   - Dependencies: Week 6, Day 1, Step 2
   - Risk: Low

##### Day 2: Trend Chart (G.2)
1. **Create TrendChart component** (File: `frontend/src/components/modules/QualityDashboard/components/TrendChart.tsx`)
   - Action: Build line chart showing outcome quality over time using Recharts
   - Why: Per design doc Section 4.7, visualize quality trends
   - Dependencies: Phase 2, Week 1, Day 1, Step 3
   - Risk: Medium - Chart configuration

2. **Implement time series aggregation** (File: `backend/src/services/HarnessManager.ts`)
   - Action: Add method to group outcomes by day with average quality
   - Why: Generate trend data points
   - Dependencies: Phase 2, Week 1, Day 1, Step 3
   - Risk: Low

3. **Add date range selector** (File: `frontend/src/components/modules/QualityDashboard/components/TrendChart.tsx`)
   - Action: Implement date range picker to filter trend data
   - Why: Focus on specific time periods
   - Dependencies: Week 6, Day 2, Step 1
   - Risk: Low

##### Day 3: Workflow Comparison (G.3)
1. **Create WorkflowComparison component** (File: `frontend/src/components/modules/QualityDashboard/components/WorkflowComparison.tsx`)
   - Action: Build bar chart comparing acceptance rates across workflows
   - Why: Per design doc Section 4.7, visualize workflow performance
   - Dependencies: Phase 2, Week 1, Day 1, Step 3
   - Risk: Medium - Chart configuration

2. **Implement comparison logic** (File: `backend/src/services/HarnessManager.ts`)
   - Action: Add method to calculate acceptance rate per workflow
   - Why: Generate comparison data
   - Dependencies: Phase 2, Week 1, Day 1, Step 3
   - Risk: Low

3. **Add detailed drill-down** (File: `frontend/src/components/modules/QualityDashboard/components/WorkflowComparison.tsx`)
   - Action: Click workflow bar to show recent outcomes for that workflow
   - Why: Detailed inspection of workflow performance
   - Dependencies: Week 6, Day 3, Step 2
   - Risk: Low

##### Day 4: Recent Errors (G.4)
1. **Create RecentErrors component** (File: `frontend/src/components/modules/QualityDashboard/components/RecentErrors.tsx`)
   - Action: Build list showing recent rejected outcomes with error details
   - Why: Per design doc Section 4.7, highlight failures for investigation
   - Dependencies: Phase 2, Week 1, Day 1, Step 3
   - Risk: Low

2. **Implement rejection filtering** (File: `backend/src/services/HarnessManager.ts`)
   - Action: Add method to filter outcomes by verdict
   - Why: Extract rejected outcomes for error display
   - Dependencies: Phase 2, Week 1, Day 1, Step 3
   - Risk: Low

3. **Add trace linkage** (File: `frontend/src/components/modules/QualityDashboard/components/RecentErrors.tsx`)
   - Action: Click error to view associated TRACE entry
   - Why: Context for understanding failures
   - Dependencies: Week 6, Day 4, Step 2
   - Risk: Low

##### Day 5: Quality Dashboard Integration
1. **Create QualityDashboard component** (File: `frontend/src/components/modules/QualityDashboard/index.tsx`)
   - Action: Integrate AcceptanceRateCards, TrendChart, WorkflowComparison, RecentErrors
   - Why: Complete quality monitoring interface
   - Dependencies: Week 6, Day 1, Step 1, Week 6, Day 2, Step 1, Week 6, Day 3, Step 1, Week 6, Day 4, Step 1
   - Risk: Low

2. **Integrate with AppShell** (File: `frontend/src/App.tsx`)
   - Action: Add routing to show QualityDashboard in main content area
   - Why: Navigation to quality monitoring functionality
   - Dependencies: Week 1, Day 3, Step 2, Week 6, Day 5, Step 1
   - Risk: Low

3. **Write integration tests** (File: `tests/integration/qualityDashboard.test.ts`)
   - Action: Test dashboard metrics calculation and chart rendering
   - Why: Verify accuracy of quality analytics
   - Dependencies: All Week 6 steps
   - Risk: Low

#### Week 4: Module H - Worldview Quick Lookup & Idea Library Classification

##### Day 1: Term Tooltip (H.1)
1. **Create TermTooltip component** (File: `frontend/src/components/modules/WorldviewLookup/components/TermTooltip.tsx`)
   - Action: Build tooltip showing term definition on hover
   - Why: Per design doc Section 4.8, provide context for terminology
   - Dependencies: None
   - Risk: Low

2. **Implement hover detection** (File: `frontend/src/components/modules/WorldviewLookup/components/TermTooltip.tsx`)
   - Action: Add text highlighting with tooltip trigger on canonical terms
   - Why: Automatic tooltip display for recognized terms
   - Dependencies: Week 7, Day 1, Step 1
   - Risk: Medium - Performance impact on large documents

3. **Add tooltip content** (File: `frontend/src/components/modules/WorldviewLookup/components/TermTooltip.tsx`)
   - Action: Show canonical name, aliases, and context from terminology.yaml
   - Why: Complete term information
   - Dependencies: Week 7, Day 1, Step 2
   - Risk: Low

##### Day 2: Related Entries (H.2)
1. **Create RelatedEntries component** (File: `frontend/src/components/modules/WorldviewLookup/components/RelatedEntries.tsx`)
   - Action: Build sidebar panel showing worldview entries related to current content
   - Why: Per design doc Section 4.8, provide relevant context
   - Dependencies: None
   - Risk: Low

2. **Implement relevance scoring** (File: `backend/src/services/WorldviewService.ts`)
   - Action: Add method to score worldview entries by term overlap with current content
   - Why: Identify most relevant entries
   - Dependencies: None
   - Risk: Medium - Scoring algorithm calibration

3. **Add entry preview** (File: `frontend/src/components/modules/WorldviewLookup/components/RelatedEntries.tsx`)
   - Action: Show snippet of related entry content on hover
   - Why: Preview without navigation
   - Dependencies: Week 7, Day 2, Step 2
   - Risk: Low

##### Day 3: Quick Search (H.3)
1. **Create QuickSearchDialog component** (File: `frontend/src/components/modules/WorldviewLookup/components/QuickSearchDialog.tsx`)
   - Action: Build command palette dialog triggered by Cmd+K with fuzzy search
   - Why: Per design doc Section 4.8, fast access to worldview data
   - Dependencies: None
   - Risk: Low

2. **Implement fuzzy search** (File: `frontend/src/utils/fuzzySearch.ts`)
   - Action: Add fuzzy matching algorithm for term and entry names
   - Why: Tolerant search with typos
   - Dependencies: None
   - Risk: Low

3. **Add keyboard navigation** (File: `frontend/src/components/modules/WorldviewLookup/components/QuickSearchDialog.tsx`)
   - Action: Implement arrow keys and Enter to select results
   - Why: Keyboard-only workflow
   - Dependencies: Week 7, Day 3, Step 1
   - Risk: Low

##### Day 4: Idea Library Classification
1. **Create IAClassifier component** (File: `frontend/src/components/idea-library/IAClassifier.tsx`)
   - Action: Build UI showing classification status with confidence indicator
   - Why: Per design doc Section 6.3, display AI classification results
   - Dependencies: Phase 1, Week 3, Day 3, Step 1
   - Risk: Low

2. **Implement automatic classification** (File: `backend/src/services/AIClassifier.ts`)
   - Action: Add method to call Claude API for note classification
   - Why: Per design doc Section 6.3, AI-powered tag suggestion
   - Dependencies: Phase 1, Week 3, Day 3, Step 1
   - Risk: Medium - API reliability and cost management

3. **Add confidence threshold handling** (File: `frontend/src/components/idea-library/IAClassifier.tsx`)
   - Action: Apply tags automatically if confidence >= 0.8, show suggestion if 0.5-0.8, manual if < 0.5
   - Why: Per design doc Section 6.3, user control over low-confidence classifications
   - Dependencies: Week 7, Day 4, Step 2
   - Risk: Low

4. **Implement hybrid tag detection** (File: `backend/src/services/AIClassifier.ts`)
   - Action: When classification suggests multiple tags (both 'rule' and 'novel'), set IdeaNote.isHybrid = true
   - Why: P1-7, handle content that belongs to both rule and novel workflows
   - Dependencies: Week 7, Day 4, Step 2
   - Risk: Low

5. **Add dual-path checking logic** (File: `backend/src/services/CommandBuilder.ts`)
   - Action: When submitting hybrid notes to queue, generate two commands (rule_modification + novel_update) with dual-path checking report
   - Why: P1-7, ensure hybrid content passes both consistency checks
   - Dependencies: Week 7, Day 4, Step 4
   - Risk: Medium - Dual-command coordination

##### Day 5: Worldview Lookup Integration
1. **Create WorldviewLookup component** (File: `frontend/src/components/modules/WorldviewLookup/index.tsx`)
   - Action: Integrate TermTooltip, RelatedEntries, QuickSearchDialog
   - Why: Complete worldview reference interface
   - Dependencies: Week 7, Day 1, Step 1, Week 7, Day 2, Step 1, Week 7, Day 3, Step 1
   - Risk: Low

2. **Enhance work mode switching** (File: `frontend/src/components/layout/WorkModeSwitcher.tsx`)
   - Action: Add Balance Adjustment mode with appropriate layout
   - Why: Per design doc Section 3.4, complete work mode implementation
   - Dependencies: Phase 2, Week 3, Day 4, Step 3
   - Risk: Low

3. **Write integration tests** (File: `tests/integration/worldviewLookup.test.ts`)
   - Action: Test term tooltip, related entries, and quick search
   - Why: Verify worldview reference functionality
   - Dependencies: All Week 7 steps
   - Risk: Low

#### Phase 3 Summary

| Metric | Target | Notes |
|--------|--------|-------|
| Duration | 4 weeks | 20 working days |
| Files Created | ~40 | Balance, terminology, dashboard, worldview components |
| Lines of Code | ~4,000 | Estimated |
| Test Coverage | > 80% | Integration tests for all modules |
| Completion Criteria | All 8 modules P0 features usable, work mode switching functional, idea library classification working | Full P0/P1 feature set |

---

### Phase 4: Polish & Optimization (3 weeks)

**Objective:** UX enhancements, performance optimization, comprehensive testing, and documentation.

**Deliverables:**
- All P2 features implemented
- Animation and transition effects
- Performance optimizations
- E2E test suite
- User documentation

**Acceptance Criteria:**
- All features passing tests
- Performance metrics met
- Documentation complete

#### Week 1: P2 Features

##### Day 1: Version Diff (A.6)
1. **Create VersionDiff component** (File: `frontend/src/components/modules/RuleEditor/components/VersionDiff.tsx`)
   - Action: Build UI showing side-by-side diff with highlighted changes
   - Why: Per design doc Section 4.1, compare rule versions
   - Dependencies: None
   - Risk: Medium - Diff algorithm and UI

2. **Implement git diff integration** (File: `backend/src/services/GitService.ts`)
   - Action: Add method to get diff between current and previous commit
   - Why: Extract version changes from git history
   - Dependencies: None
   - Risk: Low

3. **Add diff navigation** (File: `frontend/src/components/modules/RuleEditor/components/VersionDiff.tsx`)
   - Action: Implement next/previous change buttons to navigate diff hunks
   - Why: Efficient review of changes
   - Dependencies: Week 8, Day 1, Step 1
   - Risk: Low

##### Day 2: Revision History (B.7)
1. **Create RevisionHistory component** (File: `frontend/src/components/modules/NovelAssistant/components/RevisionHistory.tsx`)
   - Action: Build timeline showing chapter git commit history
   - Why: Per design doc Section 4.2, track chapter evolution
   - Dependencies: None
   - Risk: Low

2. **Implement commit list** (File: `backend/src/services/GitService.ts`)
   - Action: Add method to get commit history for specific file
   - Why: Retrieve chapter-specific commits
   - Dependencies: None
   - Risk: Low

3. **Add content preview** (File: `frontend/src/components/modules/NovelAssistant/components/RevisionHistory.tsx`)
   - Action: Show chapter content at selected commit
   - Why: Preview historical versions
   - Dependencies: Week 8, Day 2, Step 2
   - Risk: Low

##### Day 3: Batch Adjust (D.5)
1. **Create BatchAdjust component** (File: `frontend/src/components/modules/BalanceTool/components/BatchAdjust.tsx`)
   - Action: Build UI for multi-selection and slider adjustment
   - Why: Per design doc Section 4.4, bulk numerical adjustments
   - Dependencies: Phase 3, Week 1, Day 1, Step 1
   - Risk: Low

2. **Implement multi-selection** (File: `frontend/src/components/modules/BalanceTool/components/BatchAdjust.tsx`)
   - Action: Add checkboxes to WeaponTable for multi-select
   - Why: Select multiple weapons for batch operations
   - Dependencies: Week 8, Day 3, Step 1
   - Risk: Low

3. **Add adjustment preview** (File: `frontend/src/components/modules/BalanceTool/components/BatchAdjust.tsx`)
   - Action: Show before/after values for selected weapons with slider
   - Why: Visual preview of batch changes
   - Dependencies: Week 8, Day 3, (from Phase 4), Step 2
   - Risk: Low

##### Day 4: Alias Management (E.5)
1. **Create AliasManager component** (File: `frontend/src/components/modules/TerminologyEditor/components/AliasManager.tsx`)
   - Action: Build UI for adding/removing aliases with duplicate detection
   - Why: Per design doc Section 4.5, alias management
   - Dependencies: Phase 3, Week 2, Day 1, Step 1
   - Risk: Low

3. **Add alias deduplication** (File: `frontend/src/components/modules/TerminologyEditor/components/AliasManager.tsx`)
   - Action: Prevent duplicate aliases across all terms
   - Why: Maintain terminology uniqueness
   - Dependencies: Week 8, Day 4, Step 1
   - Risk: Low

##### Day 5: P2 Features Integration
1. **Integrate VersionDiff with RuleEditor** (File: `frontend/src/components/modules/RuleEditor/index.tsx`)
   - Action: Add version history button showing VersionDiff modal
   - Why: Access version comparison from rule editor
   - Dependencies: Week 8, Day 1, Step 1
   - Risk: Low

2. **Integrate RevisionHistory with NovelAssistant** (File: `frontend/src/components/modules/NovelAssistant/index.tsx`)
   - Action: Add revision history panel
   - Why: Access chapter history from novel editor
   - Dependencies: Week 8, Day 2, Step 1
   - Risk: Low

3. **Write unit tests** (File: `tests/unit/frontend/components/p2Features.test.ts`)
   - Action: Test P2 features: VersionDiff, RevisionHistory, BatchAdjust, AliasManager
   - Why: Verify new features work correctly
   - Dependencies: All Week 8 steps
   - Risk: Low

##### Day 5-1: CommandQueuePanel Enhancements (P2-10)
1. **Add command editing** (File: `frontend/src/components/common/CommandQueuePanel.tsx`)
   - Action: Allow clicking on queued command to edit its parameters
   - Why: P2-10, enable command modification before execution
   - Dependencies: Week 4, Day 2, Step 1
   - Risk: Low

2. **Implement drag-drop reordering** (File: `frontend/src/components/common/CommandQueuePanel.tsx`)
   - Action: Add drag handlers to reorder command queue
   - Why: P2-10, allow priority adjustment of queued commands
   - Dependencies: Week 8, Day 5-1, Step 1
   - Risk: Medium - Drag-drop UI implementation

3. **Add undo and delete actions** (File: `frontend/src/components/common/CommandQueuePanel.tsx`)
   - Action: Add undo button for deleted commands and delete button for pending commands
   - Why: P2-10, provide command queue management
   - Dependencies: Week 8, Day 5-1, Step 1
   - Risk: Low

4. **Implement queue templates** (File: `frontend/src/stores/commandQueueStoreTemplate.ts`)
   - Action: Add ability to save and load command queue templates (e.g., "Modify rule → Update novel → Check balance")
   - Why: P2-10, accelerate common command sequences
   - Dependencies: Week 8, Day 5-1, Step 3
   - Risk: Low

##### Day 5-2: ExecutionLogPanel Enhancements (P2-11)
1. **Create ExecutionLogPanel component** (File: `frontend/src/components/modules/HarnessPanel/components/ExecutionLogPanel.tsx`)
   - Action: Build panel showing Harness script outputs in real-time
   - Why: P2-11, make TRACE and outcome results visible in frontend
   - Dependencies: Phase 2, Week 3, Day 3, Step 1
   - Risk: Low

2. **Implement TRACE display** (File: `frontend/src/components/modules/HarnessPanel/components/ExecutionLogPanel.tsx`)
   - Action: Parse and display TRACE records with pre_checks details
   - Why: P2-11, show pre_checks results (pass/warn/fail) with findings
   - Dependencies: Week 8, Day 5-2, Step 1
   - Risk: Low

3. **Add error details expansion** (File: `frontend/src/components/modules/HarnessPanel/components/ExecutionLogPanel.tsx`)
   - Action: Show detailed error messages and suggested fixes for failed commands
   - Why: P2-11, provide troubleshooting guidance
   - Dependencies: Week 8, Day 5-2, Step 1
   - Risk: Low

##### Day 5-3: NovelAssistant AI Suggestions (P2-12)
1. **Create AISuggestionPanel component** (File: `frontend/src/components/modules/NovelAssistant/components/AISuggestionPanel.tsx`)
   - Action: Build non-intrusive panel showing AI suggestions (continuation, style adjustment)
   - Why: P2-12, provide AI assistance without interrupting editing
   - Dependencies: Phase 1, Week 3, Day 3, Step 1
   - Risk: Low

2. **Add suggestion application** (File: `frontend/src/components/modules/NovelAssistant/components/AISuggestionPanel.tsx`)
   - Action: Allow one-click application of suggestions with "AI Assisted" badge
   - Why: P2-12, seamless integration of AI-generated content
   - Dependencies: Week 8, Day 5-3, Step 1
   - Risk: Low

3. **Implement style check indicator** (File: `frontend/src/components/modules/NovelAssistant/components/NovelEditor.tsx`)
   - Action: Add status indicator showing four-axis style check result (green/pass, yellow/partial)
   - Why: P2-12, immediate visual feedback on style compliance
   - Dependencies: Phase 1, Week 3, Day 2, Step 2
   - Risk: Low

##### Day 5-4: FileTree Enhancements (P2-13)
1. **Add bookmark functionality** (File: `frontend/src/components/layout/FileTree.tsx`)
   - Action: Allow marking files as bookmarks, show bookmarks at tree top
   - Why: P2-13, quick access to frequently used files
   - Dependencies: Phase 1, Week 4, Day 4, Step 1
   - Risk: Low

2. **Implement quick search** (File: `frontend/src/components/layout/FileTree.tsx`)
   - Action: Add Cmd+K dialog for fuzzy file name search across entire repo
   - Why: P2-13, efficient navigation without tree traversal
   - Dependencies: Week 8, Day 5-4, Step 1
   - Risk: Low

3. **Add last directory memory** (File: `frontend/src/hooks/useFileTree.ts`)
   - Action: Remember and restore last used directory for new file creation
   - Why: P2-13, reduce navigation when creating multiple files in same folder
   - Dependencies: Week 8, Day 5-4, Step 1
   - Risk: Low

#### Week 2: Performance Optimization

##### Day 1: Frontend Performance
1. **Implement code splitting** (File: `frontend/src/App.tsx`)
   - Action: Use React.lazy for route-based code splitting
   - Why: Reduce initial bundle size
   - Dependencies: None
   - Risk: Low

2. **Optimize bundle size** (File: `frontend/vite.config.ts`)
   - Action: Configure Vite build with tree shaking and minification
   - Why: Minimize download size
   - Dependencies: Week 9, Day 1, Step 1
   - Risk: Low

3. **Add bundle analysis** (File: `frontend/vite.config.ts`)
   - Action: Configure rollup-plugin-visualizer for bundle inspection
   - Why: Identify large dependencies for optimization
   - Dependencies: Week 9, Day 1, Step 2
   - Risk: Low

##### Day 2: Backend Performance
1. **Implement response caching** (File: `backend/src/api/files.ts`)
   - Action: Add in-memory cache for file reads with TTL
   - Why: Reduce redundant file I/O
   - Dependencies: None
   - Risk: Low

2. **Optimize TRACE parsing** (File: `backend/src/utils/traceParser.ts`)
   - Action: Cache parsed TRACE data in memory with invalidation on file change
   - Why: Avoid repeated parsing of large trace sets
   - Dependencies: None
   - Risk: Low

3. **Implement pagination** (File: `backend/src/api/files.ts`)
   - Action: Add offset/limit parameters to list endpoints
   - Why: Handle large directories efficiently
   - Dependencies: None
   - Risk: Low

##### Day 3: Rendering Optimization
1. **Implement virtual scrolling** (File: `frontend/src/components/common/VirtualList.tsx`)
   - Action: Create reusable virtual list component for large datasets
   - Why: Efficient rendering of large lists (file tree, traces, outcomes)
   - Dependencies: None
   - Risk: Medium - Virtual scrolling implementation complexity

2. **Apply to file tree** (File: `frontend/src/components/layout/FileTree.tsx`)
   - Action: Replace tree rendering with virtual scrolling for deep hierarchies
   - Why: Handle large repos without performance degradation
   - Dependencies: Week 9, Day 3, Step 1
   - Risk: Medium - Tree virtualization complexity

3. **Apply to trace timeline** (File: `frontend/src/components/modules/HarnessPanel/components/TraceTimeline.tsx`)
   - Action: Use virtual scrolling for trace list
   - Why: Handle large trace histories efficiently
   - Dependencies: Week 9, Day 3, Step 1
   - Risk: Low

##### Day 4: Network Optimization
1. **Implement request debouncing** (File: `frontend/src/services/apiClient.ts`)
   - Action: Add debouncing for rapid API calls (search, autocomplete)
   - Why: Reduce unnecessary requests
   - Dependencies: None
   - Risk: Low

2. **Add request batching** (File: `frontend/src/services/apiClient.ts`)
   - Action: Batch file read requests for directory loading
   - Why: Reduce HTTP round trips
   - Dependencies: Week 9, Day 4, Step 1
   - Risk: Medium - Batching logic complexity

3. **Implement offline support** (File: `frontend/src/hooks/useOffline.ts`)
   - Action: Add service worker for offline caching of static assets
   - Why: Basic functionality available without backend
   - Dependencies: None
   - Risk: Medium - Service worker complexity

##### Day 5: Performance Testing
1. **Set up Lighthouse CI** (File: `.github/workflows/lighthouse.yml`)
   - Action: Configure automated performance testing on PR
   - Why: Prevent performance regressions
   - Dependencies: Week 9, Day 1, Step 2
   - Risk: Low

2. **Create performance benchmarks** (File: `tests/performance/benchmarks.ts`)
   - Action: Write benchmarks for critical operations (file load, trace parsing, command generation)
   - Why: Establish performance baselines
   - Dependencies: Week 9, Day 2, Step 2
   - Risk: Low

3. **Run load testing** (File: `tests/performance/load.test.ts`)
   - Action: Simulate high concurrent command queue execution
   - Why: Verify system handles expected load
   - Dependencies: Phase 1, Week 4, Day 1, Step 2
   - Risk: Medium - Test environment setup

#### Week 3: UX Polish, Testing & Documentation

##### Day 1: Animation & Transitions
1. **Add page transitions** (File: `frontend/src/components/layout/AppShell.tsx`)
   - Action: Implement fade/slide transitions between work modes
   - Why: Smooth visual flow between contexts
   - Dependencies: None
   - Risk: Low

2. **Add micro-interactions** (File: `frontend/src/components/common/Button.tsx`)
   - Action: Implement hover, active, disabled states with smooth transitions
   - Why: Polished, responsive feel
   - Dependencies: None
   - Risk: Low

3. **Add loading skeletons** (File: `frontend/src/components/common/Skeleton.tsx`)
   - Action: Create reusable skeleton component for loading states
   - Why: Reduce perceived latency
   - Dependencies: None
   - Risk: Low

##### Day 2: Error Handling UX
1. **Create error boundary** (File: `frontend/src/components/common/ErrorBoundary.tsx`)
   - Action: Implement React error boundary with graceful fallback UI
   - Why: Prevent app crashes, provide recovery options
   - Dependencies: None
   - Risk: Low

2. **Enhance error messages** (File: `frontend/src/components/common/ErrorMessage.tsx`)
   - Action: Create helpful error messages with troubleshooting steps
   - Why: User guidance for common issues
   - Dependencies: None
   - Risk: Low

3. **Add retry mechanisms** (File: `frontend/src/services/apiClient.ts`)
   - Action: Implement exponential backoff retry for failed requests
   - Why: Resilience against transient failures
   - Dependencies: None
   - Risk: Low

##### Day 3: Accessibility Improvements
1. **Add keyboard navigation** (File: `frontend/src/components/layout/AppShell.tsx`)
   - Action: Implement tab navigation through main UI elements
   - Why: Keyboard-only workflow support
   - Dependencies: None
   - Risk: Low

2. **Add ARIA labels** (File: `frontend/src/components/`)
   - Action: Review and add ARIA labels to all interactive elements
   - Why: Screen reader compatibility
   - Dependencies: None
   - Risk: Low

3. **Implement focus management** (File: `frontend/src/components/common/Modal.tsx`)
   - Action: Trap focus within modals, return to trigger on close
   - Why: Accessible modal interactions
   - Dependencies: None
   - Risk: Medium - Focus trap implementation

##### Day 4: Comprehensive Testing
1. **Expand unit test coverage** (File: `tests/unit/`)
   - Action: Add tests for un-covered components and utilities
   - Why: Achieve >80% code coverage
   - Dependencies: All previous phases
   - Risk: Low

2. **Expand integration tests** (File: `tests/integration/`)
   - Action: Add cross-module integration tests
   - Why: Verify modules work together correctly
   - Dependencies: All previous phases
   - Risk: Low

3. **Complete E2E test suite** (File: `tests/e2e/flows/`)
   - Action: Add Playwright tests for all major user flows
   - Why: End-to-end verification of critical paths
   - Dependencies: All previous phases
   - Risk: Medium - Test flakiness management

##### Day 5: Documentation
1. **Create user guide** (File: `docs/user-guide.md`)
   - Action: Write comprehensive user documentation with screenshots
   - Why: User onboarding and reference
   - Dependencies: None
   - Risk: Low

2. **Create architecture documentation** (File: `docs/architecture.md`)
   - Action: Document system architecture, data flows, and design decisions
   - Why: Developer onboarding and reference
   - Dependencies: None
   - Risk: Low

3. **Create API documentation** (File: `docs/api/`)
   - Action: Document all API endpoints with request/response examples
   - Why: Frontend-backend contract reference
   - Dependencies: None
   - Risk: Low

#### Phase 4 Summary

| Metric | Target | Notes |
|--------|--------|-------|
| Duration | 3 weeks | 15 working days |
| Files Created | ~25 | P2 features, performance optimizations, docs |
| Lines of Code | ~2,500 | Estimated |
| Test Coverage | > 80% | Comprehensive test suite |
| Completion Criteria | All features passing tests, performance metrics met, documentation complete | Production-ready |

---

### Phase 5: Electron Wrapping (2-3 weeks)

**Objective:** Package application as standalone desktop executable with cross-platform support.

**Deliverables:**
- Electron main process
- Application packaging scripts
- Auto-update mechanism

**Acceptance Criteria:**
- Standalone installation and execution without command startup
- Cross-platform support (macOS/Windows/Linux)

#### Week 1: Electron Foundation

##### Day 1: Electron Setup
1. **Initialize Electron project** (File: `electron/package.json`)
   - Action: Create Electron package with dependencies
   - Why: Desktop application foundation
   - Dependencies: None
   - Risk: Low

2. **Create main process** (File: `electron/main.ts`)
   - Action: Implement Electron main process with window creation
   - Why: Chromium + Node.js runtime
   - Dependencies: Week 11, Day 1, Step 1
   - Risk: Medium - Electron API complexity

3. **Create preload script** (File: `electron/preload.ts`)
   - Action: Implement preload script with secure contextBridge API exposure
   - Why: Secure communication between renderer and main process
   - Dependencies: Week 11, Day 1, Step 2
   - Risk: Medium - Security considerations

##### Day 2: Backend Integration
1. **Start backend from main process** (File: `electron/main.ts`)
   - Action: Spawn Node.js backend process from Electron main process
   - Why: Embedded backend in desktop app
   - Dependencies: Week 11, Day 1, Step 2
   - Risk: High - Process management and cleanup

2. **Implement IPC for backend control** (File: `electron/main.ts`)
   - Action: Add IPC handlers for backend start/stop/restart
   - Why: Frontend control of embedded backend
   - Dependencies: Week 11, Day 2, Step 1
   - Risk: Medium - IPC complexity

3. **Add backend health monitoring** (File: `electron/main.ts`)
   - Action: Monitor backend process with auto-restart on crash
   - Why: Application resilience
   - Dependencies: Week 11, Day 2, Step 1
   - Risk: Medium - Crash detection and recovery

##### Day 3: Window Management
1. **Configure window settings** (File: `electron/main.ts`)
   - Action: Set window size, min/max dimensions, frame options
   - Why: Native application window behavior
   - Dependencies: Week 11, Day 1, Step 2
   - Risk: Low

2. **Implement window state persistence** (File: `electron/main.ts`)
   - Action: Save and restore window position and size between sessions
   - Why: User preference persistence
   - Dependencies: Week 11, Day 3, Step 1
   - Risk: Low

3. **Add menu bar** (File: `electron/main.ts`)
   - Action: Create application menu with File, Edit, View, Help menus
   - Why: Native menu integration
   - Dependencies: Week 11, Day 1, Step 2
   - Risk: Low

##### Day 4: DevTools & Debugging
1. **Enable DevTools in development** (File: `electron/main.ts`)
   - Action: Add keyboard shortcut to open DevTools in dev mode
   - Why: Debugging support during development
   - Dependencies: Week 11, Day 1, Step 2
   - Risk: Low

2. **Add logging** (File: `electron/main.ts`)
   - Action: Implement electron-log for process logging
   - Why: Debug and troubleshoot production issues
   - Dependencies: None
   - Risk: Low

3. **Add crash reporting** (File: `electron/main.ts`)
   - Action: Integrate electron-crash-reporter for error tracking
   - Why: Collect crash reports for debugging
   - Dependencies: Week 11, Day 4, Step 2
   - Risk: Low

##### Day 5: Environment Configuration
1. **Create development config** (File: `electron/build/config.dev.json`)
   - Action: Configure development environment settings
   - Why: Separate dev and production configs
   - Dependencies: None
   - Risk: Low

2. **Create production config** (File: `electron/build/config.prod.json`)
   - Action: Configure production environment settings
   - Why: Production-optimized settings
   - Dependencies: None
   - Risk: Low

3. **Add environment switching** (File: `electron/main.ts`)
   - Action: Implement logic to load appropriate config based on mode
   - Why: Correct configuration per environment
   - Dependencies: Week 11, Day 5, Step 1, Week 11, Day 5, Step 2
   - Risk: Low

#### Week 2: Packaging & Distribution

##### Day 1: Build Configuration
1. **Configure electron-builder** (File: `electron/package.json`)
   - Action: Set up electron-builder with app metadata and build settings
   - Why: Cross-platform packaging
   - Dependencies: None
   - Risk: Low

2. **Add application icons** (File: `electron/build/icons/`)
   - Action: Create icon sets for macOS, Windows, Linux
   - Why: Native application icons
   - Dependencies: None
   - Risk: Low

3. **Configure build targets** (File: `electron/package.json`)
   - Action: Set build targets for dmg, exe, AppImage
   - Why: Generate installers for all platforms
   - Dependencies: Week 12, Day 1, Step 1
   - Risk: Low

##### Day 2: Build Process
1. **Create frontend build for Electron** (File: `electron/build/prepare.js`)
   - Action: Script to build frontend with Electron-specific configuration
   - Why: Optimized frontend bundle for desktop
   - Dependencies: None
   - Risk: Low

2. **Create backend build for Electron** (File: `electron/build/prepare.js`)
   - Action: Script to bundle backend for Electron embedding
   - Why: Embedded backend bundle
   - Dependencies: None
   - Risk: Medium - Backend bundling complexity

3. **Add build script** (File: `electron/package.json`)
   - Action: Create npm script to run full build pipeline
   - Why: One-command build process
   - Dependencies: Week 12, Day 2, Step 1, Week 12, Day 2, Step 2
   - Risk: Low

##### Day 3: Auto-Update Mechanism
1. **Integrate electron-updater** (File: `electron/main.ts`)
   - Action: Add auto-update support with update server configuration
   - Why: Seamless application updates
   - Dependencies: None
   - Risk: Medium - Update server setup

2. **Implement update checking** (File: `electron/main.ts`)
   - Action: Add periodic update checks with user notification
   - Why: Inform users of available updates
   - Dependencies: Week 12, Day 3, Step 1
   - Risk: Low

3. **Add update UI** (File: `frontend/src/components/common/UpdateBanner.tsx`)
   - Action: Create UI component for update download/install
   - Why: User control over update process
   - Dependencies: Week 12, Day 3, Step 1
   - Risk: Low

##### Day 4: Code Signing (Production)
1. **Configure macOS code signing** (File: `electron/package.json`)
   - Action: Set up macOS certificate and provisioning profile
   - Why: Avoid macOS security warnings
   - Dependencies: None
   - Risk: High - Certificate management

2. **Configure Windows code signing** (File: `electron/package.json`)
   - Action: Set up Windows certificate signing
   - Why: Avoid Windows SmartScreen warnings
   - Dependencies: None
   - Risk: High - Certificate management

3. **Add signing to build process** (File: `electron/package.json`)
   - Action: Integrate code signing into electron-builder workflow
   - Why: Automated signed builds
   - Dependencies: Week 12, Day 4, Step 1, Week 12, Day 4, Step 2
   - Risk: High - Signing infrastructure

##### Day 5: Distribution & Testing
1. **Create release scripts** (File: `electron/build/release.sh`)
   - Action: Script to build, sign, and upload releases
   - Why: Automated release pipeline
   - Dependencies: Week 12, Day 2, Step 3, Week 12, Day 4, Step 3
   - Risk: Medium - Release automation complexity

2. **Test packaged application** (File: `tests/e2e/electron/flows/installed.test.ts`)
   - Action: Playwright tests for installed desktop application
   - Why: Verify packaged app works correctly
   - Dependencies: Week 12, Day 1, Step 3
   - Risk: Medium - Desktop testing environment

3. **Create distribution documentation** (File: `docs/distribution.md`)
   - Action: Document build, sign, and release processes
   - Why: Reference for future releases
   - Dependencies: Week 12, Day 5, Step 1
   - Risk: Low

#### Week 3 (Optional): Polish & Launch

##### Day 1: Application Polish
1. **Add splash screen** (File: `electron/splash.html`)
   - Action: Create branded loading screen
   - Why: Professional application startup experience
   - Dependencies: None
   - Risk: Low

2. **Add about dialog** (File: `electron/main.ts`)
   - Action: Implement about dialog with version info
   - Why: Application information display
   - Dependencies: Week 11, Day 3, Step 3
   - Risk: Low

3. **Add first-run experience** (File: `frontend/src/components/onboarding/Welcome.tsx`)
   - Action: Create onboarding flow for new users
   - Why: User introduction and setup
   - Dependencies: None
   - Risk: Low

##### Day 2: Installers & Bundles
1. **Create DMG customization** (File: `electron/build/dmg-background.png`)
   - Action: Add custom background for macOS installer
   - Why: Professional macOS installer appearance
   - Dependencies: None
   - Risk: Low

2. **Create NSIS customization** (File: `electron/build/installer.nsi`)
   - Action: Customize Windows installer with branding
   - Why: Professional Windows installer appearance
   - Dependencies: None
   - Risk: Medium - NSIS scripting

3. **Test installers** (File: `tests/e2e/electron/installation/`)
   - Action: Test installation, upgrade, and uninstallation flows
   - Why: Verify installer correctness
   - Dependencies: Week 13, Day 2, Step 1, Week 13, Day 2, Step 2
   - Risk: Medium - Installation testing

##### Day 3: Performance Optimization
1. **Profile application startup** (File: `electron/`)
   - Action: Measure and optimize application launch time
   - Why: Meet 2-second startup target
   - Dependencies: None
   - Risk: Low

2. **Optimize memory usage** (File: `electron/main.ts`)
   - Action: Implement memory management and garbage collection hints
   - Why: Efficient resource usage
   - Dependencies: None
   - Risk: Low

3. **Add performance telemetry** (File: `electron/main.ts`)
   - Action: Collect anonymous performance metrics
   - Why: Identify performance issues in production
   - Dependencies: None
   - Risk: Low

##### Day 4: Security Hardening
1. **Implement context isolation** (File: `electron/preload.ts`)
   - Action: Ensure context isolation is enabled for security
   - Why: Prevent prototype pollution attacks
   - Dependencies: None
   - Risk: Low

2. **Disable Node.js integration** (File: `electron/main.ts`)
   - Action: Disable Node.js integration in renderer process
   - Why: Security best practice
   - Dependencies: None
   - Risk: Low

3. **Add CSP headers** (File: `electron/main.ts`)
   - Action: Implement Content Security Policy for web views
   - Why: Restrict resource loading
   - Dependencies: None
   - Risk: Low

##### Day 5: Launch Preparation
1. **Create release notes** (File: `RELEASE_NOTES.md`)
   - Action: Write comprehensive release notes for v1.0
   - Why: User communication for launch
   - Dependencies: None
   - Risk: Low

2. **Prepare support resources** (File: `docs/support/`)
   - Action: Create FAQ, troubleshooting guide, and support contact info
   - Why: User support resources
   - Dependencies: None
   - Risk: Low

3. **Final verification** (File: `tests/e2e/flows/launch.test.ts`)
   - Action: Comprehensive E2E test of complete application workflow
   - Why: Final verification before launch
   - Dependencies: All previous steps
   - Risk: Medium - Test coverage of all features

#### Phase 5 Summary

| Metric | Target | Notes |
|--------|--------|-------|
| Duration | 2-3 weeks | 10-15 working days |
| Files Created | ~20 | Electron main process, build configs, docs |
| Lines of Code | ~1,500 | Estimated |
| Test Coverage | > 80% | Electron-specific tests |
| Completion Criteria | Standalone installation and execution, cross-platform support | Desktop application ready for distribution |

---

## 4. Component Dependencies

### 4.1 Frontend Component Dependency Graph

```
AppShell
├── FileTree
│   └── fileService (API)
├── WorkModeSwitcher
│   └── uiStore
├── CommandQueuePanel
│   ├── commandQueueStore
│   └── useWebSocket
└── [Module Components]
    ├── RuleEditor
    │   ├── RuleForm
    │   │   ├── useRuleValidation
    │   │   └── commandBuilder
    │   ├── ConsistencyChecker
    │   │   └── terminologyScanner
    │   └── TermHighlighter
    │       └── terminologyScanner
    ├── NovelAssistant
    │   ├── ChapterNav
    │   ├── NovelEditor (MonacoEditor)
    │   │   ├── StyleMetrics
    │   │   │   └── useStyleAnalysis
    │   │   ├── TermAligner
    │   │   │   └── terminologyScanner
    │   │   └── AIGenerator
    │   │       └── claudeService
    │   └── RevisionHistory (P2)
    │       └── gitService
    ├── HarnessPanel
    │   ├── ProposalTrigger
    │   │   └── harnessService
    │   ├── ScoreButtons
    │   │   └── harnessService
    │   ├── TraceTimeline
    │   │   └── harnessService
    │   └── CandidateManager
    │       └── harnessService
    ├── BalanceTool
    │   ├── WeaponTable
    │   ├── DPSChart
    │   │   └── balanceCalculator
    │   ├── AnomalyDetector
    │   │   └── balanceCalculator
    │   └── BatchAdjust (P2)
    ├── TerminologyEditor
    │   ├── TermTable
    │   ├── AddTermDialog
    │   ├── ImpactAnalyzer
    │   │   └── terminologyService
    │   ├── BatchReplacer
    │   │   └── terminologyService
    │   └── AliasManager (P2)
    ├── VersionRelease
    │   ├── PreReleaseChecks
    │   │   ├── gitService
    │   │   └── testService
    │   ├── ChangelogDraft
    │   │   └── changelogService
    │   └── ReleaseWizard
    │       └── releaseService
    ├── QualityDashboard
    │   ├── AcceptanceRateCards
    │   │   └── harnessService
    │   ├── TrendChart
    │   │   └── harnessService
    │   ├── WorkflowComparison
    │   │   └── harnessService
    │   └── RecentErrors
    │       └── harnessService
    └── WorldviewLookup
        ├── TermTooltip
        │   └── terminologyScanner
   ├── RelatedEntries
        │   └── worldviewService
        └── QuickSearchDialog
            └── fuzzySearch
```

### 4.2 Backend Service Dependency Graph

```
Server
├── Routes
│   ├── files
│   │   └── FileService
│   ├── claude
│   │   └── ClaudeBridge
│   ├── harness
│   │   └── HarnessManager
│   ├── ideas
│   │   └── IdeaLibraryService
│   └── terminology
│       └── TerminologyService
├── WebSocket
│   ├── commandQueue
│   │   ├── CommandQueueService
│   │   └── ClaudeCodeBridge
│   └── fileWatcher
│       └── chokidar
└── Services
    ├── FileService
    ├── ClaudeBridge
    ├── ClaudeCodeBridge
    ├── HarnessManager
    │   ├── traceParser
    │   └── GitService
    ├── IdeaLibraryService
    │   └── AIClassifier
    ├── BalanceCalculator
    ├── TerminologyService
    │   └── yamlParser
    ├── ChangelogService
    │   └── HarnessManager
    ├── ReleaseService
    │   ├── GitService
    │   └── TestService
    ├── WorldviewService
    │   └── terminologyScanner
    └── GitService
```

### 4.3 Phase Dependencies

```
Phase 1 (MVP)
├── Week 1: Project Setup & Foundation
│   ├── Project Initialization
│   ├── Backend Foundation
│   ├── Frontend Foundation
│   ├── Shared Types & Utilities
│   └── Initial Testing Setup
├── Week 2: Module A - Rule Editor
│   ├── File Service (depends on Backend Foundation)
│   ├── Rule Form (depends on Frontend Foundation)
│   ├── Consistency Checking (depends on Rule Form)
│   └── Command Builder (depends on Shared Types)
├── Week 3: Module B - Novel Assistant
│   ├── Chapter Navigation (depends on File Service)
│   ├── Style Analysis (independent)
│   ├── AI Generation (independent)
│   └── Term Alignment (depends on Consistency Checking utilities)
└── Week 4: Command Queue & Claude Code Bridge
    ├── Command Queue Backend (depends on Backend Foundation)
    ├── Claude Code Bridge (independent)
    ├── Command Queue Frontend (depends on Command Queue Backend)
    └── File Tree Implementation (depends on File Service)

Phase 2 (Harness Integration)
├── Week 1: Module C - Harness Management Panel
│   ├── Harness Data Service (independent)
│   ├── Proposal Trigger (depends on Harness Data Service)
│   ├── Score Recording (depends on Harness Data Service)
│   ├── Trace History (depends on Harness Data Service)
│   └── Candidate Management (depends on Harness Data Service)
├── Week 2: Module F - Version Release Wizard
│   ├── Pre-Release Checks (independent)
│   ├── Changelog Draft (depends on Pre-Release Checks)
│   ├── Step Confirmation (independent)
│   ├── Error Prevention (depends on Step Confirmation)
│   └── Execution Feedback (depends on Error Prevention)
└── Week 3: Bidirectional Feedback & Integration
    ├── Command Response Handling (depends on Claude Code Bridge)
    ├── Execution Log Panel (depends on Command Response Handling)
    ├── WebSocket Enhancements (depends on Command Queue Backend)
    └── Harness Panel Integration (depends on Week 1, Week 2 outputs)

Phase 3 (Enhanced Features)
├── Week 1: Module D - Numerical Balance Tool (independent)
├── Week 2: Module E - Terminology Table Editor (depends on File Service)
├── Week 3: Module G - Harness Quality Dashboard (depends on Harness Data Service)
└── Week 4: Module H & Idea Library
    ├── Term Tooltip (depends on Consistency Checking utilities)
    ├── Related Entries (independent)
    ├── Quick Search (independent)
    └── Idea Library Classification (depends on AI Generation)

Phase 4 (Polish & Optimization)
├── Week 1: P2 Features (depends on respective modules)
├── Week 2: Performance Optimization (depends on all previous phases)
├── Week 3: UX Polish (depends on Performance Optimization)
└── Week 3: Testing & Documentation (depends on all previous phases)

Phase 5 (Electron Wrapping)
├── Week 1: Electron Foundation (depends on all backend services)
├── Week 2: Packaging & Distribution (depends on Electron Foundation)
└── Week 3: Polish & Launch (depends on Packaging & Distribution)
```

---

## 5. Risk Assessment

### 5.1 Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Claude Code CLI integration instability** | Medium | High | - Implement robust error handling<br>- File-based communication fallback<br>- Version pinning for CLI compatibility |
| **WebSocket connection reliability** | Medium | Medium | - Implement heartbeat mechanism<br>- Exponential backoff reconnection<br>- Offline mode for critical features |
| **File I/O performance on large repos** | Low | Medium | - Implement pagination for large lists<br>- Virtual scrolling for UI rendering<br>- In-memory caching with TTL |
| **AI API cost overruns** | Medium | Medium | - Implement usage tracking and alerts<br>- Request batching and caching<br>- User-configurable rate limits |
| **YAML parsing errors** | Low | Medium | - Schema validation before parsing<br>- Graceful error recovery<br>- Backup file creation before modification |
| **Monaco Editor bundle size** | Low | Medium | - Lazy loading of editor features<br>- Custom build with only required languages<br>- Code splitting by work mode |
| **Electron process management** | Medium | High | - Comprehensive health monitoring<br>- Automatic restart on crash<br>- Graceful shutdown sequence |

### 5.2 Schedule Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **P2 features scope creep** | High | Medium | - Strict prioritization of P0/P1<br>- Phase 4 focused on polish, not new features<br>- User feedback gathering before Phase 5 |
| **Harness script compatibility changes** | Medium | High | - Version checking before script execution<br>- Graceful degradation for missing features<br>- Documented script API contract |
| **Testing time underestimated** | Medium | Medium | - Parallelize test development<br>- Automated CI/CD from Phase 1<br>- Test coverage monitoring from start |
| **Electron packaging delays** | Low | Medium | - Start Electron POC in Phase 3<br>- Document build process early<br>- Use cross-platform CI for testing |

### 5.3 User Experience Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Complexity overwhelm for new users** | Medium | Medium | - Onboarding flow in Phase 5<br>- Contextual help tooltips<br>- Progressive disclosure of advanced features |
| **Work mode confusion** | Low | Medium | - Clear mode indicators<br>- Mode-specific tooltips<br>- Keyboard shortcuts for common actions |
| **Terminology changes break existing content** | Low | High | - Impact analysis before changes<br>- Confirmation dialogs<br>- Batch replacement with preview |

### 5.4 Security Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Path traversal in file API** | Low | High | - Strict path validation<br>- Whitelist allowed directories<br>- Sandboxing file operations |
| **API key exposure in logs** | Low | High | - Redact sensitive data in logs<br>- Secure storage for keys<br>- User-controlled API key management |
| **Shell injection in script execution** | Low | Critical | - Parameterized command execution<br>- Input validation and sanitization<br>- Allowlist for executable scripts |
| **Electron security vulnerabilities** | Low | High | - Enable context isolation<br>- Disable Node.js in renderer<br>- Regular security updates |

---

## 6. Complexity Estimates

### 6.1 Component Complexity Ratings

| Component | Complexity | Primary Challenges | Estimated Days |
|-----------|------------|---------------------|----------------|
| **Project Setup** | Low | Tool configuration, monorepo setup | 5 |
| **Rule Editor** | Medium | Form validation, command generation, file placement logic | 10 |
| **Novel Assistant** | High | AI integration, style analysis, Monaco configuration | 10 |
| **Command Queue** | High | WebSocket management, error handling, state sync | 10 |
| **Harness Panel** | Medium | TRACE parsing, script execution, data aggregation | 5 |
| **Version Release** | High | Git operations, rollback logic, multi-step wizard | 5 |
| **Balance Tool** | Medium | Calculation logic, chart rendering, anomaly detection | 5 |
| **Terminology Editor** | Medium | YAML manipulation, impact analysis, batch operations | 5 |
| **Quality Dashboard** | Medium | Data aggregation, chart configuration, filtering | 5 |
| **Worldview Lookup** | Low | Text highlighting, fuzzy search, relevance scoring | 5 |
| **Performance Optimization** | Medium | Profiling, caching, virtualization | 5 |
| **Electron Wrapping** | Medium | Process management, packaging, code signing | 10-15 |

### 6.2 Integration Complexity

| Integration | Complexity | Primary Challenges | Estimated Overhead |
|-------------|------------|---------------------|-------------------|
| **Frontend-Backend Communication** | Medium | WebSocket reliability, error propagation, state sync | +20% |
| **Claude Code Integration** | High | CLI compatibility, file-based communication, response parsing | +30% |
| **Harness System Integration** | Medium | Script execution, TRACE parsing, outcome tracking | +20% |
| **Electron-Backend Embedding** | High | Process lifecycle, IPC communication, crash recovery | +25% |

### 6.3 Overall Complexity

| Phase | Base Complexity | Integration Overhead | Total Effort |
|-------|----------------|----------------------|--------------|
| **Phase 1: MVP** | 20 days | +4 days (20%) | 24 days |
| **Phase 2: Harness** | 15 days | +3 days (20%) | 18 days |
| **Phase 3: Enhanced** | 20 days | +2 days (10%) | 22 days |
| **Phase 4: Polish** | 15 days | +1 day (7%) | 16 days |
| **Phase 5: Electron** | 10-15 days | +3 days (20-30%) | 13-18 days |
| **Total** | 80-85 days | +13 days | 93-98 days |

**Total Estimated Duration: 93-98 working days (~19-20 weeks)**

---

## 7. Success Criteria

### 7.1 Functional Success

- [ ] All P0 features across all 8 modules are implemented and tested
- [ ] All P1 features are implemented and tested
- [ ] P2 features are implemented where value justifies effort
- [ ] Command queue successfully transmits commands to Claude Code
- [ ] Harness integration enables proposal triggering, score recording, and trace viewing
- [ ] Work mode switching provides optimized layouts for different tasks
- [ ] Idea library classification confidence indicators are accurate
- [ ] All automated tests pass with >80% code coverage

### 7.2 Non-Functional Success

- [ ] Initial application load time < 2 seconds
- [ ] Page response time < 100ms
- [ ] WebSocket connections remain stable during extended use
- [ ] Application handles large repositories (>1000 files) without performance degradation
- [ ] All data operations respect file permissions
- [ ] Claude API Key is securely stored and never exposed in logs
- [ ] Error messages are actionable and include troubleshooting steps
- [ ] Application works offline for basic file viewing

### 7.3 User Experience Success

- [ ] New users can complete a rule creation flow without documentation
- [ ] Work mode switching is intuitive and contextually appropriate
- [ ] Command queue provides clear visibility into pending and executed operations
- [ ] Terminology inconsistencies are highlighted before submission
- [ ] Style analysis provides meaningful feedback for novel editing
- [ ] Balance tool surfaces actionable insights for equipment tuning
- [ ] Harness panel makes proposal management accessible without CLI knowledge

### 7.4 Distribution Success

- [ ] Electron application installs and runs on macOS, Windows, and Linux
- [ ] Auto-update mechanism works correctly
- [ ] Code signing eliminates security warnings on all platforms
- [ ] Application starts in < 2 seconds on typical hardware
- [ ] Memory usage remains < 500MB during normal operation
- [ ] Application can be cleanly uninstalled without leaving artifacts

---

## 8. Post-Launch Considerations

### 8.1 v2.0 Features (Future)

- Multi-provider AI support (OpenAI, Anthropic, local models)
- Collaborative editing with real-time sync
- Advanced visualization (mind maps, relationship graphs)
- Plugin system for custom workflows
- Cloud synchronization (optional, opt-in)

### 8.2 Maintenance

- Monthly dependency updates
- Quarterly security audits
- Annual UX review and polish
- Harness system evolution tracking

### 8.3 Support

- Issue tracking and triage
- User feedback collection
- Documentation maintenance
- Community forum moderation

---

**End of Implementation Plan**
