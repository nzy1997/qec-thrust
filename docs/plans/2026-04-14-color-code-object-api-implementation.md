# Color Code Object API Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor `color-code-2d(...)` into a breaking-change object API with stable face/qubit anchors, add `6.6.6` six-boundary hex patches, and make `4.8.8` use the 45-degree reference geometry.

**Architecture:** Keep `color-code-2d(...)` as the single public constructor, but move all color-code generation behind a shared builder pattern that returns canonical `faces`, `qubits`, `boundaries`, and thin render helpers. Implement tiling-specific geometry in isolated builder blocks inside [`lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ), but normalize them into one returned object shape so examples and README only need one usage model.

**Tech Stack:** Typst package code in [`lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ), CeTZ drawing primitives, example-based smoke tests via `typst compile` and `make`.

---

### Task 1: Establish the Object API Skeleton

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666.typ)

**Step 1: Write the failing example migration**

Change [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666.typ) from direct drawing:

```typ
color-code-2d(...)
```

to object usage:

```typ
#let code = color-code-2d(...)
#canvas({
  (code.draw-background)(show-qubits: true)
})
```

**Step 2: Run the migrated example to verify it fails**

Run:

```bash
typst compile examples/color_code_666.typ --root=. --format=png
```

Expected: FAIL because `color-code-2d(...)` still returns draw content instead of an object with `draw-background`.

**Step 3: Implement the minimal object scaffold**

In [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ):

- add a small shared object shape for color codes,
- move current `6.6.6 rect` rendering into a `draw-background` helper,
- return at least:

```typ
(
  tiling: tiling,
  shape: shape,
  params: (...),
  faces: (:),
  qubits: (:),
  boundaries: (:),
  basis: (:),
  face-anchor: id => ...,
  qubit-anchor: id => ...,
  draw-background: (..args) => {...},
  highlight-face: (id, ..style) => {...},
  highlight-qubit: (id, ..style) => {...},
)
```

Do not implement every geometry detail yet. Just make the object contract real and keep the old visual output for `6.6.6 rect`.

**Step 4: Run the migrated example to verify it passes**

Run:

```bash
typst compile examples/color_code_666.typ --root=. --format=png
```

Expected: PASS and render the same `6.6.6 rect` example through object usage.

**Step 5: Commit**

```bash
git add lib.typ examples/color_code_666.typ
git commit -m "Refactor color-code-2d to object API skeleton"
```

### Task 2: Add Canonical Face and Qubit Records for Existing `6.6.6` Shapes

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666.typ)

**Step 1: Add a failing anchor-usage probe to the example**

Extend [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666.typ) so it references one face anchor and one qubit anchor:

```typ
content((rel: (0, 0.5), to: (code.face-anchor)("...")), [face])
content((rel: (0.3, 0.3), to: (code.qubit-anchor)("...")), [q])
```

Use temporary placeholder ids chosen from the future deterministic scheme.

**Step 2: Run the example to verify it fails**

Run:

```bash
typst compile examples/color_code_666.typ --root=. --format=png
```

Expected: FAIL because the object exists, but canonical ids and anchor helpers are not yet wired to stable face/qubit records.

**Step 3: Implement canonical geometry storage and anchor helpers**

In [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ):

- introduce shared helpers to register faces and globally deduplicated qubits,
- store for each face:

```typ
(id: ..., kind: ..., color: ..., center: ..., vertices: (...), qubits: (...), meta: (...))
```

- store for each qubit:

```typ
(id: ..., pos: ..., incident-faces: (...), boundary-tags: (...), meta: (...))
```

- ensure `draw-background` explicitly places anchors for all faces and qubits,
- make `highlight-face` redraw using canonical face vertices,
- make `highlight-qubit` redraw using canonical qubit coordinates.

Apply this to all currently supported `6.6.6` shapes:

- `rect`
- `para`
- `tri`
- `tri-cut`

**Step 4: Verify all current `6.6.6` shapes still render**

Run:

```bash
typst compile examples/color_code_666.typ --root=. --format=png
```

Then add a temporary local smoke file or adapt the example in-place to exercise:

```typ
shape: "rect"
shape: "para"
shape: "tri"
shape: "tri-cut"
```

Expected: PASS, with anchor-based labels compiling cleanly.

**Step 5: Commit**

```bash
git add lib.typ examples/color_code_666.typ
git commit -m "Add canonical face and qubit geometry for 6.6.6"
```

### Task 3: Implement `6.6.6` Six-Boundary Hex Patches

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ)
- Create: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666_hex.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666_hex.typ)

**Step 1: Write the failing new example**

Create [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666_hex.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666_hex.typ) with:

```typ
#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#let code = color-code-2d(
  (0, 0),
  tiling: "6.6.6",
  shape: "hex",
  size: (lx: 3, ly: 4, lz: 3),
  scale: 1.0,
  name: "color-hex",
)

#canvas({
  (code.draw-background)(show-qubits: true)
})
```

**Step 2: Run the example to verify it fails**

Run:

```bash
typst compile examples/color_code_666_hex.typ --root=. --format=png
```

Expected: FAIL because `shape: "hex"` is not yet implemented.

**Step 3: Implement the hex patch builder**

In [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ):

- add `shape: "hex"` for `tiling: "6.6.6"`,
- require `size: (lx: ..., ly: ..., lz: ...)`,
- use axial or cube coordinates to define the included face region,
- generate deterministic face ids from canonical lattice coordinates,
- deduplicate qubits from canonical vertex keys before conversion to draw coordinates,
- attach `x+`, `y+`, `z+`, `x-`, `y-`, `z-` boundary tags and populate `boundaries`.

**Step 4: Run the hex example to verify it passes**

Run:

```bash
typst compile examples/color_code_666_hex.typ --root=. --format=png
```

Expected: PASS with a six-boundary patch that exposes usable anchors and qubit markers.

**Step 5: Commit**

```bash
git add lib.typ examples/color_code_666_hex.typ
git commit -m "Add six-boundary 6.6.6 hex patches"
```

### Task 4: Rework `4.8.8` into the 45-Degree Canonical Geometry

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488.typ)
- Create: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488_reference.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488_reference.typ)

**Step 1: Write the failing example migration**

Convert [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488.typ) to object usage and create [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488_reference.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488_reference.typ) that uses `code.basis`, one face anchor, and one qubit anchor for annotation.

**Step 2: Run the examples to verify the current implementation is inadequate**

Run:

```bash
typst compile examples/color_code_488.typ --root=. --format=png
typst compile examples/color_code_488_reference.typ --root=. --format=png
```

Expected: FAIL, or render with the wrong geometry/basis until the `4.8.8` builder is moved to the object model and rotated into the 45-degree reading.

**Step 3: Implement the canonical `4.8.8` object builder**

In [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ):

- move `4.8.8` onto the same returned object structure as `6.6.6`,
- model blue faces as diamonds and red/green faces as flat-top octagons,
- deduplicate qubits globally,
- set `basis.origin`, `basis.x`, and `basis.y` to the 45-degree reading,
- keep public `shape: "rect"` for now.

**Step 4: Run the examples to verify they pass**

Run:

```bash
typst compile examples/color_code_488.typ --root=. --format=png
typst compile examples/color_code_488_reference.typ --root=. --format=png
```

Expected: PASS, with the reference-style example able to annotate directly from object geometry.

**Step 5: Commit**

```bash
git add lib.typ examples/color_code_488.typ examples/color_code_488_reference.typ
git commit -m "Rework 4.8.8 to 45-degree object geometry"
```

### Task 5: Move `4.6.12` to the Shared Object API

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_4612.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_4612.typ)

**Step 1: Write the failing example migration**

Convert [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_4612.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_4612.typ) to object usage:

```typ
#let code = color-code-2d(...)
#canvas({
  (code.draw-background)(show-qubits: true)
})
```

**Step 2: Run the example to verify it fails**

Run:

```bash
typst compile examples/color_code_4612.typ --root=. --format=png
```

Expected: FAIL until the `4.6.12` branch returns the shared object shape.

**Step 3: Implement the shared object return for `4.6.12`**

In [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ):

- move the existing `4.6.12` code to the same builder-return path,
- populate canonical faces and qubits,
- provide stable face and qubit anchors,
- ensure `draw-background`, `highlight-face`, and `highlight-qubit` work.

Do not expand the supported patch family yet. Keep scope limited to API unification.

**Step 4: Run the example to verify it passes**

Run:

```bash
typst compile examples/color_code_4612.typ --root=. --format=png
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib.typ examples/color_code_4612.typ
git commit -m "Unify 4.6.12 with color-code object API"
```

### Task 6: Update Docs, Versioning, and Full Verification

**Files:**
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/README.md`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/README.md)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/typst.toml`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/typst.toml)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_4612.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_4612.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666_hex.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666_hex.typ)
- Modify: [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488_reference.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488_reference.typ)

**Step 1: Update the docs to the new public API**

Rewrite the `2D color code` sections in [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/README.md`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/README.md) so every example uses:

```typ
#let code = color-code-2d(...)
#canvas({
  (code.draw-background)(...)
})
```

Document:

- `faces`, `qubits`, `boundaries`, and `basis`,
- `face-anchor(id)` and `qubit-anchor(id)`,
- `shape: "hex"` for `6.6.6`,
- the 45-degree reading of `4.8.8`,
- the breaking change from `0.1.x`.

**Step 2: Bump the package version**

In [`/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/typst.toml`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/typst.toml), change:

```toml
version = "0.1.2"
```

to:

```toml
version = "0.2.0"
```

**Step 3: Run full verification**

Run:

```bash
typst compile examples/color_code_4612.typ --root=. --format=png
typst compile examples/color_code_488.typ --root=. --format=png
typst compile examples/color_code_488_reference.typ --root=. --format=png
typst compile examples/color_code_666.typ --root=. --format=png
typst compile examples/color_code_666_hex.typ --root=. --format=png
make
git diff --check
```

Expected:

- all examples compile,
- `make` succeeds,
- `git diff --check` reports no whitespace or merge-marker problems.

**Step 4: Inspect final status**

Run:

```bash
git status --short
```

Expected: only the intended implementation files are modified or added.

**Step 5: Commit**

```bash
git add lib.typ README.md typst.toml examples/color_code_666.typ examples/color_code_488.typ examples/color_code_4612.typ examples/color_code_666_hex.typ examples/color_code_488_reference.typ
git commit -m "Implement object-based color code geometry API"
```
