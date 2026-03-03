# AGENTS.md

## Purpose

This repository is designed for AI-assisted research and objective-driven analysis.

It guarantees:

- Experimental reproducibility
- Cognitive traceability (analysis provenance)
- Objective-driven evaluation
- Clear separation of facts and interpretation
- Human-final authority over research decisions

This system is not only an experiment manager.
It is a structured thinking environment.

---

# GLOBAL PRINCIPLES

## 1. Source of Truth

- `experiments/<exp>/config.yaml` is the single source of truth for experiment settings.
- `results/<exp>/run_summary.json` contains result summary only.
- `results/` must NEVER be modified by AI.
- `logs/<exp>.json` contains execution provenance.
- Facts must always be separated from evaluation.

AI must not rewrite or reinterpret raw experimental data.

---

## 2. Objective-Driven Research Model

Research is organized around Objectives defined in:

`ai_context/intent.md`

Each Objective MUST contain:

- Claim
- Quantitative Criteria
- Qualitative Criteria
- Comparison Baseline
- Status

Quantitative + Qualitative criteria are both mandatory.

AI must evaluate objectives strictly against these criteria.

---

## 3. Objective Status Lifecycle

Each Objective has a Status:

- exploratory
- active
- partially_validated
- validated
- rejected
- abandoned
- merged

Rules:

- AI may PROPOSE status changes.
- AI must NEVER modify intent.md automatically.
- Human must explicitly update intent.md.
- Status updates require rationale.

---

## 4. Separation of Layers

| Layer        | Meaning              |
| ------------ | -------------------- |
| experiments/ | What was done        |
| results/     | What happened        |
| analysis/    | How we reasoned      |
| intent.md    | What we aim to prove |

These layers must never be mixed.

---

## 5. External Data Handling (Lightweight v0.1)

### Purpose

For experiments that reference external DB/storage/API/datasets, keep enough traceability to answer:

- what was referenced
- under which reference condition
- what values were actually used for computation (minimum)

Full raw-data preservation is NOT required in v0.1.

### Scope

- material/property DBs
- external storage (HPC/S3/etc.)
- external datasets referenced by DOI/URL/path/query

### Design Principles

1. Do not copy raw external data by default.
2. Save references (required for reproducibility context).
3. Save actually-used values in result summary when possible.
4. Keep analysis flow unchanged (read config + run_summary).
5. Keep structure minimal (no mandatory new directory).

### Config Rule (`experiments/<exp>/config.yaml`)

`external_data` MAY be added (recommended):

```yaml
external_data:
  - name: materials_db
    type: database   # database | api | dataset | filesystem
    locator: "material_id=1234"
    version: "v2.1"  # optional
    retrieved_at: "2026-03-03T10:12:00+09:00"  # optional
    note: "optional human-readable memo"
```

Rules:

- `external_data` must be an array.
- `locator` must be a human-readable minimal reference (query/ID/URL/path/DOI).
- `version` and `retrieved_at` are optional.
- Do not embed raw bulk data in config.

### Result Summary Rule (`results/<exp>/run_summary.json`)

`external_data_used` is recommended for values actually used by computation:

```json
"external_data_used": [
  {
    "name": "materials_db",
    "locator": "material_id=1234",
    "values_used": { "elastic_modulus_GPa": 210.5 }
  }
]
```

Rules:

- Prefer values actually consumed by solver/model, not only references.
- Full payload is unnecessary; summary/statistics are acceptable for large value sets.

### Log Rule (`logs/<exp>.json`)

Optional short provenance is allowed (source name, reference time, host context), but avoid duplicate deep details already present in config/run_summary.

### Analysis Rule

No special analysis subsystem is introduced for external data.
AI should evaluate using:

- `config.yaml` `external_data` (reference condition)
- `run_summary.json` `external_data_used` (used values)

### Limitations (v0.1)

Lightweight rule may be insufficient when:

- DB values change for same ID
- API responses are non-deterministic
- raw payload itself determines conclusions

In such cases, treat as exception and consider extra capture (response excerpt/checksum) as future extension.

### AI Review Checklist (Mandatory when external data exists)

1. `external_data` exists in config (reference captured).
2. `external_data_used` exists in run_summary (used values captured).
3. `locator` and `values_used` are not contradictory.
4. Baseline comparison uses aligned external-data conditions.

If violated, report as "needs correction".

---

# PROJECT-LOCAL SKILL POLICY

- Prefer `.codex/skills/`
- If local skill exists, do not use global variants.
- If local skill is broken:
  - Report
  - Fall back to AGENTS.md rules
- For notes update workflows, prioritize:
  - `.codex/skills/notes-updater/SKILL.md`

---

# EXPERIMENTAL ANALYSIS MODE (Single Experiment)

## Priority Files

1. `ai_context/intent.md`
2. `experiments/<exp>/config.yaml`
3. `results/<exp>/run_summary.json`
4. `logs/<exp>.json`
5. `experiments/<exp>/notes.md` (optional human input)

## Operating Rules

1. config.yaml is ground truth.
2. run_summary.json contains results only.
3. Never infer solver configuration from run_summary.
4. Prioritize objective metrics over human commentary.
5. Strictly separate:
   - Facts (numbers)
   - Evaluation (interpretation)

---

## Objective Evaluation Rules

When evaluating:

1. Only evaluate objectives listed in:
   - analysis/<ana>/objective.md
   OR
   - explicitly referenced by user

2. For each objective:

   Provide:

   - Quantitative Evaluation
   - Qualitative Evaluation
   - Baseline Comparison
   - Verdict (Satisfied / Partial / Not satisfied)
   - Proposed Status Update

3. Status update must be a proposal only.

---

# ANALYSIS PROVENANCE MODE

Applies when working inside:

`analysis/<ana>/`

Analysis is EVENT-BASED, not state-based.

Every reasoning step MUST be recorded.

---

## 1. Directory Structure

~~~
analysis/<ana>/
├── meta.json
├── discussion.md
├── events/
└── inputs_snapshot/ (created only when needed)
~~~

---

## 2. Event Recording Rules

For every reasoning interaction:

1. Determine next event number:
   - 3-digit zero padded
   - max(existing) + 1
   - never reuse numbers

2. Save prompt:
   `events/NNN_prompt.md`

3. Save response:
   `events/NNN_response.md`

4. Never edit past events.
5. Never delete history.

---

## 3. Input Snapshot Rule

If new experiment(s) are referenced:

1. Create `inputs_snapshot/` if absent.
2. Copy:

   - `experiments/<exp>/config.yaml`
   - `results/<exp>/run_summary.json`

3. Save:
   `events/NNN_add_input.md`

4. Update `meta.json` experiments array.

Snapshots must be immutable copies.
Never use symlinks.

---

## 4. Discussion Update Rule

`discussion.md` is append-only.

When:

- Session logically ends
- Major conclusion formed
- User requests summary

Append:

~~~
Session N (YYYY-MM-DD)
AI Summary (Facts)

Numbers only

No interpretation

AI Analysis (Evaluation)

For each objective:

OX

Quantitative:
...

Qualitative:
...

Baseline:
...

Verdict:
...

Proposed Status:
...

Human Notes

(leave blank unless user provides)
~~~

Never erase prior sessions.

---

## 5. Objective Handling

Initial objective is written in `discussion.md`.

If updated,

Append:

~~~
## Objective (Updated - DATE)
- Do not delete prior objective.
~~~

---

## 6. Model Independence

Do not rely on:

- Hidden chain-of-thought
- External memory
- Model-specific internal traces

All reasoning must be reconstructible from `events/`.

---

## 7. Non-Determinism Policy

LLMs are non-deterministic.

Provenance guarantees:

- Inputs
- Prompts
- Outputs

It does NOT guarantee identical future outputs.

---

## 8. Forbidden Actions

Never:

- Modify results
- Rewrite event history
- Skip event logging
- Overwrite discussion
- Auto-update intent.md
- Declare objective validated without traceable evaluation

---

## 9. Fallback Rule

If automatic saving fails:

- Stop
- Report error
- Do not continue silently

---

# AUTO ANALYSIS SESSION RULE (High Priority)

- This rule has higher priority than normal exploratory workflow.

  ## Trigger

  If the user intent is to start or continue experiment analysis
  (e.g., "分析します", "挙動を分析", "比較したい", "評価したい", "解析開始"),
  the agent MUST initialize or attach an analysis session before any analysis work.

  Use the following regex to detect analysis-start intent:
  `(?i)(分析(を)?(開始|します|したい)?|解析(を)?(開始|します|したい)?|挙動(を)?分析|評価(を)?(開始|します|したい)?|比較(を)?(開始|します|したい)?|review|analy[sz]e|analysis)`

  If the user message matches this pattern, treat it as analysis intent and apply this rule.


  ## Mandatory First Action

  0. Determine analysis topic name from user prompt (short and relevant, e.g. `sor`, `ssor_vs_taylor`).
     If missing, ask user for the analysis name before initialization.

  1. BEFORE reading/summarizing/interpreting experiment results, MUST run:
     `./bin/new_analysis <topic>`
     (`<topic>` should be the analysis name provided or confirmed from user prompt)

  2. If an active analysis directory already exists and user intent is continuation,
     the agent may attach to that directory instead of creating a new one.
     In that case, agent MUST explicitly state which `analysis/<ana>/` is used.

  ## Provenance Enforcement

  After session initialization/attachment:

  1. Save user message to `events/NNN_prompt.md`
  2. Save AI reply to `events/NNN_response.md`
  3. Record added inputs via prompt-driven workflow only (no dedicated add_input CLI), save `events/NNN_add_input.md`, and update `meta.json`
  4. Never provide conclusions that are not traceable in `events/`

  ## Failure Handling

  If `new_analysis` (or attach decision) fails or is ambiguous:

  1. STOP immediately
  2. Report the error/ambiguity
  3. Do not continue analysis silently

  ## Forbidden

  - Starting analysis without analysis session initialization/attachment
  - Emitting analysis conclusions without event recording

---

# NOTES UPDATE RULE (generate_notes internal)

When:

`./bin/generate_notes <exp> --llm-internal`

Read ONLY:

- `ai_context/intent.md`
- `experiments/<exp>/config.yaml`
- `results/<exp>/run_summary.json`

Update ONLY:

- `experiments/<exp>/notes.md`
  - Section 1: AI Summary (Facts)
  - Section 2: AI Analysis (Evaluation)

Never modify:

- Section 3: Human Thoughts

Language: Japanese.

If structure broken:
- Stop
- Report error
- Do not rewrite whole file

---

# MULTI-OBJECTIVE POLICY

Objectives are flat.
No hierarchy assumed.

An analysis may target multiple objectives.

Do NOT assume one-to-one mapping between experiment and objective.

Only evaluate objectives explicitly referenced.

---

# CODE DEVELOPMENT MODE

## Project Structure & Module Organization

This repository is currently a Kiro-style, spec-driven workspace. Most content is documentation rather than application code.

- `.kiro/specs/<feature>/`: Feature specs (e.g., `.kiro/specs/adpoisson/requirements.md`, `spec.json`).
- `.kiro/settings/`: Kiro templates and rules used to generate or validate specs.
- `.gemini/commands/kiro/`: CLI command definitions for spec workflows.
- `README.md`, `GEMINI.md`: High-level project context and process notes.

There is no application source tree or tests directory yet. If you add code, create a clear top-level folder (for example, `src/` and `tests/`) and document it here.

## Build, Test, and Development Commands

No build/test scripts or package manifests are present (no `package.json`, `pyproject.toml`, `go.mod`, etc.). If you introduce a build or runtime, document the exact commands and expected outputs here and in `README.md`.

## Coding Style & Naming Conventions

- Documentation is Markdown. Keep headings consistent and concise.
- Spec feature folders are lowercase and short (e.g., `adpoisson`).
- For spec documents, follow the language defined in the feature’s `spec.json` (currently `"language": "ja"`).

## Testing Guidelines

No testing framework is configured. If you add executable code, add a corresponding test setup and document:

- test directory location
- test naming conventions
- the command to run tests

## Commit & Pull Request Guidelines

Git history contains only `"first commit"`, so no established commit convention exists. Use short, imperative messages and include scope when helpful (e.g., `spec: add adpoisson requirements`).
For pull requests, include:

- a brief summary of changes
- the spec path being updated (for example, `.kiro/specs/adpoisson/requirements.md`)
- any required phase approvals (requirements → design → tasks)

## Source of Truth

- src/ contains implementation.
- tests/ define correctness.
- config.yaml defines runtime parameters.

## Rules

- Do not modify config structure unless requested.
- Preserve reproducibility.
- Avoid breaking run_exp interface.
- Suggest refactoring only when complexity increases.


## Process Notes

Follow the Kiro workflow described in `GEMINI.md`. Specs move through requirements, design, and tasks before implementation.

## Execution Policy

- Do not create files, edit files, or run commands when the user asks only to "show", "review", or "confirm".

---

# When Both Apply

- Never alter experimental results to fix code.
- Code fixes require new experiment runs.
