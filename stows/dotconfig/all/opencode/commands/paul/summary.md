---
name: paul:phase-summary
description: Display all phases by ID with plans and status in a readable table
argument-hint:
allowed-tools: [Read]
---

<objective>
Display a clean, readable phase summary table showing all phases by ID (01–09) with their plans and status. Read-only reporting command — no state changes.
</objective>

<execution_context>
</execution_context>

<context>
@.paul/ROADMAP.md
@.paul/STATE.md
@.paul/PROJECT.md
</context>

<process>

<step name="read_sources" priority="first">
Read the three state files:
1. ROADMAP.md — completed milestones (phase tables), current milestone phases table, phase details sections, execution order
2. STATE.md — current position (milestone, phase, plan), loop position markers (PLAN/APPLY/UNIFY), last activity, next action, decisions table
3. PROJECT.md — project name/reference (if exists)
</step>

<step name="build_phase_list">
Construct ordered list of ALL phases from v0.1 through current:

**From completed milestones (ROADMAP.md "Completed Milestones" sections):**
- Extract each milestone's phase table
- Phase IDs may be simple (1, 2, 3) or with suffixes (3b)
- Include plans and completion dates

**From current milestone (ROADMAP.md "Current Milestone" → Phases table):**
- Extract phase number, name, plans, status, completed date
- Note execution order if specified in "Phase Detail" or "Execution order" sections

**From STATE.md "Current Position" / "Loop Position":**
- Current phase and plan
- Loop position markers (✓/●/○ for PLAN/APPLY/UNIFY)
- Per-plan status details
</step>

<step name="render_summary">
Output exactly this format:

```
════════════════════════════════════════
PAUL PHASE SUMMARY — {{project_name}}
════════════════════════════════════════

{{milestone_progress_bars}}

All Phases by ID:
{{phase_table}}

Current Loop:
{{loop_position_diagram}}

Execution order: {{execution_order}}

────────────────────────────────────────
▶ NEXT: {{next_action_suggestion}}
────────────────────────────────────────

Type "yes" to proceed, or provide context for a different suggestion.
```

**Milestone progress bars:**
- Completed: `[████████████] 100% ✓ CLOSED YYYY-MM-DD`
- In progress: `[████░░░░░░] 44% — Phase X of Y`
- Use █ for complete, ░ for pending (12 chars total)

**Phase table (markdown):**
| Phase | Name | Plans | Status | Completed |
|-------|------|-------|--------|-----------|
- Sub-plans as indented rows (empty Phase cell, indented Name)
- Status icons: ✅ Complete, 🔄 In progress, 📋 Planned, ✅ CLOSED (to baseline)

**Loop position diagram:**
```
PLAN ──▶ APPLY ──▶ UNIFY
  ✓        ✓        ✓     [Phase 8: 08-01 COMPLETE]

  ✓        ✓        ✓     [Phase 9: 09-01 COMPLETE]

  ✓        ○        ○     [Phase 9: 09-05 PLAN written — APPLY Task 0 next]
```
- One line per plan in current loop (from STATE.md "Loop Position" section)
- ✓ = complete, ● = in progress, ○ = pending

**Next action suggestion:**
Use routing logic from `/paul:progress`:
- Check STATE.md loop position + audit flags
- Single action only (see progress.md routing table)
</step>

</process>

<success_criteria>
- [ ] All phases from v0.1 to current displayed in ID order
- [ ] Milestone progress bars shown
- [ ] Phase table with plans and status
- [ ] Current loop position with PLAN/APPLY/UNIFY markers
- [ ] Single next action suggested
- [ ] Execution order shown
</success_criteria>

<error_handling>
**No ROADMAP.md:**
```
No ROADMAP.md found. Run /paul:init or /paul:milestone first.
```

**No STATE.md:**
```
No STATE.md found. Phase summary limited to ROADMAP.md data only.
```

**Malformed ROADMAP.md:**
```
Could not parse ROADMAP.md — check format.
Expected: phase table under "## Current Milestone" or "### Phase N"
```

**No active milestone:**
```
No active milestone in ROADMAP.md.
Showing completed milestones only.
```
</error_handling>
