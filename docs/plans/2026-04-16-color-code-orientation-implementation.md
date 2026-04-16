# Color Code Orientation Unification Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace `hex-orientation` with a unified breaking-change `orientation` API and make `4.8.8` support both flat and pointy canonical geometry without outer `#rotate(...)`.

**Architecture:** Keep `color-code-2d(...)` as the single public constructor, rename orientation plumbing across render and canonical builder layers, and extend the `4.8.8` canonical generator so orientation selects the actual embedding rather than a post-render transform. Use existing Typst examples as smoke tests and add a small `4.8.8` example migration that exercises both orientations directly.

**Tech Stack:** Typst package code in [`lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ), CeTZ drawing primitives, example-based verification via `typst compile`, `make`, and repository text search with `rg`.

---

### Task 1: Rename the Public Orientation API

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666_panels.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666_panels.typ)

**Step 1: Write the failing API migration**

Rename current `6.6.6` example call sites from:

```typ
hex-orientation: "pointy"
```

to:

```typ
orientation: "pointy"
```

**Step 2: Run the example to verify it fails**

Run:

```bash
typst compile examples/color_code_666.typ --root=. --format=png
```

Expected: FAIL because `color-code-2d(...)` and internal helpers still accept `hex-orientation`.

**Step 3: Implement the minimal rename**

In [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ):

- rename all public/internal parameter names from `hex-orientation` to `orientation`,
- rename validation messages,
- propagate the renamed field through `params`, canonical builders, render helpers, and returned metadata,
- keep `6.6.6` geometry behavior unchanged.

**Step 4: Run the migrated examples to verify they pass**

Run:

```bash
typst compile examples/color_code_666.typ --root=. --format=png
typst compile examples/color_code_666_panels.typ --root=. --format=png
```

Expected: PASS with no remaining `hex-orientation` use in `6.6.6` examples.

### Task 2: Make `4.8.8` Orientation a Geometry-Level Choice

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488_panels.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488_panels.typ)

**Step 1: Write the failing `4.8.8` example migration**

Replace outer `#rotate(...)` usage in [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488.typ) with direct:

```typ
orientation: "flat"
orientation: "pointy"
```

calls.

**Step 2: Run the example to verify it fails or renders with the wrong geometry**

Run:

```bash
typst compile examples/color_code_488.typ --root=. --format=png
```

Expected: FAIL, or render only one orientation because `4.8.8` canonical geometry is still hard-coded.

**Step 3: Implement orientation-aware `4.8.8` canonical geometry**

In [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ):

- add `orientation: "flat" | "pointy"` to `color-code-488-canonical(...)`,
- keep topology shared between the two orientations,
- generate square/octagon centers, local vertex offsets, and basis vectors from the selected orientation,
- make the returned basis include `orientation`,
- ensure the rectangular patch boundary remains rectangular for both orientations,
- route `color-code-2d(...)` through the selected `4.8.8` embedding.

**Step 4: Run the migrated `4.8.8` examples to verify they pass**

Run:

```bash
typst compile examples/color_code_488.typ --root=. --format=png
typst compile examples/color_code_488_panels.typ --root=. --format=png
```

Expected: PASS, with `examples/color_code_488.typ` containing no outer `#rotate(...)`, and diagonal helpers still rendering correctly when they request `orientation: "pointy"`.

### Task 3: Verify Breaking-Change Cleanup

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_4612.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_4612.typ)
- Modify: any remaining orientation call sites found by search

**Step 1: Search for remaining old API usage**

Run:

```bash
rg -n 'hex-orientation|#rotate\\(' lib.typ examples docs -S
```

Expected: Only intentional mention of `hex-orientation` in the design/history docs before cleanup.

**Step 2: Replace remaining live call sites**

Update any remaining code examples to use `orientation:` and remove obsolete `#rotate(...)`-based `4.8.8` presentation.

**Step 3: Run verification**

Run:

```bash
typst compile examples/color_code_666.typ --root=. --format=png
typst compile examples/color_code_666_panels.typ --root=. --format=png
typst compile examples/color_code_488.typ --root=. --format=png
typst compile examples/color_code_488_panels.typ --root=. --format=png
typst compile examples/color_code_4612.typ --root=. --format=png
git diff --check
make
```

Expected: PASS for all Typst examples and repository smoke build.

**Step 4: Final regression search**

Run:

```bash
rg -n 'hex-orientation' lib.typ examples -S
```

Expected: no matches.
