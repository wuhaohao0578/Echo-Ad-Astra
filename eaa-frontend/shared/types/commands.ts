// P1-7: 支持多维标签（如同时包含 'rule' 和 'novel'）
export interface IdeaNote {
  id: string;
  content: string;
  tags: string[];
  status: 'active' | 'classified' | 'ai_generated';
  confidence: number;
  isHybrid?: boolean;
  created_at: string;
  last_modified: string;
  position: { x: number; y: number };
}

export interface ClassificationRequest {
  content: string;
  available_tags: string[];
}

export interface ClassificationResponse {
  suggested_tag: string;
  confidence: number;
  alternative_tags: Array<{
    tag: string;
    confidence: number;
  }>;
}

export interface Command {
  id: string;
  type: 'rule_modification' | 'novel_update' | 'harness_command';
  action: string;
  payload: Record<string, unknown>;
  status: 'pending' | 'executing' | 'success' | 'failed';
  affected_files: string[];
  error: string | null;
  created_at: string;
  executed_at?: string;
}

export interface RuleModificationPayload {
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

export interface NovelUpdatePayload {
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
