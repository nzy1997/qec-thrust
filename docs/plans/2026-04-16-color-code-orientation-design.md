# Color Code Orientation Unification Design

Date: 2026-04-16

## Context

The current orientation API is inconsistent across tilings in [`lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ):

- `6.6.6` uses `hex-orientation: "flat" | "pointy"` as a geometry-level parameter.
- `4.8.8` exposes a rotated reading frame internally, but examples still rely on outer `#rotate(...)` wrappers to present the patch in different orientations.

This creates an avoidable split between canonical geometry and displayed geometry. Faces, qubits, anchors, basis vectors, and downstream annotations should all come from the same final lattice embedding.

## Validated Decisions

The design discussion settled the following decisions:

1. `hex-orientation` is removed entirely and replaced by a single public parameter: `orientation`.
2. This is a breaking change. No compatibility alias is kept.
3. `orientation` uses the same public values for all supported tilings:
   - `"flat"`
   - `"pointy"`
4. `4.8.8` must not use outer `#rotate(...)` to express the 45-degree presentation.
5. `4.8.8` orientation is defined at the canonical geometry layer, just like `6.6.6`.

## User-Facing Semantics

`color-code-2d(...)` becomes:

```typ
#let code = color-code-2d(
  (0, 0),
  tiling: "4.8.8",
  shape: "rect",
  size: (rows: 3, cols: 5),
  orientation: "pointy",
  name: "cc",
)
```

Public meaning:

- For `6.6.6`:
  - `orientation: "flat"` means the hexagons have horizontal edges.
  - `orientation: "pointy"` means the hexagons are rotated to the point-up embedding.
- For `4.8.8`:
  - `orientation: "flat"` means the square faces have horizontal and vertical edges.
  - `orientation: "pointy"` means the square faces have diagonal 45-degree edges.

In both cases, `orientation` describes the actual face geometry, not a post-render view transform.

## Geometry Strategy

### `6.6.6`

The `6.6.6` implementation already uses orientation-aware canonical geometry. This refactor keeps the existing geometry logic and only:

- renames all public and internal parameters from `hex-orientation` to `orientation`,
- updates validation messages,
- propagates the renamed field through returned metadata and helper code.

No compatibility shim is added.

### `4.8.8`

`4.8.8` is upgraded from a single hard-coded geometry to an orientation-aware canonical builder.

The implementation should separate:

- topology:
  - face ids,
  - face grid indexing,
  - qubit deduplication keys,
  - boundary classification,
  - public anchor naming;
- embedding:
  - face centers,
  - local vertex offsets,
  - basis vectors,
  - any orientation-specific lattice metadata.

`orientation: "flat"` and `orientation: "pointy"` should each produce complete canonical geometry directly. The chosen orientation determines the final qubit coordinates, face polygons, anchors, and basis.

The important consequence is that all downstream helpers operate on final geometry. There is no hidden post-rotation stage.

## Basis and Anchors

The returned object should expose the selected orientation in canonical metadata so callers do not need to infer it from coordinates.

At minimum, the returned basis data should remain consistent with the chosen embedding:

- `basis.origin`
- `basis.x`
- `basis.y`
- `basis.orientation`

Face and qubit anchors must remain stable under both `4.8.8` orientations and both `6.6.6` orientations. A caller that uses:

- `code.faces`
- `code.qubits`
- `code.face-anchor(id)`
- `code.qubit-anchor(id)`

should always get positions in the actual chosen embedding, not in a pre-rotation coordinate frame.

## Examples and Migration

All example call sites should migrate from `hex-orientation:` to `orientation:`.

Specific example changes:

- [`examples/color_code_666.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666.typ)
  - rename `hex-orientation:` to `orientation:`
- [`examples/color_code_488.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_488.typ)
  - remove outer `#rotate(...)`
  - render distinct `orientation: "flat"` and `orientation: "pointy"` patches directly
- any `4.8.8` panel or plot recreation examples that rely on the diagonal embedding
  - explicitly request `orientation: "pointy"`

Because this is a deliberate breaking change, there is no fallback behavior for `hex-orientation:`.

## Verification

The implementation should be considered complete only after all of the following are verified:

1. `6.6.6` examples compile with `orientation:` instead of `hex-orientation:`.
2. `4.8.8` examples compile without any `#rotate(...)` workaround.
3. Both `4.8.8` orientations generate valid anchors, faces, qubits, and basis vectors.
4. Existing object-API figure helpers that depend on `4.8.8` diagonal geometry still render correctly when they request `orientation: "pointy"`.
5. A repository search shows no remaining `hex-orientation` references.
