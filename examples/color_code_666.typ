#import "@preview/cetz:0.4.0": canvas
#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 5pt)

#let overview-666(loc, shape, size, name, orientation: "flat") = {
  let code = color-code-2d(
    loc,
    tiling: "6.6.6",
    shape: shape,
    size: size,
    orientation: orientation,
    scale: 0.8,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: name,
    show-qubits: false,
  )
  (code.draw-background)()
}

#canvas({
  overview-666((0, 0), "rect", (rows: 4, cols: 4), "color-666-rect-flat")
  overview-666((11.8, 0), "rect", (rows: 4, cols: 4), "color-666-rect-pointy", orientation: "pointy")
  overview-666((23.6, 0), "para", (rows: 4, cols: 4), "color-666-para")

  overview-666((0, -10.5), "tri", (n: 3), "color-666-tri")
  overview-666((11.8, -10.5), "tri-cut", (n: 3), "color-666-tri-cut")
  overview-666((23.6, -10.5), "hex", (lx: 2, ly: 2, lz: 2), "color-666-hex")
})
