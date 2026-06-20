# MR: US-013-PLUS - Devkit Naming Standardization & Clean Architecture Quality Model

**Branch:** `feature/US-013-PLUS-import-patterns-quality`

**Objective:** Complete the governance standardization of the COPILOT repository by enforcing consistent `devkit-` naming across all artifacts (agents, skills, prompts, instructions) and implementing Bankinter's canonical Clean Architecture Quality audit model for multi-language backend services.

---

## 🎯 Summary

This MR delivers **Phase 3** of the governance refactor:

1. **✅ Complete Devkit Naming Compliance** — All agents, skills, prompts, and instructions now use `devkit-<domain>-<artifact>` naming convention.
2. **✅ Global Clean Architecture Quality Framework** — Bankinter-inspired multi-language (Java/Kotlin/Swift/Python) quality audit skill with severity-based rules.
3. **✅ Stack-Specific CA Quality Audit Agents/Skills/Prompts** — Android, iOS, Python with handoff logic to `devkit-clean-code-guardian` for pure readability issues.
4. **✅ Mandatory Routing Policy** — All 7 project orchestrators updated with decision logic: architecture+systemic risk → `devkit-clean-architecture-quality`; readability/SRP → `devkit-clean-code-guardian`.
5. **✅ Consolidated Governance Documentation** — Updated `instructions/devkit-global.instructions.md` with naming requirements and routing policy.

---

## 📋 Changes by Category

### **A. Renamed Artifacts with Devkit Prefix**

#### Agents (7 files)
| Old Name | New Name | Location |
|----------|----------|----------|
| `android-expert-pattern` | `devkit-android-expert-pattern` | `agents/android/compose/` |
| `android-compose-expert` | `devkit-android-compose-expert` | `agents/android/compose/` |
| `ios-swiftui-expert` | `devkit-ios-swiftui-expert` | `agents/ios/swiftui/` |
| `python-expert-pattern` | `devkit-python-expert-pattern` | `agents/backend/python/` |

#### Skills (1 directory)
| Old Path | New Path |
|----------|----------|
| `skills/backend/python/python-patterns/` | `skills/backend/python/devkit-python-patterns/` |

#### Prompts (2 files)
| Old Name | New Name | Location |
|----------|----------|----------|
| `android-expert-patterns.prompt.md` | `devkit-android-expert-patterns.prompt.md` | `prompts/android/compose/` |
| `python-expert-patterns.prompt.md` | `devkit-python-expert-patterns.prompt.md` | `prompts/backend/python/` |

---

### **B. New Global Clean Architecture Quality Skill**

**Path:** `skills/global/devkit-clean-architecture-quality/`

**Purpose:** Canonical multi-language CA quality audit framework (adapted from Bankinter reference).

**Content:**
- **SKILL.md** — Trigger definitions, non-triggers, execution rules, output format
- **references/overview.md** — Mermaid diagram showing architecture quality audit flow
- **Rule files** (16 total, 4 severity levels):
  - `java-rules-{critical,high,medium,low}.md`
  - `kotlin-rules-{critical,high,medium,low}.md`
  - `swift-rules-{critical,high,medium,low}.md`
  - `python-rules-{critical,high,medium,low}.md`

**Key Rules Coverage:**
- **CRITICAL:** Layering violations, direct DB access from UI, secret leakage
- **HIGH:** Dependency injection misuse, tight coupling, concurrent access without synchronization
- **MEDIUM:** Incomplete error handling, missing type hints (Python), no nullability annotations (Kotlin)
- **LOW:** Naming convention violations, missing documentation blocks

---

### **C. New Stack-Specific CA Quality Agents/Skills/Prompts**

| Stack | Agent | Skill | Prompt |
|-------|-------|-------|--------|
| Android | `devkit-android-clean-architecture-quality.agent.md` | `skills/android/compose/devkit-android-clean-architecture-quality/` | `devkit-android-clean-architecture-quality-analyze.prompt.md` |
| iOS | `devkit-ios-clean-architecture-quality.agent.md` | `skills/ios/swiftui/devkit-ios-clean-architecture-quality/` | `devkit-ios-clean-architecture-quality-analyze.prompt.md` |
| Python | `devkit-python-clean-architecture-quality.agent.md` | `skills/backend/python/devkit-python-clean-architecture-quality/` | `devkit-python-clean-architecture-quality-analyze.prompt.md` |

**Handoff Logic (Each Agent):**
- If architecture/systemic risk detected → invoke global `devkit-clean-architecture-quality`
- If pure readability/SRP issue → handoff to `devkit-clean-code-guardian`
- If pattern decision needed → handoff to stack-specific expert pattern agent

---

### **D. Updated Project Orchestrators (7 total)**

All updated with mandatory **CA Quality vs Clean-Code Routing Policy**:

1. `agents/android/devkit-android-project-orchestrator.agent.md`
2. `agents/ios/devkit-ios-project-orchestrator.agent.md`
3. `agents/backend/kotlin-ktor/devkit-backend-kotlin-project-orchestrator.agent.md`
4. `agents/backend/python/devkit-backend-python-project-orchestrator.agent.md`
5. `agents/backend/spring-java/devkit-backend-java-project-orchestrator.agent.md`
6. `agents/multiplatform/kmp/devkit-kmp-project-orchestrator.agent.md`
7. `agents/multiplatform/cmp/devkit-cmp-project-orchestrator.agent.md`

**Decision Tree Logic:**
```
Request → Identify scope (architecture/readability/mixed)
  ├─ Architecture risk → devkit-clean-architecture-quality (stack-specific)
  ├─ Readability/SRP → devkit-clean-code-guardian
  └─ Mixed → both (ordered: CA quality first, then clean-code)
```

---

### **E. Deleted Artifacts (Superseded)**

Removed old quality agents/skills/prompts (replaced by new global/stack-specific model):
- `agents/android/compose/android-quality.agent.md`
- `agents/backend/python/python-quality.agent.md`
- `agents/ios/swiftui/ios-quality.agent.md`
- `prompts/android/compose/android-quality-analyze.prompt.md`
- `prompts/backend/python/python-quality-analyze.prompt.md`
- `prompts/ios/swiftui/ios-quality-analyze.prompt.md`
- `skills/android/compose/android-quality/`
- `skills/backend/python/python-quality/`
- `skills/ios/swiftui/ios-quality/`
- `skills/ios/swiftui/swiftui-patterns/`

---

### **F. Updated Internal References**

All handoff targets, skill names, and agent references updated across:
- Expert pattern agents (Android, iOS, Python) — now reference `devkit-<domain>-patterns` skills
- CA quality agents — reference correct skill paths
- Prompts — updated agent targets and skill references
- Orchestrators — include new routing logic with updated agent names

---

### **G. Documentation Updates**

| File | Changes |
|------|---------|
| `instructions/devkit-global.instructions.md` | Added mandatory routing policy, devkit naming requirements, and CA quality vs clean-code decision tree |
| `docs/implementation/user-stories/US-013-PLUS-import-patterns-quality-android-ios-python.md` | Updated artifact paths to reflect new naming and folder structure |
| `docs/implementation/epics.md` | Cross-reference updates for affected US |

---

## ✅ Validation & Quality Checks

### **1. Naming Compliance Audit**
```bash
# Verified: No old naming patterns remain
grep -r "android-expert-pattern\|python-patterns\|ios-swiftui-expert" agents prompts skills --exclude-dir=.git
# Result: 0 matches (except devkit- prefixed versions)
```

### **2. Skill Validation**
```bash
./scripts/devkit-validate-skill.sh
# Results: 4 skills PASSED
#  ✓ devkit-clean-architecture-quality (global)
#  ✓ devkit-android-clean-architecture-quality
#  ✓ devkit-ios-clean-architecture-quality
#  ✓ devkit-python-clean-architecture-quality
```

### **3. Reference Integrity**
- ✅ All handoff targets resolved
- ✅ All skill targets resolved
- ✅ All agent references updated
- ✅ No broken cross-references

---

## 📊 Impact Analysis

### **Repository Governance**
- **Consistency:** 100% devkit naming compliance across all artifact types
- **Discoverability:** Agents/skills now consistently searchable with `devkit-` prefix
- **Maintainability:** Single source of truth for CA quality rules (global skill) + stack-specific customizations

### **Quality Gate Execution**
- **Architecture Reviews:** Routed to stack-specific CA quality agents with mandatory rule validation
- **Readability Issues:** Routed to `devkit-clean-code-guardian` (SRP, naming, function length)
- **Mixed Issues:** Orchestrators handle sequential routing (architecture first, then clean-code)

### **User Stories Affected**
- ✅ **US-013-PLUS:** Import multi-platform quality utilities with devkit naming
- ✅ Related: Android/iOS/Python project orchestrators now enforce governance routing

---

## 🔄 Merge Strategy

- **Target Branch:** `develop`
- **Commit Strategy:** Single atomic commit (80+ files) with comprehensive message
- **Backward Compatibility:** ⚠️ Breaking change (old agent/skill names no longer available) — document migration for any external references

---

## 📝 Related Documentation

- [Bankinter Clean Architecture Quality Reference](docs/implementation/solve/)
- [Devkit Global Instructions](instructions/devkit-global.instructions.md)
- [User Story US-013-PLUS](docs/implementation/user-stories/US-013-PLUS-import-patterns-quality-android-ios-python.md)

---

## ✨ Checklist

- [x] All agents/skills/prompts follow `devkit-` naming convention
- [x] Global CA quality skill created with multi-language rules
- [x] Stack-specific CA quality agents/skills implemented
- [x] All project orchestrators updated with routing policy
- [x] All internal references updated and validated
- [x] Skill validation script passed (4 skills)
- [x] No broken cross-references
- [x] Documentation updated with new governance rules
- [x] No merge conflicts with develop branch

