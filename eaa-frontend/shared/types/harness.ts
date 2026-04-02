export interface Trace {
  workflow: string;
  step: string;
  harness_rule_ref: string;
  confidence: number;
  pre_checks: Array<{
    check: string;
    result: 'pass' | 'warn' | 'fail';
    findings: string[];
  }>;
  timestamp: string;
}

export interface Outcome {
  verdict: 'accepted' | 'rejected' | 'modified';
  quality?: {
    overall?: number;
    [dimension: string]: number;
  };
  mod_type?:?: 'tone_adjust' | 'content_edit' | 'placement_change' | 'factual_correction';
  timestamp: string;
}

export interface Proposal {
  id: string;
  harness_version: string;
  active_since: string;
  changes: Array<{
    rule_ref: string;
    description: string;
  }>;
  rationale: string;
}
