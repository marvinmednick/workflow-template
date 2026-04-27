# DESIGN.md

Architecture and design reference. Read before implementing any new feature or modifying core patterns. Keep this file current — update it when patterns change, not just when adding new ones.

---

## Overview

[One paragraph: what this project does, who uses it, and the primary tech stack.]

---

## Architecture

[High-level description or diagram of how the system is structured. Example:
- Frontend: React Native (Expo) — iOS, Android, Web
- Backend: Supabase (PostgreSQL + Realtime + Auth)
- State: React Query for server state, React Context for session state]

---

## Directory Layout

[Key directories and what they contain. Focus on the non-obvious ones — skip anything self-explanatory from the name alone.]

---

## Data Model

[Key tables, their purpose, and important relationships. Include constraints that affect how the app behaves (e.g. soft-delete patterns, multi-tenancy scoping, nullable foreign keys).]

---

## Key Patterns

[Core patterns that cut across many features. Document each with: what it is, why it exists, and how to use it correctly. Examples:

### Multi-Tenancy / Scoping
[How user data is isolated — RLS policies, a tenant_id column, etc.]

### Authentication Flow
[How auth works, what happens after sign-in, session persistence]

### Real-Time / Subscriptions
[If applicable: how live updates flow to the client]

### Optimistic Updates / Undo
[If applicable: how mutations and rollbacks are handled]
]

---

## External Services

[APIs and third-party services the app depends on, plus required environment variables.]

| Service | Purpose | Env var |
|---------|---------|---------|
| [Service] | [What it does] | `[ENV_VAR_NAME]` |

---

## Design Decisions Log

[Brief record of significant past decisions — what was decided and why. This prevents re-litigating settled questions. New decisions are added here via `/design-review`.]

| Decision | Rationale | Date |
|----------|-----------|------|
| [Decision] | [Why] | [YYYY-MM] |
