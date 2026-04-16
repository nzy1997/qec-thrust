# Code Interface Unification Assessment

Date: 2026-04-16

## Context

The repository now has two interface styles for code visualizations in [`lib.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/lib.typ):

- `color-code-2d(...)` returns an object with canonical geometry, anchors, and a small official helper surface.
- `surface-code(...)`, `toric-code(...)`, and `steane-code(...)` are still draw-first APIs.

This split is already visible in the examples:

- [`examples/color_code_666_panels.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/color_code_666_panels.typ) and related color-code examples build secondary figures from returned geometry and stable ids.
- [`examples/surface.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/surface.typ), [`examples/toric1.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/toric1.typ), and [`examples/steane.typ`](/Users/nzy/tycode/qec-thrust/.worktrees/color-code-object-api/examples/steane.typ) still rely on implicit naming conventions and string-built anchors.

The design question is not whether every code family should have exactly the same fields. The real question is whether the remaining code generators should share the same usage model as color codes: construct first, then draw and annotate through stable geometry objects.

## Validated Decision Summary

The evaluation settled on the following conclusions:

1. `surface-code` and `toric-code` should be aligned with the color-code object API model.
2. `steane-code` should not be forced into the same heavyweight patch object if the only motivation is symmetry.
3. Helper functions should be included in the assessment, not treated as separate from constructor design.
4. The goal is shared interaction style, not a single bloated object schema.
5. Priority order should be:
   - `toric-code`
   - `surface-code`
   - `steane-code`

## Assessment by Code Family

### `toric-code`

`toric-code` is the strongest candidate for unification and should be addressed first.

Current problems:

- it is draw-first,
- callers depend on hard-coded string naming for qubits,
- stabilizer semantics are split into external helpers such as `plaquette-code-label(...)` and `vertex-code-label(...)`,
- downstream figure code must already know the geometry rules that the library itself should own.

This is the same structural problem that motivated the color-code refactor. The API currently exposes a picture, but not the reusable geometry model behind that picture.

Conclusion:

- `toric-code(...)` should move to an object-style constructor,
- the current label/highlight helpers should be evaluated as part of the main API rather than extended as standalone geometry-aware functions.

### `surface-code`

`surface-code` should also move toward the object API model, but it is less urgent than toric code.

Current problems:

- it is draw-first,
- callers annotate by manually constructing anchor names,
- the library does not expose explicit qubit or stabilizer records even though the underlying geometry is regular and parameterized.

Unlike toric code, the helper situation is less fragmented, so this migration can be narrower in the first phase.

Conclusion:

- `surface-code(...)` should eventually return an object,
- the first version only needs the common geometry protocol and does not need an extensive helper surface.

### `steane-code`

`steane-code` should not be fully normalized into the same interface weight as patch generators.

Reason:

- it is a fixed small configuration rather than a large parameterized patch family,
- it has little need for boundary, shape, tiling, or orientation metadata,
- a complete `faces/qubits/boundaries/basis/highlight-*` contract would likely be over-designed for current usage.

Conclusion:

- keep `steane-code` lightweight,
- only unify the user experience where it is clearly beneficial, especially stable anchor access and a minimal draw helper.

## Proposed Shared Protocol

The repository should converge on a shared core protocol rather than a fully identical object layout.

### Core object protocol for reusable code generators

All object-style code constructors should aim to support:

- `params`
- `qubits`
- `draw-background()`
- `qubit-anchor(id)`
- `highlight-qubit(id, ...)`

For patch families with meaningful face or stabilizer regions, add:

- `faces`
- `face-anchor(id)`
- `highlight-face(id, ...)`

### Family-specific extensions

Each code family should remain free to expose its own additional metadata:

- `color-code-2d`: `tiling`, `shape`, `boundaries`, `basis`
- `surface-code`: boundary-type and stabilizer-region metadata
- `toric-code`: periodic-boundary metadata, edge orientation classes, plaquette and vertex stabilizer sets
- `steane-code`: minimal qubit/region metadata only

This keeps the interaction style consistent without pretending that all codes have the same geometry model.

## Helper Policy

Helper functions should not remain split from the geometry object when they encode structural knowledge of the code.

The clearest case is toric code:

- `plaquette-code-label(...)`
- `vertex-code-label(...)`

These functions already know toric geometry and qubit placement. That makes them a sign that the constructor is hiding reusable structure rather than a sign that the helper layer should keep growing.

Recommended direction:

- stop expanding these standalone helpers,
- move their structural role into the returned toric object,
- expose object-driven highlight or selection helpers instead.

For `surface-code`, helper migration can be more conservative.

For `steane-code`, only add helpers if they clearly simplify stable annotation.

## Priority and Scope

The recommended implementation order is:

1. `toric-code`
2. `surface-code`
3. `steane-code`

The intended scope by family is:

- `toric-code`: full object-API migration
- `surface-code`: object-API migration with a smaller first helper surface
- `steane-code`: light consistency pass, not a full heavy patch object

## Non-Goals

The assessment explicitly rejects the following goals:

- making every code family expose the exact same top-level fields,
- forcing `steane-code` to carry patch-style metadata it does not naturally need,
- preserving the current split where helper functions duplicate hidden constructor geometry,
- adding a universal all-codes helper abstraction before the per-family object models are clear.

## Recommendation

Yes, the other major patch-style code generators should be aligned with the color-code generation model, but selectively.

Recommended repository direction:

- unify `toric-code` and `surface-code` with the color-code object style,
- treat `toric` helper fragmentation as a real API smell and fix it at the object layer,
- keep `steane-code` lightweight and only partially aligned,
- optimize for shared usage patterns rather than full structural sameness.
