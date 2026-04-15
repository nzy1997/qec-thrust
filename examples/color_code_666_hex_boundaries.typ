#import "../lib.typ": *
#import draw: content

#set page(width: auto, height: auto, margin: 5pt)

#let find-qubit(code, id) = {
  let found = none
  for qubit in code.qubits {
    if qubit.id == id {
      found = qubit
    }
  }
  assert(found != none, message: "Unknown boundary qubit id " + str(id) + ".")
  found
}

#let mean-pos(code, ids) = {
  let sx = 0
  let sy = 0
  let count = 0
  for id in ids {
    let qubit = find-qubit(code, id)
    sx += qubit.pos.at(0)
    sy += qubit.pos.at(1)
    count += 1
  }
  assert(count > 0, message: "Expected a non-empty boundary.")
  (sx / count, sy / count)
}

#canvas({
  let code = color-code-2d(
    (0, 0),
    tiling: "6.6.6",
    shape: "hex",
    size: (lx: 3, ly: 4, lz: 2),
    hex-orientation: "flat",
    scale: 1.0,
    color1: yellow.transparentize(35%),
    color2: aqua.transparentize(35%),
    color3: olive.transparentize(35%),
    name: "color-666-hex-boundaries",
    show-qubits: true,
    qubit-radius: 0.07,
  )

  (code.draw-background)()

  let boundary-specs = (
    (tag: "x+", color: red, shift: (0.8, 0.2)),
    (tag: "y+", color: blue, shift: (0.1, 0.9)),
    (tag: "z+", color: green, shift: (-0.9, 0.6)),
    (tag: "x-", color: red.darken(35%), shift: (-0.9, -0.2)),
    (tag: "y-", color: blue.darken(35%), shift: (-0.1, -0.9)),
    (tag: "z-", color: green.darken(35%), shift: (0.9, -0.6)),
  )

  for spec in boundary-specs {
    let ids = code.boundaries.at(spec.tag)
    for id in ids {
      (code.highlight-qubit)(
        id,
        radius: 0.12,
        fill: spec.color.transparentize(60%),
        stroke: (paint: spec.color, thickness: 0.9pt),
      )
    }

    let mid = mean-pos(code, ids)
    let label-pos = (mid.at(0) + spec.shift.at(0), mid.at(1) + spec.shift.at(1))
    content(label-pos, text(fill: spec.color)[#spec.tag])
  }
})
