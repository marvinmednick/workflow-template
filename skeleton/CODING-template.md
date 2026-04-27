# CODING.md

Read this file before writing any code. It defines mandatory patterns, tech stack, and coding conventions for this project. All implementors (Gemini, Codex, aider) read this file at the start of every session.

---

## Tech Stack

[List your languages, frameworks, and key libraries. Example:
- TypeScript + React Native (Expo) for the frontend
- Supabase (PostgreSQL + Realtime) for the backend
- React Query for server state management
- Jest for testing]

---

## Directory Layout

[Describe the key directories and what lives in each. Example:
- `src/` — application source
- `src/api/` — data fetching and mutations
- `src/components/` — UI components
- `src/lib/` — shared utilities
- `tests/` — test files]

---

## Mandatory Coding Patterns

These patterns are checked during every `/review-impl`. Missing any of them is a blocking review failure.

### [Pattern 1 Name]

[Describe the pattern, when it applies, and what correct usage looks like. Example:
**Multi-tenancy guard:** Every mutation that writes to tenant-scoped tables must check `tenantId` early and throw if null.]

### [Pattern 2 Name]

[Add as many mandatory patterns as your project requires.]

---

## Naming Conventions

[File naming, function naming, variable naming rules. Example:
- React components: PascalCase (`MyComponent.tsx`)
- Hooks: camelCase with `use` prefix (`useMyHook.ts`)
- Test files: `<component>-test.tsx` co-located with source]

---

## Testing Conventions

[Where tests live, what test setup is required, any mandatory mocks or wrappers. Example:
- Tests live in `__tests__/` directories next to the code they test
- All component tests must wrap with `<QueryClientProvider>` and `<AuthProvider>`
- Never skip a test — report it as a blocker instead]

---

## Mandatory Test Cases

[List test cases that must appear in every spec's Tests to Write section when the relevant pattern applies. Example:
- If the feature mutates data: include a test that verifies the tenant guard fires when tenantId is null
- If the feature has async state: include a loading and error state test]

---

## Key Patterns

[Additional important patterns that don't rise to "mandatory" level but implementors should follow. Add sections as your project develops them.]

---

## Off-Limits Without a Spec Section

[Patterns or files that must not be changed without an explicit spec section. Example:
- Do not modify the root provider tree without a spec
- Do not add columns to the database without a migration file in the spec]
