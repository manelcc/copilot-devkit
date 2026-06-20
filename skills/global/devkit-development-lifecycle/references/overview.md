# Development Lifecycle Overview

Complete guided development cycle from planning to merge-ready state with expert consultation, quality gates, and interactive user decisions.

## Workflow Diagram

```mermaid
flowchart TD
    Start[Receive US] --> A1[A.1 Confirm Scope]
    A1 --> A11[A.1.1 Consult Experts]
    A11 --> A11a[Architecture Expert]
    A11 --> A11b[Patterns Expert]
    A11 --> A11c[Quality Expert]
    A11a --> A12
    A11b --> A12
    A11c --> A12[A.1.2 Generate Plan]
    A12 --> A13[A.1.3 Generate Test Cases + Smoke]
    A13 --> B[B. Implementation]
    B --> C[C. Generate Unit Tests]
    C --> D1[D.1 Clean-Code Analysis]
    D1 --> D2[D.2 Architecture Analysis]
    D2 --> D3[D.3 Coverage Validation]
    D3 --> D4{D.4 All Gates Pass?}
    D4 -->|No| E[E. Correction Loop]
    E --> E1{Iteration < 3?}
    E1 -->|Yes| A11
    E1 -->|No| Escalate[Escalate to User]
    D4 -->|Yes| F1[F.1 Quality Summary]
    F1 --> F2{F.2 User: E2E?}
    F2 -->|Yes| F3[F.3 E2E Instructions]
    F3 --> F4[F.4 Wait Confirmation]
    F4 --> G1
    F2 -->|No| G1{G.1 User: Smoke Tests?}
    G1 -->|Yes| G2[G.2 Execute Smoke]
    G2 --> G3[G.3 Wait Confirmation]
    G3 --> H1
    G1 -->|No| H1[H.1 Prepare Atomic Commits]
    H1 --> H2[H.2 Show Commits]
    H2 --> H3{H.3 User: Execute?}
    H3 -->|Yes| H4[Execute Commits]
    H3 -->|No| H5[Manual Commit]
    H3 -->|Edit| H2
    H4 --> I1
    H5 --> I1[I.1 Generate MR Description]
    I1 --> I2[I.2 Add Traceability]
    I2 --> I3[I.3 Persist MR Description]
    I3 --> End[Ready for Push + MR]
    Escalate --> End
```

## Phase Summary

### Phase A: Planning (Pre-Implementation)
- **A.1**: Receive and confirm User Story scope
- **A.1.1**: Consult expert agents (architecture, patterns, quality)
- **A.1.2**: Generate detailed implementation plan
- **A.1.3**: Generate test cases and select smoke tests
- **Output**: Planning artifacts in `docs/plan-implementation/`, `docs/test-cases/`, `docs/smoke-test/`

### Phase B: Implementation
- Implement according to plan
- Follow expert recommendations
- Adapt to existing code and patterns
- **Output**: Code changes in project

### Phase C: Test Generation
- Generate unit tests for implemented code
- Target coverage ≥40%
- **Output**: Test files in project

### Phase D: Quality Gates (Mandatory)
- **D.1**: Clean-code analysis (score ≥7.0, 0 critical issues)
- **D.2**: Clean-architecture analysis (0 critical violations)
- **D.3**: Test coverage validation (≥40%)
- **D.4**: Decision: pass → Phase F, fail → Phase E
- **Output**: Quality reports in `docs/quality/`

### Phase E: Correction Loop
- Collect failure reports
- Consult experts with failure context
- Regenerate plan with corrections
- Return to Phase A.1.1
- **Limit**: 3 iterations max, then escalate
- **Output**: Updated plan versions in `docs/plan-implementation/`

### Phase F: E2E Tests (Optional, User Decision)
- Generate quality summary
- Ask user if E2E tests should run
- Provide instructions adapted to stack (Docker, mobile, web)
- Wait for user confirmation
- **Output**: Optional E2E instructions in `docs/quality/`

### Phase G: Smoke Tests (Optional, User Decision)
- Ask user if smoke tests should run
- Execute automated tests or show manual checklist
- Wait for user confirmation
- **Output**: Smoke test execution results

### Phase H: Atomic Commits (User Decision)
- Prepare commits grouped by responsibility
- Show proposed commits to user
- Execute or allow manual commit
- **Output**: Atomic commits in git history

### Phase I: MR/PR Description
- Generate description with traceability
- Include links to all artifacts
- Add reviewer checklist
- **Output**: MR description in `docs/mr/`

## Handoffs

```mermaid
flowchart LR
    DevLifecycle[Development Lifecycle] -->|Phase A.1.1| ArchExpert[Architecture Expert]
    DevLifecycle -->|Phase A.1.1| PatternExpert[Patterns Expert]
    DevLifecycle -->|Phase D.1| CleanCode[devkit-clean-code-guardian]
    DevLifecycle -->|Phase D.2| CleanArch[devkit-clean-architecture-quality]
    DevLifecycle -->|Phase H| GitWorkflow[devkit-git-workflow]
    DevLifecycle -->|Phase I| MRGenerator[devkit-mr-description-generator]
    DevLifecycle -->|Scope unclear| ScrumMaster[Scrum Master]
```

## Artifacts Generated

All artifacts are persisted in the **project consuming this skill** (not in DevTools-AI repo):

```
project-consuming-skill/
  docs/
    plan-implementation/
      US-XXX-implementation-plan.md
      US-XXX-implementation-plan.md (v2)  # if correction loop
    test-cases/
      US-XXX-test-cases.md
    smoke-test/
      US-XXX-smoke-suite.md
    quality/
      US-XXX-clean-code-report.md
      US-XXX-architecture-report.md
      US-XXX-e2e-instructions.md         # optional
    mr/
      US-XXX-description.md
```

## Quality Gate Thresholds

| Gate | Threshold | Fail Behavior |
|------|-----------|---------------|
| Clean-code score | ≥7.0/10 | Enter correction loop |
| Clean-code critical issues | 0 | Enter correction loop |
| Architecture critical violations | 0 | Enter correction loop |
| Test coverage | ≥40% | Enter correction loop |

## User Decision Points

| Phase | Decision | Options |
|-------|----------|---------|
| F.2 | Execute E2E tests? | Yes, No |
| F.4 | E2E tests passed? | Confirmed, Failed |
| G.1 | Execute smoke tests? | Yes, No |
| G.3 | Smoke tests passed? | Confirmed, Failed |
| H.3 | Execute proposed commits? | Yes, No, Edit messages |

## Correction Loop Limit

- **Maximum iterations**: 3
- **After 3 failures**: Escalate to user with summary and recommendation
- **Escalation includes**:
  - All quality reports from 3 attempts
  - Persistent issues summary
  - Recommendation: manual intervention or scope reduction
