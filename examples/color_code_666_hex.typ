#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: content
  let code = color-code-2d(
    (0, 0),
    tiling: "6.6.6",
    shape: "hex",
    size: (lx: 3, ly: 4, lz: 2),
    hex-orientation: "flat",
    scale: 1.0,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-666-hex",
    show-qubits: true,
    qubit-radius: 0.08,
  )
  (code.draw-background)()
  content((code.face-anchor)("f-0-0"), [hex-f])
  content((code.qubit-anchor)("q-2-0"), [hex-q])
})
