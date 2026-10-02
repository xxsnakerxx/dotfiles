# Working Style

Applies to every project. Project-specific rules live in the project's own AGENTS.md.

## Asking vs. guessing

- Read the official docs before using any library API — never write API shapes from memory
- Never present an assumption as fact. If the codebase can't prove it — API response shapes, which fields arrive on which status, backend behaviour — ask before writing code or comments that depend on it
- This holds for claims about our own code too: a comment may state only what the construct actually enforces, never the failure it feels like it prevents. Before writing "so X can't happen", find the path where X still happens — if it exists, the claim is wrong
- If a fix must ship before the answer arrives: implement the conservative branch, say plainly "unverified — assumed X", and list it as a manual check. Never write an unverified claim into a code comment
- If the same question has been re-examined more than twice without a clear answer, stop and ask — with a short summary of the tradeoff and a recommendation, not an exhaustive survey

## Existing solutions first

- Before deciding to implement something — a helper, a script, a library, a CI step — search the web for an existing ready-made solution (a package, a GitHub Action, a service) and propose it. Hand-rolling what already exists is the most common avoidable work. Build only when nothing fits or a dependency is explicitly unwanted.

## Test-driven development

- For logic that is unit-testable (pure functions, formatters, state transitions), write the failing test before the implementation and make it pass — not tests written after the fact to match code
- Where a red test adds nothing (wiring, markup, one-off scripts), skip the cycle; "when possible" is the bar, not an obligation

## Verification

- The user walks the UI himself to verify visual changes. Never claim a visual change is verified, and never substitute a screenshot pass for it
- Instead, after each shippable chunk, hand over a checklist: which URLs/params to open, which screens to walk, what to look at — phrased so "correct" vs "broken" is distinguishable without reading the diff. Then stop and wait
- Plan commits so each one ends at a hand-checkable state

## Blocked commands

- If a command is denied by the sandbox or needs something unavailable (docker daemon, a login, a network host), don't silently downgrade to reasoning or drop the check. Hand the user a copy-pasteable `! <command>` and ask for the output
- Say what the expected output looks like, so a wrong result is recognisable without reading the code
- Until that output arrives, the thing stays "unverified" — never report it as verified

## Respecting edits

- Never restore code the user removed, even if it looks like an omission — treat every user edit as intentional
- Ask only if the removal causes a hard type error with no obvious fix

## Commit messages

- After any turn that changed files (code or docs), print a short suggested commit message automatically — don't wait to be asked
- One-line summary, short body only if the motivation is non-obvious. Match the repo's commit style
- Multiple independent changesets pending (e.g. staged code vs. untracked docs) → one message per changeset, not a merged one
- Never run `git commit` unless explicitly asked; just propose the text

## Git worktrees

- Worktrees belong to `worktrunk`, binary `wt` — `git worktree add` stays out of it. Syntax: `wt --help`, `wt <command> --help`
- `wt` puts a worktree beside the repo, outside the bash sandbox, so creating one or working in it is the user's move. Hand over the command: `! wt switch --create <branch> -x <agent> -- '<prompt>'` starts a session in the new branch
- Per-worktree setup — dependencies, gitignored env files, codegen — belongs in a `pre-start` hook in the project's `.config/wt.toml`

## Feature → PR workflow

Default pipeline for a feature branch, unless the task says otherwise:

1. Clarify only if fuzzy: grilling (decision), prototype (UI/logic), research (new lib/API).
2. Write with ponytail ON — minimal code, no speculative abstraction. Frontend:
   keep modern-web-guidance + the stack's best-practices skill active (they govern
   correctness, ponytail governs size).
3. Clean: /simplify (Claude Code) — one pass, not several.
4. Gate: code-review — Standards + Spec.
5. Draft: create-pr.
6. Iterate: review-fixes on review comments.

Reach for these only on their trigger, not per-PR: diagnosing-bugs (broken),
resolving-merge-conflicts (conflict), improve-codebase-architecture / codebase-design
(periodic deepening), to-spec / to-tickets / wayfinder (multi-session epics).

ponytail is a write-time mode, not a review step — its job is to make steps 3–4 cheaper.

# graphify

- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
  When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

When the project has `graphify-out/graph.json`, the graph is the first lookup for structural questions — before grep or an Explore agent:

- Impact before a refactor or a signature change → `graphify affected "<symbol>"`
- Whether two modules are linked → `graphify path "<A>" "<B>"`
- Orientation in an unfamiliar area → `graphify query "<terms>" --context call`, then read only the 1–2 files it points at
- The graph is a map, not the behaviour: values, conditions and reasons come from reading the code. Component script blocks (`.svelte`, `.vue`) can be missing from it — a symbol it can't find there still gets a grep
- Freshness first: the report's "Built from commit" against `git rev-parse HEAD`; on a mismatch run `graphify update .` (AST only, no tokens)
