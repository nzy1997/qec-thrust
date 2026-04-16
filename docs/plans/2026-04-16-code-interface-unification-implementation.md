# Code Interface Unification Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Align `toric-code` and `surface-code` with the color-code object API model, and apply a lighter object-style consistency pass to `steane-code`.

**Architecture:** Reuse the same interaction style introduced for `color-code-2d(...)`: constructors return reusable geometry objects, drawing becomes an explicit `draw-background()` call, and annotation uses stable helper methods instead of string-built names. Keep the shared core protocol small, then add toric- and surface-specific extensions only where the geometry actually needs them; do not force `steane-code` into a heavyweight patch schema.

**Tech Stack:** Typst package code in [`lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ), CeTZ drawing primitives, example-based red/green verification via `typst compile`, repository smoke checks via `make`, and text cleanup with `rg`.

---

### Task 1: Convert `toric-code` to an Object Constructor

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/toric1.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/toric1.typ)

**Step 1: Write the failing example migration**

Change [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/toric1.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/toric1.typ) from direct drawing:

```typ
toric-code((0, 0), m, n, size: size, circle-radius: circle-radius)
```

to object usage:

```typ
#let code = toric-code((0, 0), m, n, size: size, circle-radius: circle-radius)
(code.draw-background)()
content((code.qubit-anchor)(("vertical", i, j)), [...])
```

Do not migrate the old stabilizer helpers yet in this task. Only force the constructor to become an object and make qubit anchors explicit.

**Step 2: Run the migrated example to verify it fails**

Run:

```bash
typst compile examples/toric1.typ --root=. --format=png
```

Expected: FAIL because `toric-code(...)` still draws directly and does not return `draw-background` or `qubit-anchor`.

**Step 3: Implement the minimal toric object**

In [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ):

- preserve the current toric visual output,
- make `toric-code(...)` return an object,
- expose at least:

```typ
(
  params: (...),
  qubits: (...),
  draw-background: () => {...},
  qubit-anchor: id => ...,
  highlight-qubit: (id, ..style) => {...},
)
```

- give toric qubits stable public ids, for example:

```typ
("vertical", i, j)
("horizontal", i, j)
```

and normalize them internally into deterministic string ids.

**Step 4: Run the example to verify it passes**

Run:

```bash
typst compile examples/toric1.typ --root=. --format=png
```

Expected: PASS, with the same lattice rendered through `code.draw-background()` and labels attached through `code.qubit-anchor(...)`.

**Step 5: Commit**

```bash
git add lib.typ examples/toric1.typ
git commit -m "Refactor toric code to object API scaffold"
```

### Task 2: Pull Toric Stabilizer Helpers into the Toric Object

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/toric1.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/toric1.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/toric2.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/toric2.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/README.md`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/README.md)

**Step 1: Write the failing example migration**

Replace standalone calls in [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/toric1.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/toric1.typ):

```typ
plaquette-code-label(...)
vertex-code-label(...)
```

with object-driven helpers, for example:

```typ
(code.highlight-plaquette)((2, 0), ...)
(code.highlight-vertex)((3, 2), ...)
```

and remove direct dependence on the old helper functions from the example.

**Step 2: Run the example to verify it fails**

Run:

```bash
typst compile examples/toric1.typ --root=. --format=png
```

Expected: FAIL because the toric object does not yet expose stabilizer-region helpers.

**Step 3: Implement toric stabilizer geometry and helpers**

In [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ):

- add explicit toric stabilizer records for plaquettes and vertices,
- expose stable ids for each stabilizer family,
- expose at least:

```typ
plaquettes
vertices
plaquette-anchor(id)
vertex-anchor(id)
highlight-plaquette(id, ...)
highlight-vertex(id, ...)
```

- implement these helpers by reusing the toric geometry object rather than the old standalone helper math,
- keep any legacy standalone helpers only if needed temporarily for compatibility, but stop using them in examples.

**Step 4: Run toric examples to verify they pass**

Run:

```bash
typst compile examples/toric1.typ --root=. --format=png
typst compile examples/toric2.typ --root=. --format=png
```

Expected: PASS, with `toric1` no longer depending on `plaquette-code-label(...)` or `vertex-code-label(...)` as external geometry owners.

**Step 5: Commit**

```bash
git add lib.typ examples/toric1.typ examples/toric2.typ README.md
git commit -m "Move toric stabilizer helpers into toric object API"
```

### Task 3: Convert `surface-code` to the Shared Object-API Style

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/surface.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/surface.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/README.md`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/README.md)

**Step 1: Write the failing example migration**

Change [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/surface.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/surface.typ) from:

```typ
surface-code((0, 0), size: 1.5, n, n, name: "surface1")
content((rel: (0.3, 0.3), to: "surface1-0-0"), [...])
```

to:

```typ
#let code = surface-code((0, 0), n, n, size: 1.5, name: "surface1")
(code.draw-background)()
content((rel: (0.3, 0.3), to: (code.qubit-anchor)((0, 0))), [...])
```

**Step 2: Run the migrated example to verify it fails**

Run:

```bash
typst compile examples/surface.typ --root=. --format=png
```

Expected: FAIL because `surface-code(...)` still draws directly and does not expose object helpers.

**Step 3: Implement the minimal surface object**

In [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ):

- preserve the current visual output and boundary-bulge behavior,
- return an object with at least:

```typ
(
  params: (...),
  qubits: (...),
  draw-background: () => {...},
  qubit-anchor: id => ...,
  highlight-qubit: (id, ..style) => {...},
)
```

- if interior plaquette records are easy to expose cleanly, add them now; if not, defer them and keep this first pass minimal.

**Step 4: Run the surface example to verify it passes**

Run:

```bash
typst compile examples/surface.typ --root=. --format=png
```

Expected: PASS, with explicit object construction and qubit-anchor usage.

**Step 5: Commit**

```bash
git add lib.typ examples/surface.typ README.md
git commit -m "Convert surface code to object-style API"
```

### Task 4: Apply a Lightweight Consistency Pass to `steane-code`

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/steane.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/steane.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/README.md`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/README.md)

**Step 1: Write the failing example migration**

Change [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/steane.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/steane.typ) from:

```typ
steane-code((0, 0), size: 3)
content((rel: (0, -0.3), to: "steane-1"), [...])
```

to:

```typ
#let code = steane-code((0, 0), size: 3)
(code.draw-background)()
content((rel: (0, -0.3), to: (code.qubit-anchor)(1)), [...])
```

Do not require patch-style fields such as `shape`, `tiling`, or `boundaries`.

**Step 2: Run the migrated example to verify it fails**

Run:

```bash
typst compile examples/steane.typ --root=. --format=png
```

Expected: FAIL because `steane-code(...)` still draws directly and exposes only implicit names.

**Step 3: Implement the light object wrapper**

In [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ):

- keep `steane-code` lightweight,
- return a small object with:

```typ
(
  params: (...),
  qubits: (...),
  regions: (...),
  draw-background: () => {...},
  qubit-anchor: id => ...,
  highlight-qubit: (id, ..style) => {...},
)
```

- do not add artificial patch metadata that does not naturally belong to the Steane layout.

**Step 4: Run the Steane example to verify it passes**

Run:

```bash
typst compile examples/steane.typ --root=. --format=png
```

Expected: PASS, with no string-built anchor names in the example.

**Step 5: Commit**

```bash
git add lib.typ examples/steane.typ README.md
git commit -m "Apply lightweight object API to Steane code"
```

### Task 5: Repository Cleanup and Verification

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/README.md`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/README.md)
- Modify: any example still showing the old draw-first style

**Step 1: Search for remaining draw-first usage in live docs and examples**

Run:

```bash
rg -n 'surface-code\\(|toric-code\\(|steane-code\\(|plaquette-code-label\\(|vertex-code-label\\(' README.md examples lib.typ -S
```

Expected: matches only in intended compatibility code paths before cleanup.

**Step 2: Update docs and examples**

- make README examples object-style for toric, surface, and steane,
- remove documentation that treats external toric helpers as the main public API,
- ensure example code demonstrates explicit construction and `draw-background()`.

**Step 3: Run full verification**

Run:

```bash
typst compile examples/toric1.typ --root=. --format=png
typst compile examples/toric2.typ --root=. --format=png
typst compile examples/surface.typ --root=. --format=png
typst compile examples/steane.typ --root=. --format=png
typst compile examples/color_code_666.typ --root=. --format=png
typst compile examples/color_code_488.typ --root=. --format=png
typst compile examples/color_code_4612.typ --root=. --format=png
git diff --check
make
```

Expected: PASS for all examples and repository smoke build.

**Step 4: Final cleanup search**

Run:

```bash
rg -n 'plaquette-code-label\\(|vertex-code-label\\(' README.md examples -S
```

Expected: no matches in public examples or README unless an explicit compatibility note is intentionally kept.

**Step 5: Commit**

```bash
git add lib.typ README.md examples
git commit -m "Unify patch-style code interfaces"
```
