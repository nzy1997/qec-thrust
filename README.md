# Visualization of Quantum Error Correction Codes
This is a Typst package for visualizing quantum error correction codes.

**Note: Requires CeTZ version >= 0.4.0 and compiler version >= 0.13**


## Steane code
You can draw a Steane code by calling the `steane-code` function. The name of the qubits are automatically generated as `steane-1`, `steane-2`, etc.
```typ
#import "@preview/qec-thrust:0.2.0": *

#canvas({
  import draw: *
  steane-code((0, 0), size: 3)
    for j in range(7) {
      content((rel: (0, -0.3), to: "steane-" + str(j+1)), [#(j)])
    }
})
```
![Steane code](examples/steane.png)

## Surface code
You can draw a surface code with different size, color and orientation by `surface-code` function. The name of the qubits can be defined with `name` parameter as `name-i-j`. By default, they will be named as `surface-i-j`. The `type-tag` parameter can be set to `false` to change the orientation of the surface code. You can also tweak `point-radius` (relative to `size`) and `boundary-bulge` for the boundary curves. Here is an example of two surface codes.
```typ
#canvas({
  import draw: *
  let n = 3
  surface-code((0, 0),size:1.5, n, n,name: "surface1")
  for i in range(n) {
    for j in range(n) {
      content((rel: (0.3, 0.3), to: "surface1" + "-" + str(i) + "-" + str(j)), [#(i*n+j+1)])
    }
  }
  surface-code((4, 0), 15, 7,color1:red,color2:green,size:0.5,type-tag: false)
  })
```
![Surface code](examples/surface.png)

## Toric code
You can draw a toric code with different size and color by `toric-code` function. The name of the qubits can be defined with `name` parameter as `name-point-vertical-i-j` and `name-point-horizontal-i-j`. By default, they will begin with `toric`. Here is an example of a toric code with 5x3 size. `plaquette-code-label` and `vertex-code-label` functions can be used to label the plaquette and vertex stabilizers at a specified location. `stabilizer-label` generates a stabilizer legend.
```typ
#canvas({
  import draw: *
  let m = 5
  let n = 3
  let size = 2
  let circle-radius = 0.4
  toric-code((0, 0), m, n, size: size, circle-radius: circle-radius)
  plaquette-code-label((0, 0),2,0, size: size, circle-radius: circle-radius)
  vertex-code-label((0, 0),3,2, size: size, circle-radius: circle-radius)
  stabilizer-label((12, -2))
  for i in range(m){
    for j in range(n){
      content( "toric-point-vertical-" + str(i) + "-" + str(j), [#(i*n+j+1)])
      content( "toric-point-horizontal-" + str(i) + "-" + str(j), [#(i*n+j+1+m*n)])
    }
  }
})
```
![Toric code](examples/toric1.png)

`plaquette-code-label` and `vertex-code-label` functions can be adjusted to change the label of the stabilizers. Here is an example of$〚98,8,12〛$BB code.

```typ
#canvas({
  import draw: *
  toric-code((0, 0), 7, 7, size: 1)
  plaquette-code-label((0, 0),2,4,ver-vec:((-1,0),(2,1),(3,1)),hor-vec:((0,0),(-1,-4),(-1,-3)), size: 1)
  vertex-code-label((0, 0),6,1,ver-vec:((-1,0),(0,4),(0,3)),hor-vec:((-4,-1),(0,0),(-3,-1)), size: 1)
  stabilizer-label((10, -3))
})
```
![BB code](examples/toric2.png)

## 2D color code
`color-code-2d` now returns a geometry object instead of drawing directly. This is a breaking change in `0.2.x`: construct the patch first, then draw and annotate it explicitly inside `canvas`.

```typ
#canvas({
  import draw: *

  let code = color-code-2d(
    (0, 0),
    tiling: "6.6.6",
    shape: "rect",
    size: (rows: 4, cols: 4),
    hex-orientation: "flat",
    scale: 1.0,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-rect",
    show-qubits: true,
    qubit-radius: 0.08,
  )

  (code.draw-background)()
  (code.highlight-face)((0, 0), stroke: (paint: red, thickness: 1pt))
  (code.highlight-qubit)((2, 0), stroke: (paint: blue, thickness: 1pt))
  content((code.face-anchor)((0, 0)), [f])
  content((code.qubit-anchor)((2, 0)), [q])
})
```

The returned object exposes:

- `code.faces`: canonical face records with `id`, `kind`, `color`, `center`, `vertices`, `qubits`, and `meta`.
- `code.qubits`: canonical qubit records with `id`, `pos`, `incident-faces`, `boundary-tags`, and `meta`.
- `code.boundaries`: boundary-indexed qubit ids. For `6.6.6` hex patches this includes `x+`, `y+`, `z+`, `x-`, `y-`, and `z-`.
- `code.basis`: lattice basis information. `4.8.8` and `4.6.12` expose `origin`, `x`, and `y`; `6.6.6` exposes orientation metadata.
- `code.face-anchor(id)` and `code.qubit-anchor(id)`: stable anchors for downstream figure composition.
- `code.draw-background()`, `code.highlight-face(id, ..style)`, and `code.highlight-qubit(id, ..style)`: the small official drawing helper surface.

For `tiling: "6.6.6"`, supported shapes are `rect`, `para`, `tri`, `tri-cut`, and `hex`. `hex-orientation` can be `"flat"` or `"pointy"` for the non-hex patches (`tri-cut` requires `"flat"`). Tuple shorthand such as `(0, 0)` for faces and `(2, 0)` for qubits is accepted for the simple `6.6.6` and `4.8.8` id schemes.

![2D color code](examples/color_code_666.png)

## 2D color code (6.6.6 hex patch)
`shape: "hex"` builds a six-boundary patch with `size: (lx: ..., ly: ..., lz: ...)`.

```typ
#canvas({
  import draw: content

  let code = color-code-2d(
    (0, 0),
    tiling: "6.6.6",
    shape: "hex",
    size: (lx: 3, ly: 4, lz: 2),
    hex-orientation: "flat",
    scale: 1.0,
    name: "color-666-hex",
    show-qubits: true,
    qubit-radius: 0.08,
  )

  (code.draw-background)()
  content((code.face-anchor)((0, 0)), [hex-f])
  content((code.qubit-anchor)((2, 0)), [hex-q])
})
```

The boundary qubits are available via `code.boundaries.qubits`, and the six colored sides are split into `code.boundaries.x+`, `y+`, `z+`, `x-`, `y-`, and `z-`.

![2D color code 6.6.6 hex](examples/color_code_666_hex.png)

## 2D color code (4.8.8)
`tiling: "4.8.8"` now uses the same object API, keeps `size: (rows: ..., cols: ...)` as a rectangular patch boundary, and exposes a geometry-derived 45-degree reading frame through `code.basis.origin`, `code.basis.x`, and `code.basis.y`.

```typ
#canvas({
  let code = color-code-2d(
    (0, 0),
    tiling: "4.8.8",
    shape: "rect",
    size: (rows: 4, cols: 4),
    scale: 0.8,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-488",
    show-qubits: true,
    qubit-radius: 0.1,
  )
  (code.draw-background)()
})
```

See `examples/color_code_488_reference.typ` for a reference-style figure that reads the basis vectors directly from the object and annotates one face and one qubit through anchors.

![2D color code 4.8.8](examples/color_code_488.png)
![2D color code 4.8.8 reference](examples/color_code_488_reference.png)

## 2D color code (4.6.12)
`tiling: "4.6.12"` also returns the shared object shape. Currently only `shape: "rect"` is implemented. Stable face ids use the canonical prefixes `f-dod-*`, `f-sq-*`, and `f-hex-*`.

```typ
#canvas({
  import draw: content

  let code = color-code-2d(
    (0, 0),
    tiling: "4.6.12",
    shape: "rect",
    size: (rows: 6, cols: 6),
    scale: 0.6,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-4612",
    show-qubits: true,
    qubit-radius: 0.2,
  )

  (code.draw-background)()
  (code.highlight-face)("dod-2-2", stroke: (paint: red, thickness: 1pt))
  content((code.face-anchor)("dod-2-2"), [dod])
})
```

![2D color code 4.6.12](examples/color_code_4612.png)

## Notes
- If you draw multiple codes of the same type in one canvas, set a unique `name` prefix to avoid anchor collisions.
- `show-qubits`, `qubit-radius`, `qubit-color`, `show-stabilizers`, and `stabilizer-offset` are constructor options that affect `code.draw-background()`.
- `surface-code` uses +y upward, while `toric-code` uses -y downward (grid grows down).
## License

Licensed under the [MIT License](LICENSE).
