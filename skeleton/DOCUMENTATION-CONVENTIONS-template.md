# Documentation Conventions

How the architecture set is organised, and how a document is changed while the work changing it is
still open.

> **Template note — delete this block once customized.** Copy to `architecture/01-documentation-conventions.md`
> and link it from your architecture index. Add anything project-specific (file-numbering scheme,
> which documents exist) to the index rather than here. The rules below are the workflow's, and
> `/spec`, `/review-impl` and `/complete` enforce them.

---

## What the architecture set is for

`architecture/` describes **how the application works** — its current state, in the present tense. It
is the reader's documentation: someone who wants to know what the system does reads here.

`docs/design/` decides **what to build and why**. Rationale, alternatives, open questions and
forward-looking material live there and do not move into `architecture/`.

The two are separated by *kind*, not by maturity. A design doc keeps its decisions log forever; what
migrates to `architecture/` is the description of the mechanism those decisions produced.

---

## Keeping the set current

An ordinary feature does not migrate anything. It designs in `docs/design/`, and the mechanism it
produced lands in `architecture/` when it ships, so the set describes the running system at every
commit.

The workflow enforces this at three points, each a hard gate:

| command | mechanism |
|---|---|
| `/spec` | a `### Doc Updates` section naming each architecture doc the feature will change — `None.` if none |
| `/review-impl` | a `## Doc Updates` section in the review ledger; `Status: Passed` cannot be set without it |
| `/complete` | Step 3.5 applies them. No issue may be filed for a doc gap — apply now or block shipping |

---

## Forking a document under open work

A document being changed by an open feature or issue is **forked** for the life of that work.

| file | role |
|---|---|
| `<name>.md` | shipped truth — what the system does today |
| `<name>_<ID>.md` | the fork — the in-design version, and the only edit surface for what it covers |

`<ID>` is `F<n>` for a feature or `I<n>` for an issue, using the GitHub number.

**A fork's name is its base's name plus the ID.** The name is what says which document it forks, so it
is derived, never chosen. A fork whose content will eventually want a different name is renamed at the
merge, not before.

**A spec's and a review ledger's Doc Updates name the fork**, not the base, whenever one is open. An
update written against `<name>.md` while `<name>_<ID>.md` exists edits shipped truth and is lost at
the merge.

The fork is merged back into `<name>.md` and deleted at `/complete`, staying retrievable from the
merge commit. Two forks beside one `<name>.md` means two efforts are changing it concurrently.

A fork whose base does not exist yet is a new document. It has no base to merge against, and at
`/complete` it simply becomes `<name>.md`.

Where a merge **replaces** a document rather than extending it, the replaced document is deleted in
the same step. A retired document left in place describes a system that no longer runs, and nothing
in the file says so.

### Two-level forks

A feature large enough to be built incrementally holds its fork open across many pieces of work, and
those pieces need somewhere to make their own changes. A second level says where:

```
<name>.md                shipped truth
<name>_F<a>.md           the new master — F<a>'s in-progress replacement
<name>_F<a>_F<b>.md      F<b>'s change to that new master
```

Rules:

- **Two levels, never three.** Work that would need a third level waits, or is folded into the
  second-level fork it would have branched from.
- **The innermost open fork is the edit surface** for the material it covers. While
  `<name>_F<a>_F<b>.md` is open, `<name>_F<a>.md` is not edited for that material.
- **Merges run inward-out.** `<name>_F<a>_F<b>.md` merges into `<name>_F<a>.md` at F\<b\>'s
  `/complete`; `<name>_F<a>.md` merges into `<name>.md` at F\<a\>'s.
- **An inner fork outliving its outer re-bases** onto whatever the outer merged into, and the banner
  is updated to say so.

### The fork banner

Every fork opens with a blockquote stating four things:

1. **That it is in design**, naming the issue or feature.
2. **Which fork it is**, and what happens to it at `/complete` — including whether a base exists.
3. **Where it was extracted from**, with the source document, section, and the commit it was taken at.
4. **That rationale does not live here**, linking to the design doc that holds it.

---

## Migrating a large design doc into the architecture set

A design doc written before this convention, which has grown to describe a whole subsystem, is moved
into `architecture/` **one unit at a time**, so a description of the working system accumulates
gradually instead of arriving as one large rewrite. The design doc's section becomes a pointer to the
migrated one.

Five rules make that work:

- **One destination document, not one per unit.** A unit is typically a section's worth of material,
  and a file per unit produces documents far smaller than anything else in the set.
- **Migrate mechanism, leave rationale.** What the unit reads, does and writes moves. The decisions
  log, known limitations, open items and future work stay in the design doc.
- **A unit whose design is still moving does not migrate.** Migration is the signal that a mechanism
  has settled.
- **The destination states its own coverage** while partial — which units it owns and which the design
  doc still holds — so a half-migrated document is honest rather than misleading.
- **Final form is decided at `/complete`,** against the material as it actually reads, not planned in
  advance. Splitting one finished document into several is a mechanical cut at heading boundaries;
  merging several into a coherent narrative is a rewrite. Starting from one document keeps both
  outcomes cheap.

Where the migration replaces an existing document, the destination is a fork of **that** document, so
it holds the same position in the reading order and retires it at the merge.

The per-migration specifics — which document, which units in which order, and what the measurements
were — belong to the design doc being migrated, not here.
