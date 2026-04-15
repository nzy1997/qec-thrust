#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: content
  let qubit-radius = 0.08

  let rect = color-code-2d(
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
    qubit-radius: qubit-radius,
  )
  (rect.draw-background)()
  (rect.highlight-face)((0, 0), stroke: (paint: red, thickness: 1pt))
  (rect.highlight-qubit)((2, 0), stroke: (paint: blue, thickness: 1pt))
  content((rect.face-anchor)((0, 0)), [rect-f])
  content((rect.qubit-anchor)((2, 0)), [rect-q])

  let para = color-code-2d(
    (9.5, 0),
    tiling: "6.6.6",
    shape: "para",
    size: (rows: 4, cols: 4),
    hex-orientation: "flat",
    scale: 1.0,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-para",
    show-qubits: true,
    qubit-radius: qubit-radius,
  )
  (para.draw-background)()
  content((para.face-anchor)((0, 0)), [para-f])
  content((para.qubit-anchor)((2, 0)), [para-q])

  let tri = color-code-2d(
    (0, 7.5),
    tiling: "6.6.6",
    shape: "tri",
    size: (n: 4),
    hex-orientation: "flat",
    scale: 1.0,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-tri",
    show-qubits: true,
    qubit-radius: qubit-radius,
  )
  (tri.draw-background)()
  content((tri.face-anchor)((0, 0)), [tri-f])
  content((tri.qubit-anchor)((2, 0)), [tri-q])

  let tri-cut = color-code-2d(
    (9.5, 7.5),
    tiling: "6.6.6",
    shape: "tri-cut",
    size: (n: 3),
    hex-orientation: "flat",
    scale: 1.0,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-tri-cut",
    show-qubits: true,
    qubit-radius: qubit-radius,
  )
  (tri-cut.draw-background)()
  content((tri-cut.face-anchor)((0, 0)), [tri-cut-f])
  content((tri-cut.qubit-anchor)((2, 0)), [tri-cut-q])
})
