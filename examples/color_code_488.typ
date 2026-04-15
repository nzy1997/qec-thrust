#import "../lib.typ": *
#import draw: content
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
    name: "color-488",
    show-qubits: true,
    qubit-radius: 0.1,
  )
  (code.draw-background)()
  (code.highlight-face)((2, 2), stroke: (paint: red, thickness: 1pt))
  content((code.face-anchor)((2, 2)), [f])
})
