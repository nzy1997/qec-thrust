#import "../lib.typ": *
#import draw: *

#set page(width: auto, height: auto, margin: 5pt)

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
    name: "color-488-reference",
    show-qubits: true,
    qubit-radius: 0.1,
  )

  (code.draw-background)()
  (code.highlight-face)((2, 2), stroke: (paint: red, thickness: 1pt))
  (code.highlight-qubit)((8, 10), stroke: (paint: blue, thickness: 1pt))

  let o = code.basis.origin
  let bx = code.basis.x
  let by = code.basis.y
  let scale = 2.4
  let px = (o.at(0) + bx.at(0) * scale, o.at(1) + bx.at(1) * scale)
  let py = (o.at(0) + by.at(0) * scale, o.at(1) + by.at(1) * scale)

  line(o, px, stroke: (paint: red, thickness: 1pt))
  line(o, py, stroke: (paint: blue, thickness: 1pt))
  content(px, [x])
  content(py, [y])
  content((code.face-anchor)((2, 2)), [f])
  content((code.qubit-anchor)((8, 10)), [q])
})
