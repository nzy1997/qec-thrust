#import "@preview/fig-plucker:0.1.0": *
#import "@preview/cetz:0.4.0": canvas, draw
#import "../lib.typ": *

#show: fig-plucker.with(
  debug: true,
  output-num: 8,
)

#set text(font: "New Computer Modern")
#show math.equation: set text(font: "New Computer Modern Math")

#let soft-red = red.lighten(80%)
#let soft-green = green.lighten(80%)
#let soft-blue = blue.lighten(80%)
#let anyon-fill = green
#let cyan-fill = rgb("#40b8cc")
#let magenta-fill = rgb("#c02dd8")
#let orange-fill = rgb("#f3b341")
#let lattice-stroke = (paint: rgb("#bcbcbc"), thickness: 1pt)
#let qubit-stroke = (paint: rgb("#bcbcbc"), thickness: 0.8pt)
#let arrow-stroke = (paint: black, thickness: 1pt)
#let dashed-stroke = (paint: black, thickness: 1pt, dash: "dashed")
#let qubit-radius = 0.14

#let pt-add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let pt-scale(p, s) = (p.at(0) * s, p.at(1) * s)
#let dist2(a, b) = {
  let dx = a.at(0) - b.at(0)
  let dy = a.at(1) - b.at(1)
  dx * dx + dy * dy
}

#let format-id(id) = {
  if type(id) == array and id.len() > 0 {
    str(id.at(0)) + id.slice(1).fold("", (acc, part) => acc + "-" + str(part))
  } else {
    str(id)
  }
}

#let face-id(id) = {
  let text = format-id(id)
  if text.starts-with("f-") { text } else { "f-" + text }
}

#let qubit-id(id) = {
  let text = format-id(id)
  if text.starts-with("q-") { text } else { "q-" + text }
}

#let find-face(code, id) = {
  let target = face-id(id)
  let found = none
  for face in code.faces {
    if found == none and face.id == target {
      found = face
    }
  }
  assert(found != none, message: "Unknown face id " + target + ".")
  found
}

#let find-qubit(code, id) = {
  let target = qubit-id(id)
  let found = none
  for qubit in code.qubits {
    if found == none and qubit.id == target {
      found = qubit
    }
  }
  assert(found != none, message: "Unknown qubit id " + target + ".")
  found
}

#let nearest-qubit(code, target, exclude: none) = {
  let skip-id = if exclude == none { none } else { qubit-id(exclude) }
  let best = none
  let best-dist = 1e18
  for qubit in code.qubits {
    let skip = skip-id != none and qubit.id == skip-id
    if not skip {
      let d = dist2(qubit.pos, target)
      if d < best-dist {
        best = qubit
        best-dist = d
      }
    }
  }
  assert(best != none, message: "Could not find a nearby qubit.")
  best
}

#let draw-open-qubits(code, radius: qubit-radius) = {
  import draw: circle
  for qubit in code.qubits {
    circle(qubit.pos, radius: radius, fill: white, stroke: qubit-stroke)
  }
}

#let label-dot(pos, body, fill: white, stroke: black) = {
  import draw: content
  content(
    pos,
    body,
    frame: "circle",
    fill: fill,
    stroke: stroke,
  )
}

#let highlight-pos(pos, fill, radius: 0.17) = {
  import draw: circle
  circle(pos, radius: radius, fill: fill, stroke: (paint: black, thickness: 0.8pt))
}

#let make-666(name: "obj-666") = color-code-2d(
  (0, 0),
  tiling: "6.6.6",
  shape: "hex",
  size: (lx: 3, ly: 3, lz: 3),
  hex-orientation: "flat",
  scale: 1.0,
  color1: soft-red,
  color2: soft-green,
  color3: soft-blue,
  name: name,
  stroke: lattice-stroke,
  show-qubits: false,
)

#let make-488(name: "obj-488") = color-code-2d(
  (0, 0),
  tiling: "4.8.8",
  shape: "rect",
  size: (rows: 3, cols: 3),
  scale: 1.0,
  color1: soft-red,
  color2: soft-green,
  color3: soft-blue,
  name: name,
  stroke: lattice-stroke,
  show-qubits: false,
)

#let draw-base(code) = {
  (code.draw-background)()
  draw-open-qubits(code)
}

#let draw-666-basis() = {
  import draw: *
  let code = make-666(name: "obj-666-basis")
  draw-base(code)

  let face = find-face(code, (0, 0))
  let q1-id = face.qubits.at(3)
  let q2-id = face.qubits.at(5)
  let q1 = find-qubit(code, q1-id).pos
  let q2 = find-qubit(code, q2-id).pos
  let qy = nearest-qubit(code, pt-add(q1, (0, -2.0)), exclude: q1-id).pos

  highlight-pos(q1, cyan-fill)
  highlight-pos(q2, magenta-fill)
  line(q1, q2, stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.7))
  line(q1, qy, stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.7))

  label-dot(q1, text(size: 14pt)[$1$], fill: cyan-fill)
  label-dot(q2, text(size: 14pt)[$2$], fill: magenta-fill)
  content(pt-add(q2, (0.45, 0.3)), text(size: 18pt)[$x$])
  content(pt-add(qy, (0.0, -0.45)), text(size: 18pt)[$y$])
}

#let draw-666-stabilizers() = {
  import draw: *
  let code = make-666(name: "obj-666-stabilizers")
  draw-base(code)

  let face = find-face(code, (0, 0))
  let qs = face.qubits.map((qid) => find-qubit(code, qid).pos)
  for (i, qid) in face.qubits.enumerate() {
    let fill = if calc.even(i) { magenta-fill } else { cyan-fill }
    (code.highlight-qubit)(qid, radius: 0.17, fill: fill, stroke: (paint: black, thickness: 0.8pt))
  }

  line(qs.at(0), qs.at(2), stroke: dashed-stroke)
  line(qs.at(2), qs.at(4), stroke: dashed-stroke)
  line(qs.at(4), qs.at(0), stroke: dashed-stroke)
  line(qs.at(1), qs.at(3), stroke: dashed-stroke)
  line(qs.at(3), qs.at(5), stroke: dashed-stroke)
  line(qs.at(5), qs.at(1), stroke: dashed-stroke)

  let center = face.center
  content(pt-add(qs.at(1), (-0.45, -0.35)), text(size: 18pt)[$y$])
  content(pt-add(qs.at(0), (0.15, -0.35)), text(size: 18pt)[$x y$])
  content(pt-add(qs.at(5), (0.2, 0.55)), text(size: 18pt)[$x$])
  content(pt-add(qs.at(0), (1.05, 0.1)), text(size: 18pt)[$x y$])
  content(pt-add(center, (-3.2, -0.25)), text(size: 16pt, fill: cyan-fill)[$1+x+x y$])
  content(pt-add(center, (-3.0, 0.55)), text(size: 16pt, fill: magenta-fill)[$1+y+x y$])
}

#let draw-666-anyon() = {
  import draw: *
  let code = make-666(name: "obj-666-anyon")
  draw-base(code)

  let a = find-face(code, (-1, 0)).center
  let b = find-face(code, (1, -1)).center
  let c = find-face(code, (1, 1)).center

  for pos in (a, b, c) {
    circle(pos, radius: 0.28, fill: anyon-fill, stroke: (paint: black, thickness: 0.8pt))
  }
  line(a, b, stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.6))
  line(a, c, stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.6))
  content(pt-add(pt-scale(pt-add(a, b), 0.5), (-0.2, -0.55)), text(size: 16pt)[$x^2 y = 1$])
  content(pt-add(pt-scale(pt-add(a, c), 0.5), (0.0, 0.55)), text(size: 16pt)[$x^3 = 1$])
}

#let draw-666-debug() = {
  import draw: *
  let code = make-666(name: "obj-666-debug")
  draw-base(code)

  for face in code.faces {
    content(face.center, text(size: 7pt)[#face.id])
  }
  for qubit in code.qubits {
    content(qubit.pos, text(size: 4.5pt, fill: gray)[#qubit.id])
  }
}

#let draw-488-basis() = {
  import draw: *
  let code = make-488(name: "obj-488-basis")
  draw-base(code)

  let square = find-face(code, (2, 2))
  let origin = square.center
  let px = find-face(code, (4, 2)).center
  let py = find-face(code, (2, 4)).center

  line(origin, px, stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.7))
  line(origin, py, stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.7))
  content(pt-add(px, (0.25, 0.05)), text(size: 18pt)[$x$])
  content(pt-add(py, (-0.1, -0.45)), text(size: 18pt)[$y$])

  let fills = (cyan-fill, soft-blue.darken(20%), cyan-fill.darken(15%), magenta-fill)
  for (i, qid) in square.qubits.enumerate() {
    (code.highlight-qubit)(qid, radius: 0.17, fill: fills.at(i), stroke: (paint: black, thickness: 0.8pt))
  }
  label-dot(find-qubit(code, square.qubits.at(1)).pos, text(size: 14pt)[$1$], fill: fills.at(1))
  label-dot(find-qubit(code, square.qubits.at(2)).pos, text(size: 14pt)[$2$], fill: fills.at(2))
  label-dot(find-qubit(code, square.qubits.at(3)).pos, text(size: 14pt)[$3$], fill: fills.at(3))
  label-dot(find-qubit(code, square.qubits.at(0)).pos, text(size: 14pt)[$4$], fill: fills.at(0))
}

#let draw-488-stabilizers() = {
  import draw: *
  let code = make-488(name: "obj-488-stabilizers")
  draw-base(code)

  let square = find-face(code, (2, 2))
  let oct = find-face(code, (3, 3))
  let sq-colors = (magenta-fill, cyan-fill, orange-fill, aqua)
  let oct-colors = (cyan-fill, aqua, orange-fill, white, white, cyan-fill, magenta-fill, orange-fill)

  for (i, qid) in square.qubits.enumerate() {
    (code.highlight-qubit)(qid, radius: 0.17, fill: sq-colors.at(i), stroke: (paint: black, thickness: 0.8pt))
  }
  for (i, qid) in oct.qubits.enumerate() {
    let fill = oct-colors.at(i)
    if fill != white {
      (code.highlight-qubit)(qid, radius: 0.17, fill: fill, stroke: (paint: black, thickness: 0.8pt))
    }
  }

  let s = square.qubits.map((qid) => find-qubit(code, qid).pos)
  let o = oct.qubits.map((qid) => find-qubit(code, qid).pos)
  line(s.at(0), s.at(2), stroke: dashed-stroke)
  line(s.at(1), s.at(3), stroke: dashed-stroke)
  line(o.at(6), o.at(2), stroke: dashed-stroke)
  line(o.at(7), o.at(3), stroke: dashed-stroke)
  line(s.at(0), o.at(6), stroke: dashed-stroke)
  line(s.at(1), o.at(7), stroke: dashed-stroke)

  content(pt-add(o.at(6), (-0.2, -0.35)), text(size: 18pt)[$x y$])
  content(pt-add(o.at(2), (0.2, 0.0)), text(size: 18pt)[$x y$])
  content(pt-add(o.at(5), (-0.55, -0.15)), text(size: 18pt)[$y$])
  content(pt-add(o.at(3), (0.2, 0.55)), text(size: 18pt)[$x$])
  content(pt-add(s.at(0), (-0.65, 0.1)), text(size: 18pt)[$y$])
  content(pt-add(s.at(1), (0.15, 0.6)), text(size: 18pt)[$x$])

  content(pt-add(square.center, (-2.55, 0.2)), text(size: 15pt, fill: cyan-fill)[$1+y$])
  content(pt-add(square.center, (-2.55, 0.8)), text(size: 15pt, fill: soft-blue.darken(20%))[$1+y$])
  content(pt-add(square.center, (-2.55, 1.4)), text(size: 15pt, fill: orange-fill)[$1+x$])
  content(pt-add(square.center, (-2.55, 2.0)), text(size: 15pt, fill: magenta-fill)[$1+x$])

  content(pt-add(oct.center, (1.55, -1.5)), text(size: 15pt, fill: cyan-fill)[$x y$])
  content(pt-add(oct.center, (1.7, -0.9)), text(size: 15pt, fill: aqua)[$y$])
  content(pt-add(oct.center, (1.55, -0.3)), text(size: 15pt, fill: orange-fill)[$x y$])
  content(pt-add(oct.center, (1.7, 0.3)), text(size: 15pt, fill: magenta-fill)[$x$])
}

#let draw-488-anyon() = {
  import draw: *
  let code = make-488(name: "obj-488-anyon")
  draw-base(code)

  let a = find-face(code, (1, 3)).center
  let b = find-face(code, (3, 1)).center
  let c = find-face(code, (5, 3)).center

  for pos in (a, b, c) {
    circle(pos, radius: 0.28, fill: anyon-fill, stroke: (paint: black, thickness: 0.8pt))
  }
  line(a, b, stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.6))
  line(a, c, stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.6))
  content(pt-add(pt-scale(pt-add(a, b), 0.5), (-0.35, -0.4)), text(size: 16pt)[$x y = 1$])
  content(pt-add(pt-scale(pt-add(a, c), 0.5), (0.0, 0.55)), text(size: 16pt)[$x^2 = 1$])
}

#let draw-488-debug() = {
  import draw: *
  let code = make-488(name: "obj-488-debug")
  draw-base(code)

  for face in code.faces {
    content(face.center, text(size: 7pt)[#face.id])
  }
  for qubit in code.qubits {
    content(qubit.pos, text(size: 4.5pt, fill: gray)[#qubit.id])
  }
}

#fig("666cc-basis")[
  #canvas({
    draw-666-basis()
  })
]

#fig("666cc-stabilizers")[
  #canvas({
    draw-666-stabilizers()
  })
]

#fig("666cc-anyon")[
  #canvas({
    draw-666-anyon()
  })
]

#fig("666cc-debug")[
  #canvas({
    draw-666-debug()
  })
]

#fig("488cc-basis")[
  #canvas({
    draw-488-basis()
  })
]

#fig("488-stabilizers")[
  #canvas({
    draw-488-stabilizers()
  })
]

#fig("488cc-anyon")[
  #canvas({
    draw-488-anyon()
  })
]

#fig("488cc-debug")[
  #canvas({
    draw-488-debug()
  })
]
