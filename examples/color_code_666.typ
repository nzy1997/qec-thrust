#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: content
  let qubit-radius = 0.1
  let code = color-code-2d(
    (0, 0),
    tiling: "6.6.6",
    shape: "rect",
    size: (rows: 4, cols: 4),
    hex-orientation: "flat",
    scale: 1.2,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-rect",
    show-qubits: true,
    qubit-radius: qubit-radius,
  )
  (code.draw-background)()
  content((code.face-anchor)("f-0-0"), [F00])
  content((code.qubit-anchor)("q-2-0"), [q20])
})
