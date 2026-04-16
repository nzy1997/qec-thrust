# Color Code Object API Refactor Design

Date: 2026-04-14

## Context

The current `color-code-2d(...)` API in [`lib.typ`](/Users/nzy/tycode/qec-thrust/lib.typ) is draw-first:

- It draws faces immediately.
- Face anchors exist only as shape names.
- Qubits are drawn directly and do not have stable names or reusable geometry records.
- More advanced figures such as `temp/plot1.typ` require ad hoc reconstruction of centers, vertices, and local offsets in the calling code.

This makes it difficult to reproduce publication-style diagrams where the lattice is only the base layer and the actual figure needs:

- stable anchors for faces and physical qubits,
- deterministic lattice geometry that can be reused by higher-level annotations,
- support for additional patch families beyond the currently implemented rectangular examples.

## Goals

1. Refactor `color-code-2d(...)` into an object-construction API rather than an immediate drawing API.
2. Preserve stable anchors for both faces and qubits so downstream drawing can reference them directly.
3. Keep a small official helper surface:
   `draw-background`, `highlight-face`, and `highlight-qubit`.
4. Support a deformed six-boundary `6.6.6` patch with three independent boundary lengths.
5. Support a `4.8.8` layout whose canonical presentation is the 45-degree reading used by the reference figure.
6. Keep `4.6.12` on the same object API even if its geometry support remains limited.

## Non-Goals

- Porting the full custom figure helpers from `temp/lib_cc.typ` into the public library.
- Preserving backward compatibility for the old draw-first `color-code-2d(...)` behavior.
- General arbitrary polygon clipping input for color-code patches in this refactor.

## User-Facing Decision Summary

The validated decisions from the design discussion are:

- `color-code-2d(...)` becomes a breaking-change object API.
- Users must explicitly draw via `let code = color-code-2d(...); (code.draw-background)()`.
- `6.6.6` gains a new six-boundary patch mode with `shape: "hex"`.
- The `6.6.6` hex patch uses `size: (lx: ..., ly: ..., lz: ...)`, where each value controls one opposite boundary pair.
- `4.8.8` adopts the 45-degree reading as its canonical public geometry and basis.
- The public helper layer remains intentionally small.

## Proposed API

### Constructor

`color-code-2d(...)` remains the main entry point but no longer draws by itself.

Example:

```typ
#let code = color-code-2d(
  (0, 0),
  tiling: "6.6.6",
  shape: "hex",
  size: (lx: 3, ly: 4, lz: 3),
  scale: 1.2,
  color1: yellow,
  color2: aqua,
  color3: olive,
  name: "cc",
)

#canvas({
  (code.draw-background)(show-qubits: true)
  (code.highlight-face)("f-2-1", fill: red)
  (code.highlight-qubit)("q-17", fill: black)
})
```

### Returned Object

The returned object should expose at least:

- `tiling`
- `shape`
- `params`
- `faces`
- `qubits`
- `boundaries`
- `basis`
- `face-anchor(id)`
- `qubit-anchor(id)`
- `draw-background(...)`
- `highlight-face(id, ...)`
- `highlight-qubit(id, ...)`

### Helper Responsibilities

The helpers are deliberately thin wrappers over canonical geometry:

- `draw-background(...)` draws the patch, registers anchors, and optionally renders qubit markers.
- `highlight-face(id, ...)` redraws one face using the canonical face polygon.
- `highlight-qubit(id, ...)` redraws one physical qubit at its canonical coordinate.

No specialized annotation helpers such as unit-cell diagrams, basis arrows, or publication-specific overlays are part of the public API for this refactor. Those should be built by the caller on top of stable anchors and geometry.

## Canonical Data Model

### Faces

Each face record should contain:

- `id`: deterministic public face identifier,
- `kind`: face kind such as `hex`, `oct`, or `sq`,
- `color`: logical color class,
- `center`: final draw coordinate,
- `vertices`: ordered polygon vertices in draw coordinates,
- `qubits`: ordered list of global qubit ids attached to the face,
- `meta`: tiling-specific lattice metadata.

### Qubits

Each physical qubit must be globally unique. A qubit record should contain:

- `id`: deterministic public qubit identifier,
- `pos`: final draw coordinate,
- `incident-faces`: list of adjacent face ids,
- `boundary-tags`: list of boundary labels touching this qubit,
- `meta`: canonical lattice-space vertex data.

This is the key structural change from the current implementation. Qubits must no longer be modeled implicitly as repeated face-local vertices.

### Boundaries

`boundaries` should expose stable boundary segments and tags so higher-level figures can label or highlight them without reconstructing the patch boundary. For `6.6.6` hex patches the public boundary tags should be six directional labels:

- `x+`
- `y+`
- `z+`
- `x-`
- `y-`
- `z-`

Each boundary entry should contain:

- `tag`
- `qubits`
- `faces`
- `polyline`

### Basis

`basis` should expose public vectors or reference points sufficient for downstream annotations. At minimum:

- `origin`
- `x`
- `y`

For `4.8.8`, these basis directions must align with the canonical 45-degree reading.

## Anchor Policy

Anchors must be explicit and deterministic. The library should not rely on incidental shape names or derived anchors such as polygon centroids unless those are internally wrapped by the returned object.

The public contract is:

- `code.face-anchor(id)` returns a stable anchor for the face center.
- `code.qubit-anchor(id)` returns a stable anchor for the qubit position.

The `name` constructor argument is only a namespace prefix for anchors on a shared canvas. It must not alter canonical face or qubit ids.

## Geometry Strategy

### `6.6.6`

#### Existing Shapes

Current `6.6.6` shapes remain supported and migrate to the object model:

- `rect`
- `para`
- `tri`
- `tri-cut`

#### New Shape: `hex`

Add:

- `tiling: "6.6.6"`
- `shape: "hex"`
- `size: (lx: ..., ly: ..., lz: ...)`

Interpretation:

- `lx`, `ly`, and `lz` are positive integers.
- Each controls one pair of opposite boundaries.
- The patch is a convex six-boundary patch obtained by clipping the infinite `6.6.6` tiling with three independent axial extent constraints.

Implementation guidance:

- Use axial or cube lattice coordinates as the canonical face-space representation.
- Determine face inclusion by region inequalities in lattice space.
- Assign logical face colors via a deterministic `mod 3` color rule on lattice coordinates.
- Construct qubits from lattice-space vertex keys before converting to draw coordinates.

This avoids floating-point identity problems and guarantees that shared vertices deduplicate into single physical qubits.

### `4.8.8`

`4.8.8` should keep `shape: "rect"` in this refactor, but its public geometry should be rotated into the 45-degree reading used by the reference figure.

Concretely:

- blue faces are modeled as diamonds,
- red and green faces are modeled as flat-top octagons,
- the public basis directions are diagonal rather than axis-aligned,
- examples and README should use this orientation directly rather than applying custom post-rotation logic.

Canonical layout strategy:

- blue square centers lie on an integer lattice,
- red and green octagon centers lie on the half-shifted checkerboard sublattice,
- color assignment is parity-based and deterministic.

### `4.6.12`

`4.6.12` should be moved to the same object API in this refactor even if geometry expansion is deferred.

Requirements:

- return the same object shape,
- provide stable face and qubit anchors,
- support `draw-background`, `highlight-face`, and `highlight-qubit`.

## Identifier Policy

The object API needs deterministic ids so downstream figure code can be stable across redraws and formatting changes.

Requirements:

- face ids must be generated from canonical lattice coordinates or canonical face indices,
- qubit ids must be generated from canonical vertex keys after global deduplication,
- the same input parameters must always yield the same ids,
- ids must not depend on floating-point rounding artifacts.

The exact textual format of the ids can be finalized during implementation, but they must be human-usable and predictable.

## Error Handling

All major validation should happen during object construction.

The constructor should `assert` on:

- unsupported `tiling` and `shape` combinations,
- missing required `size` fields,
- non-positive size values,
- geometry configurations that produce an empty or degenerate patch,
- duplicate canonical qubit keys,
- internal inconsistencies such as an invalid vertex count for a face kind.

Errors should fail early in the builder rather than surfacing later in rendering helpers.

## Migration Plan

This is a breaking change.

Required repository updates:

- refactor [`lib.typ`](/Users/nzy/tycode/qec-thrust/lib.typ) so `color-code-2d(...)` returns an object,
- update [`README.md`](/Users/nzy/tycode/qec-thrust/README.md) to the object-style usage,
- update [`examples/color_code_666.typ`](/Users/nzy/tycode/qec-thrust/examples/color_code_666.typ),
- update [`examples/color_code_488.typ`](/Users/nzy/tycode/qec-thrust/examples/color_code_488.typ),
- update [`examples/color_code_4612.typ`](/Users/nzy/tycode/qec-thrust/examples/color_code_4612.typ),
- add at least one new example for the `6.6.6` six-boundary hex patch,
- add at least one example showing the 45-degree `4.8.8` geometry in a way close to the reference-style figure.

Because the public API changes incompatibly, the package version should move from the `0.1.x` line to `0.2.0`.

## Verification Strategy

### Geometry Checks

Implementation should verify:

- each face has the correct number of vertices,
- shared vertices deduplicate into a single physical qubit,
- qubit incident-face relationships are consistent,
- boundary tags for boundary qubits are correct and stable.

### Render Smoke Tests

All example files should compile after the refactor, including coverage for:

- `6.6.6 rect`
- `6.6.6 para`
- `6.6.6 tri`
- `6.6.6 tri-cut`
- `6.6.6 hex`
- `4.8.8 rect`
- `4.6.12 rect`

### Reference Alignment

At least one example should be written specifically to validate that:

- the `4.8.8` 45-degree basis is directly usable for annotations,
- the `6.6.6` six-boundary patch exposes stable anchors and boundary tags,
- advanced overlays can be composed without re-deriving geometry in user code.

## Recommended Implementation Order

1. Extract a shared geometry builder and object-construction layer.
2. Migrate current `6.6.6`, `4.8.8`, and `4.6.12` generation to the shared object API.
3. Implement canonical face and qubit deduplication plus anchor helpers.
4. Add `6.6.6 shape: "hex"` with `size: (lx, ly, lz)`.
5. Rework `4.8.8` into the canonical 45-degree presentation.
6. Update README, examples, and package version.
7. Compile examples and validate geometry invariants before release.

## Ready for Implementation

This document intentionally stops at the validated design level. The next implementation phase should create a detailed execution plan and then perform the refactor in the repository.
