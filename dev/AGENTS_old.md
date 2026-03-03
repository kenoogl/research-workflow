# AGENTS.md

## Purpose

This repository is designed for AI-assisted research analysis.

It guarantees:

- Experimental reproducibility
- Cognitive traceability (analysis provenance)
- Separation of facts and evaluation

---

# GLOBAL PRINCIPLES

## Source of Truth

- `config.yaml` is ground truth for experiment settings.
- `run_summary.json` contains result summary only.
- `results/` must never be modified by AI.
- Facts must be separated from evaluation.

---

# PROJECT-LOCAL SKILL POLICY

- This project uses local skills under:
  - `.codex/skills/`
- For notes update workflows, prioritize:
  - `.codex/skills/notes-updater/SKILL.md`
- If both global and project-local skills exist, prefer project-local skills.
- Do not use global skill variants unless explicitly requested.
- If project-local skill files are missing or broken:
  - Report it
  - Fall back to AGENTS.md rules

---

# EXPERIMENTAL ANALYSIS MODE (Single Experiment)

## Priority Files

1. `ai_context/intent.md` (if exists)
2. `experiments/<exp>/config.yaml`
3. `results/<exp>/run_summary.json`
4. `logs/<exp>.json`
5. `experiments/<exp>/notes.md` (human thoughts, optional)
6. `results/<exp>/`

## Operating Rules

1. `config.yaml` is the single source of truth.
2. `run_summary.json` contains result summary only.
3. Do NOT infer solver settings from run_summary.
4. When comparing experiments, use run_summary fields.
5. Prioritize objective metrics over human notes.
6. Always distinguish:
   - Facts (metrics)
   - Evaluation (interpretation)

---

# ANALYSIS PROVENANCE MODE

This applies when working inside:`analysis/<ana>/`

Analysis is event-based, not state-based.

Every reasoning step MUST be recorded.

---

## 1. Directory Structure

~~~
analysis/<ana>/
meta.json
discussion.md
events/
inputs_snapshot/ (created when first input is added)
~~~

---

## 2. Event Recording Rules

For every reasoning interaction:

1. Determine next event number:
   - 3-digit zero-padded
   - max(existing) + 1
   - never reuse numbers

2. Save prompt to:
   `events/NNN_prompt.md`

3. Save response to:
   `events/NNN_response.md`

4. Never edit past events.

5. Never delete history.

---

## 3. Input Snapshot Rule

If a new experiment is referenced during analysis:

1. Create `inputs_snapshot/` if it does not exist.
2. Copy into:
   `inputs_snapshot/<exp_name>/`

   - `experiments/<exp_name>/config.yaml`
   - `results/<exp_name>/run_summary.json`

3. Record action as:
   `events/NNN_add_input.md`

4. Update `meta.json`:
   - append experiment name to `experiments` array

Never use symlinks.
Snapshots must be immutable copies.

---

## 4. Discussion Update Rule

`discussion.md` is append-only.

When:

- A session logically ends
- A major conclusion is formed
- The user requests summary

Append:

~~~
## Session N (YYYY-MM-DD)

Include:
### AI Summary
- Facts only

### AI Analysis
- Alignment with objective
- Hypothesis candidates
- Counterarguments
- Minimal next experiment

### Human Notes
- Leave blank unless user provides input
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

- Hidden reasoning traces
- External memory
- Model-specific system prompts

All reasoning that affects conclusions must be recorded in `events/`.

---

## 7. Non-Determinism

LLM outputs are non-deterministic.

Provenance guarantees:

- Inputs seen
- Prompts issued
- Outputs generated

It does NOT guarantee identical future outputs.

---

## 8. Forbidden Actions

Never:

- Modify experimental results
- Rewrite event history
- Skip event recording
- Overwrite discussion content
- Add conclusions without event trace

---

## 9. Fallback Rule

If automatic saving fails:
- Stop
- Report error
- Do not continue silently

---

# AUTO ANALYSIS SESSION RULE
This rule has higher priority than normal exploratory workflow.

## Trigger
If the user intent is to start or continue experiment analysis
(e.g., "分析します", "挙動を分析", "比較したい", "評価したい", "解析開始"),
the agent MUST initialize or attach an analysis session before any analysis work.

Use the following regex to detect analysis-start intent:
`(?i)(分析(を)?(開始|します|したい)?|解析(を)?(開始|します|したい)?|挙動(を)?分析|評価(を)?(開始|します|したい)?|比較(を)?(開始|します|したい)?|review|analy[sz]e|analysis)`

If the user message matches this pattern, treat it as analysis intent and apply this rule.


## Mandatory First Action
1. BEFORE reading/summarizing/interpreting experiment results, MUST run:
   `./bin/new_analysis <topic>`
   (`<topic>` should be short and relevant, e.g. `sor`, `ssor_vs_taylor`)

2. If an active analysis directory already exists and user intent is continuation,
   the agent may attach to that directory instead of creating a new one.
   In that case, agent MUST explicitly state which `analysis/<ana>/` is used.

## Provenance Enforcement
After session initialization/attachment:
1. Save user message to `events/NNN_prompt.md`
2. Save AI reply to `events/NNN_response.md`
3. Record added inputs via `events/NNN_add_input.md` and update `meta.json`
4. Never provide conclusions that are not traceable in `events/`

## Failure Handling
If `new_analysis` (or attach decision) fails or is ambiguous:
1. STOP immediately
2. Report the error/ambiguity
3. Do not continue analysis silently

## Forbidden
- Starting analysis without analysis session initialization/attachment
- Emitting analysis conclusions without event recording


# NOTES UPDATE RULE (generate_notes internal)

When:

~~~
./bin/generate_notes <exp> --llm-internal
~~~

is used, read only:

- `ai_context/intent.md` (if exists)
- `experiments/<exp>/config.yaml`
- `results/<exp>/run_summary.json`

Ensure `experiments/<exp>/notes.md` header matches the experiment name:

- `# Experiment Notes: <exp>`
- Never leave placeholder text like `<exp>`.

Update ONLY`experiments/<exp>/notes.md`:

- `## 1. AI Summary (Facts)`
- `## 2. AI Analysis (Evaluation)`

Never modify:

- `## 3. Human Thoughts (Decision)`

Keep output language Japanese.

If markers are missing or broken:

- Stop

- Report error

- Do not rewrite whole file

  

------

# Code Development Mode

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
