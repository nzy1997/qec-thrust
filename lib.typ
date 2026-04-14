#import "@preview/cetz:0.4.0": canvas,draw

#let steane-code(loc,size:4, color1:yellow, color2:aqua,color3:olive,name: "steane",point-radius:0.1) = {
  import draw: *
  let x = loc.at(0) 
  let y = loc.at(1)
  let locp-vec = ((x - calc.sqrt(3)*size/2,y  - size/2),(x,y - size/2),(x + calc.sqrt(3)*size/2,y  - size/2),(x,y + size),(x - calc.sqrt(3)*size/4,y + size/4),(x + calc.sqrt(3)*size/4,y + size/4),(x,y))
  for (i, locp) in locp-vec.enumerate() {
    circle(locp, radius: point-radius, fill: black, stroke: none, name: name + "-" + str(i + 1))
  }

  for ((i,j,k,l),color) in (((1,2,7,5),color1),((2,3,6,7),color2),((4,5,7,6),color3)) {
    line(name + "-" + str(i), name + "-" + str(j), name + "-" + str(k), name + "-" + str(l), name + "-" + str(i), fill: color)
  }

  for (i, locp) in locp-vec.enumerate() {
    circle(locp, radius: point-radius, fill: black, stroke: none)
  }
}

#let surface-code(
  loc,
  m,
  n,
  size: 1,
  color1: yellow,
  color2: aqua,
  name: "surface",
  type-tag: true,
  point-radius: 0.08,
  boundary-bulge: 0.7,
) = {
  import draw: *
  let x0 = loc.at(0)
  let y0 = loc.at(1)
  for i in range(m) {
    for j in range(n) {
      let x = x0 + i * size
      let y = y0 + j * size
      if (i != m - 1) and (j != n - 1) {
        // determine the color of the plaquette
        let (colora, colorb) = if (calc.rem(i + j, 2) == 0) {
          (color1, color2)
        } else {
          (color2, color1)
        }
        // four types of boundary plaquettes
        if type-tag == (calc.rem(i + j, 2) == 0) {
            if (i == 0) {
              bezier((x, y), (x, y + size), (x - size * boundary-bulge, y + size/2), fill: colorb, stroke: black)
            }
            if (i == m - 2) {
              bezier((x + size, y), (x + size, y + size), (x + size * (1 + boundary-bulge), y + size/2), fill: colorb, stroke: black)
            }
          } else {
            if (j == 0) {
              bezier((x, y), (x + size, y), (x + size/2, y - size * boundary-bulge), fill: colorb, stroke: black)
            }
            if (j == n - 2) {
              bezier((x, y + size), (x + size, y + size), (x + size/2, y + size * (1 + boundary-bulge)), fill: colorb, stroke: black)
            }
          }
          rect((x, y), (x + size, y + size), fill: colora, stroke: black, name: name + "-square" + "-" + str(i) + "-" + str(j))
      }
      circle((x, y), radius: point-radius * size, fill: black, stroke: none, name: name + "-" + str(i) + "-" + str(j))
    }
    }
  }
}

#let color-code-2d-render(
  loc,
  tiling: "6.6.6",
  shape: "rect",
  size: none,
  hex-orientation: "flat",
  scale: 1,
  color1: yellow,
  color2: aqua,
  color3: olive,
  name: "color-code",
  stroke: black,
  show-stabilizers: false,
  stabilizer-offset: 0.35,
  show-qubits: false,
  qubit-radius: 0.12,
  qubit-color: black,
) = {
  import draw: line, content, circle
  assert(size != none, message: "color-code-2d requires size: (rows/cols or n).")
  let x0 = loc.at(0)
  let y0 = loc.at(1)
  let s = scale
  let pick-color = (color-index) => {
    if (color-index == 0) { color1 } else if (color-index == 1) { color2 } else { color3 }
  }
  let mod3 = (value) => {
    let m = calc.rem(value, 3)
    if m < 0 { m + 3 } else { m }
  }

  if tiling == "6.6.6" {
    let sqrt3 = calc.sqrt(3)
    let half = s / 2
    let diag = sqrt3 / 2 * s
    let qubit-r = qubit-radius * s
    assert(hex-orientation == "flat" or hex-orientation == "pointy", message: "hex-orientation must be \"flat\" or \"pointy\".")

    let axial-to-center = (q, r) => {
      if hex-orientation == "pointy" {
        (x0 + sqrt3 * s * (q + r / 2), y0 + 1.5 * s * r)
      } else {
        (x0 + 1.5 * s * q, y0 + sqrt3 * s * (r + q / 2))
      }
    }

    let offset-to-axial = (col, row) => {
      if hex-orientation == "pointy" {
        (col - (row - calc.rem(row, 2)) / 2, row)
      } else {
        (col, row - (col - calc.rem(col, 2)) / 2)
      }
    }

    let draw-face = (x, y, q, r, color-index) => {
      if hex-orientation == "pointy" {
        line(
          (x, y + s),
          (x + diag, y + half),
          (x + diag, y - half),
          (x, y - s),
          (x - diag, y - half),
          (x - diag, y + half),
          (x, y + s),
          fill: pick-color(color-index),
          stroke: stroke,
          name: name + "-face-" + str(q) + "-" + str(r),
        )
        if show-qubits {
          circle((x, y + s), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-0")
          circle((x + diag, y + half), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-1")
          circle((x + diag, y - half), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-2")
          circle((x, y - s), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-3")
          circle((x - diag, y - half), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-4")
          circle((x - diag, y + half), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-5")
        }
      } else {
        line(
          (x + s, y),
          (x + half, y + diag),
          (x - half, y + diag),
          (x - s, y),
          (x - half, y - diag),
          (x + half, y - diag),
          (x + s, y),
          fill: pick-color(color-index),
          stroke: stroke,
          name: name + "-face-" + str(q) + "-" + str(r),
        )
        if show-qubits {
          circle((x + s, y), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-0")
          circle((x + half, y + diag), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-1")
          circle((x - half, y + diag), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-2")
          circle((x - s, y), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-3")
          circle((x - half, y - diag), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-4")
          circle((x + half, y - diag), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-5")
        }
      }
      if show-stabilizers {
        content((x, y + stabilizer-offset * s), [X])
        content((x, y - stabilizer-offset * s), [Z])
      }
    }

    if shape == "rect" {
      assert(size.rows != none and size.cols != none, message: "shape \"rect\" requires size: (rows: ..., cols: ...).")
      for r in range(size.rows) {
        for q in range(size.cols) {
          let (aq, ar) = offset-to-axial(q, r)
          let (x, y) = axial-to-center(aq, ar)
          let color-index = calc.rem(aq + 2 * ar, 3)
          draw-face(x, y, q, r, color-index)
        }
      }
    } else if shape == "para" or shape == "parallelogram" {
      assert(size.rows != none and size.cols != none, message: "shape \"para\" requires size: (rows: ..., cols: ...).")
      for r in range(size.rows) {
        for q in range(size.cols) {
          let (x, y) = axial-to-center(q, r)
          let color-index = calc.rem(q + 2 * r, 3)
          draw-face(x, y, q, r, color-index)
        }
      }
    } else if shape == "tri" {
      assert(size.n != none, message: "shape \"tri\" requires size: (n: ...).")
      for r in range(size.n) {
        for q in range(size.n - r) {
          let (x, y) = axial-to-center(q, r)
          let color-index = calc.rem(q + 2 * r, 3)
          draw-face(x, y, q, r, color-index)
        }
      }
    } else if shape == "tri-cut" {
      assert(hex-orientation == "flat", message: "shape \"tri-cut\" requires hex-orientation: \"flat\".")
      assert(size.n != none, message: "shape \"tri-cut\" requires size: (n: ...).")
      let n = size.n
      let tri-a = (x0, y0)
      let base-len = 3 * s * n
      let tri-b = (x0 + base-len, y0)
      let tri-c = ((tri-a.at(0) + tri-b.at(0)) / 2, y0 + base-len * sqrt3 / 2)
      let tri-center = ((tri-a.at(0) + tri-b.at(0) + tri-c.at(0)) / 3, (tri-a.at(1) + tri-b.at(1) + tri-c.at(1)) / 3)
      let ox = x0 + half
      let oy = y0 + diag
      let axial-to-center-cut = (q, r) => (ox + 1.5 * s * q, oy + sqrt3 * s * (r + q / 2))

      let pt-x = (p) => p.at(0)
      let pt-y = (p) => p.at(1)
      let add = (a, b) => (pt-x(a) + pt-x(b), pt-y(a) + pt-y(b))
      let sub = (a, b) => (pt-x(a) - pt-x(b), pt-y(a) - pt-y(b))
      let mul = (a, k) => (pt-x(a) * k, pt-y(a) * k)
      let dot = (a, b) => pt-x(a) * pt-x(b) + pt-y(a) * pt-y(b)

      let line-normal = (p1, p2) => {
        let d = sub(p2, p1)
        let n0 = (pt-y(d), -pt-x(d))
        if dot(sub(tri-center, p1), n0) < 0 {
          (-pt-x(n0), -pt-y(n0))
        } else {
          n0
        }
      }

      let intersect = (p1, p2, p0, n) => {
        let d = sub(p2, p1)
        let denom = dot(d, n)
        if denom == 0 { p2 } else {
          let t = dot(sub(p0, p1), n) / denom
          add(p1, mul(d, t))
        }
      }

      let clip-poly = (poly, p0, n) => {
        let out = ()
        if poly.len() == 0 { return out }
        let prev = poly.last()
        let prev-in = dot(sub(prev, p0), n) >= 0
        for curr in poly {
          let curr-in = dot(sub(curr, p0), n) >= 0
          if curr-in != prev-in {
            out += (intersect(prev, curr, p0, n),)
          }
          if curr-in {
            out += (curr,)
          }
          prev = curr
          prev-in = curr-in
        }
        out
      }

      let n-base = line-normal(tri-a, tri-b)
      let n-right = line-normal(tri-b, tri-c)
      let n-left = line-normal(tri-c, tri-a)
      let eps = 1e-6
      let inside-tri = (p) => dot(sub(p, tri-a), n-base) >= -eps and dot(sub(p, tri-b), n-right) >= -eps and dot(sub(p, tri-c), n-left) >= -eps

      let q-min = -2
      let q-max = 2 * n + 2
      let r-min = -n - 2
      let r-max = 2 * n + 2

      for q in range(q-min, q-max + 1) {
        for r in range(r-min, r-max + 1) {
          let (x, y) = axial-to-center-cut(q, r)
          let poly = (
            (x + s, y),
            (x + half, y + diag),
            (x - half, y + diag),
            (x - s, y),
            (x - half, y - diag),
            (x + half, y - diag),
          )
          let clipped = clip-poly(poly, tri-a, n-base)
          let clipped = clip-poly(clipped, tri-b, n-right)
          let clipped = clip-poly(clipped, tri-c, n-left)
          if clipped.len() >= 3 {
            line(..clipped, close: true, fill: pick-color(mod3(q + 2 * r)), stroke: stroke, name: name + "-face-" + str(q) + "-" + str(r))
            if show-stabilizers {
              content((x, y + stabilizer-offset * s), [X])
              content((x, y - stabilizer-offset * s), [Z])
            }
          }
        }
      }
      if show-qubits {
        for q in range(q-min, q-max + 1) {
          for r in range(r-min, r-max + 1) {
            let (x, y) = axial-to-center-cut(q, r)
            let verts = (
              (x + s, y),
              (x + half, y + diag),
              (x - half, y + diag),
              (x - s, y),
              (x - half, y - diag),
              (x + half, y - diag),
            )
            for pt in verts {
              if inside-tri(pt) {
                circle(pt, radius: qubit-r, fill: qubit-color, stroke: none)
              }
            }
          }
        }
      }
    } else {
      assert(false, message: "color-code-2d: unsupported shape \"" + shape + "\" for tiling \"6.6.6\".")
    }
  } else if tiling == "4.6.12" {
    assert(shape == "rect", message: "tiling \"4.6.12\" currently supports only shape \"rect\".")
    assert(size.rows != none and size.cols != none, message: "shape \"rect\" requires size: (rows: ..., cols: ...).")
    let sqrt3 = calc.sqrt(3)
    let a4 = s / 2
    let a6 = s * sqrt3 / 2
    let a12 = s * (1 + sqrt3 / 2)
    let qubit-r = qubit-radius * s

    let vx = (p) => p.at(0)
    let vy = (p) => p.at(1)
    let add = (a, b) => (vx(a) + vx(b), vy(a) + vy(b))
    let sub = (a, b) => (vx(a) - vx(b), vy(a) - vy(b))
    let mul = (a, k) => (vx(a) * k, vy(a) * k)
    let mid = (a, b) => mul(add(a, b), 0.5)
    let square-angle-v1 = 180deg
    let square-angle-v2 = 240deg
    let square-angle-v3 = 300deg
    let hex-angle = 30deg

    let poly-verts = (center, sides, normal-angle) => {
      let radius = s / (2 * calc.sin(180deg / sides))
      let start = normal-angle - 180deg / sides
      let verts = ()
      for k in range(sides) {
        let ang = start + 360deg * k / sides
        verts += ((vx(center) + radius * calc.cos(ang), vy(center) + radius * calc.sin(ang)),)
      }
      verts
    }

    let draw-poly = (center, sides, normal-angle, fill-color, tag, prefix) => {
      let verts = poly-verts(center, sides, normal-angle)
      line(..verts, close: true, fill: fill-color, stroke: stroke, name: name + "-" + prefix + "-" + tag)
      if show-qubits {
        for pt in verts {
          circle(pt, radius: qubit-r, fill: qubit-color, stroke: none)
        }
      }
    }

    let L = 2 * (a12 + a4)
    let v1 = (L, 0)
    let v2 = (L / 2, L * sqrt3 / 2)
    let center = (i, j) => (x0 + i * vx(v1) + j * vx(v2), y0 + i * vy(v1) + j * vy(v2))

    // Dodecagons
    for j in range(size.rows) {
      for i in range(size.cols) {
        let c = center(i, j)
        draw-poly(c, 12, 0deg, color2, str(i) + "-" + str(j), "dod")
      }
    }

    // Squares on lattice edges (three directions)
    for j in range(size.rows) {
      for i in range(size.cols - 1) {
        let a = center(i, j)
        let b = center(i + 1, j)
        let c = mid(a, b)
        draw-poly(c, 4, square-angle-v1, color3, str(i) + "-" + str(j) + "-v1", "sq")
      }
    }
    for j in range(size.rows - 1) {
      for i in range(size.cols) {
        let a = center(i, j)
        let b = center(i, j + 1)
        let c = mid(a, b)
        draw-poly(c, 4, square-angle-v2, color3, str(i) + "-" + str(j) + "-v2", "sq")
      }
    }
    for j in range(size.rows - 1) {
      for i in range(size.cols - 1) {
        let a = center(i + 1, j)
        let b = center(i, j + 1)
        let c = mid(a, b)
        draw-poly(c, 4, square-angle-v3, color3, str(i) + "-" + str(j) + "-v3", "sq")
      }
    }

    // Hexagons at triangle centroids
    for j in range(size.rows - 1) {
      for i in range(size.cols - 1) {
        let a = center(i, j)
        let b = center(i + 1, j)
        let c = center(i, j + 1)
        let cent = mul(add(add(a, b), c), 1 / 3)
        draw-poly(cent, 6, hex-angle, color1, str(i) + "-" + str(j) + "-up", "hex")

        let a2 = center(i + 1, j + 1)
        let cent2 = mul(add(add(b, c), a2), 1 / 3)
        draw-poly(cent2, 6, hex-angle, color1, str(i) + "-" + str(j) + "-down", "hex")
      }
    }
  } else if tiling == "4.8.8" {
    assert(shape == "rect", message: "tiling \"4.8.8\" currently supports only shape \"rect\".")
    assert(size.rows != none and size.cols != none, message: "shape \"rect\" requires size: (rows: ..., cols: ...).")
    let half = s / 2
    let inv-sqrt2 = 1 / calc.sqrt(2)
    let apothem = s * (0.5 + inv-sqrt2)
    let step = apothem + half
    let qubit-r = qubit-radius * s

    let draw-oct = (x, y, q, r, color-index) => {
      line(
        (x - half, y + apothem),
        (x + half, y + apothem),
        (x + apothem, y + half),
        (x + apothem, y - half),
        (x + half, y - apothem),
        (x - half, y - apothem),
        (x - apothem, y - half),
        (x - apothem, y + half),
        (x - half, y + apothem),
        fill: if (color-index == 0) { color1 } else { color2 },
        stroke: stroke,
        name: name + "-oct-" + str(q) + "-" + str(r),
      )
      if show-qubits {
        circle((x - half, y + apothem), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x + half, y + apothem), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x + apothem, y + half), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x + apothem, y - half), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x + half, y - apothem), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x - half, y - apothem), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x - apothem, y - half), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x - apothem, y + half), radius: qubit-r, fill: qubit-color, stroke: none)
      }
      if show-stabilizers {
        content((x, y + stabilizer-offset * s), [X])
        content((x, y - stabilizer-offset * s), [Z])
      }
    }

    let draw-square = (x, y, tag) => {
      line(
        (x - half, y + half),
        (x + half, y + half),
        (x + half, y - half),
        (x - half, y - half),
        (x - half, y + half),
        fill: color3,
        stroke: stroke,
        name: name + "-" + tag,
      )
      if show-qubits {
        circle((x - half, y + half), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x + half, y + half), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x + half, y - half), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x - half, y - half), radius: qubit-r, fill: qubit-color, stroke: none)
      }
      if show-stabilizers {
        content((x, y + stabilizer-offset * s), [X])
        content((x, y - stabilizer-offset * s), [Z])
      }
    }

    let grid-rows = size.rows * 2 - 1
    let grid-cols = size.cols * 2 - 1
    for r in range(grid-rows) {
      for q in range(grid-cols) {
        let x = x0 + q * step
        let y = y0 + r * step
        if calc.rem(q + r, 2) == 0 {
          let color-index = calc.rem(q, 2)
          draw-oct(x, y, q, r, color-index)
        } else {
          draw-square(x, y, "sq-" + str(q) + "-" + str(r))
        }
      }
    }
  } else {
    assert(false, message: "color-code-2d: unsupported tiling \"" + tiling + "\".")
  }
}

#let color-code-666-canonical(
  loc,
  shape: "rect",
  size: none,
  hex-orientation: "flat",
  scale: 1,
) = {
  assert(size != none, message: "color-code-2d requires size: (rows/cols or n).")
  assert(hex-orientation == "flat" or hex-orientation == "pointy", message: "hex-orientation must be \"flat\" or \"pointy\".")
  let x0 = loc.at(0)
  let y0 = loc.at(1)
  let s = scale
  let sqrt3 = calc.sqrt(3)
  let half = s / 2
  let diag = sqrt3 / 2 * s

  let mod3 = (value) => {
    let m = calc.rem(value, 3)
    if m < 0 { m + 3 } else { m }
  }

  let pt-x = (p) => p.at(0)
  let pt-y = (p) => p.at(1)
  let add = (a, b) => (pt-x(a) + pt-x(b), pt-y(a) + pt-y(b))
  let sub = (a, b) => (pt-x(a) - pt-x(b), pt-y(a) - pt-y(b))
  let mul = (a, k) => (pt-x(a) * k, pt-y(a) * k)
  let dot = (a, b) => pt-x(a) * pt-x(b) + pt-y(a) * pt-y(b)
  let add-int = (a, b) => (a.at(0) + b.at(0), a.at(1) + b.at(1))

  let axial-to-center = (q, r) => {
    if hex-orientation == "pointy" {
      (x0 + sqrt3 * s * (q + r / 2), y0 + 1.5 * s * r)
    } else {
      (x0 + 1.5 * s * q, y0 + sqrt3 * s * (r + q / 2))
    }
  }

  let offset-to-axial = (col, row) => {
    if hex-orientation == "pointy" {
      (col - (row - calc.rem(row, 2)) / 2, row)
    } else {
      (col, row - (col - calc.rem(col, 2)) / 2)
    }
  }

  let vertex-offsets = if hex-orientation == "pointy" {
    (
      (0, s),
      (diag, half),
      (diag, -half),
      (0, -s),
      (-diag, -half),
      (-diag, half),
    )
  } else {
    (
      (s, 0),
      (half, diag),
      (-half, diag),
      (-s, 0),
      (-half, -diag),
      (half, -diag),
    )
  }

  let vertex-key-offsets = if hex-orientation == "pointy" {
    (
      (0, 2),
      (1, 1),
      (1, -1),
      (0, -2),
      (-1, -1),
      (-1, 1),
    )
  } else {
    (
      (2, 0),
      (1, 1),
      (-1, 1),
      (-2, 0),
      (-1, -1),
      (1, -1),
    )
  }

  let center-key = (q, r) => {
    if hex-orientation == "pointy" {
      (2 * q + r, 3 * r)
    } else {
      (3 * q, 2 * r + q)
    }
  }

  let all-corners = (0, 1, 2, 3, 4, 5)
  let face-seeds = ()

  if shape == "rect" {
    assert(size.rows != none and size.cols != none, message: "shape \"rect\" requires size: (rows: ..., cols: ...).")
    for row in range(size.rows) {
      for col in range(size.cols) {
        let (aq, ar) = offset-to-axial(col, row)
        let center = axial-to-center(aq, ar)
        let verts = all-corners.map((corner) => add(center, vertex-offsets.at(corner)))
        face-seeds += ((
          aq: aq,
          ar: ar,
          center: center,
          vertices: verts,
          "qubit-corners": all-corners,
          kind: "hex",
          meta: (shape: "rect", row: row, col: col),
        ),)
      }
    }
  } else if shape == "para" or shape == "parallelogram" {
    assert(size.rows != none and size.cols != none, message: "shape \"para\" requires size: (rows: ..., cols: ...).")
    for row in range(size.rows) {
      for col in range(size.cols) {
        let aq = col
        let ar = row
        let center = axial-to-center(aq, ar)
        let verts = all-corners.map((corner) => add(center, vertex-offsets.at(corner)))
        face-seeds += ((
          aq: aq,
          ar: ar,
          center: center,
          vertices: verts,
          "qubit-corners": all-corners,
          kind: "hex",
          meta: (shape: "para", row: row, col: col),
        ),)
      }
    }
  } else if shape == "tri" {
    assert(size.n != none, message: "shape \"tri\" requires size: (n: ...).")
    for row in range(size.n) {
      for col in range(size.n - row) {
        let aq = col
        let ar = row
        let center = axial-to-center(aq, ar)
        let verts = all-corners.map((corner) => add(center, vertex-offsets.at(corner)))
        face-seeds += ((
          aq: aq,
          ar: ar,
          center: center,
          vertices: verts,
          "qubit-corners": all-corners,
          kind: "hex",
          meta: (shape: "tri", row: row, col: col),
        ),)
      }
    }
  } else if shape == "tri-cut" {
    assert(hex-orientation == "flat", message: "shape \"tri-cut\" requires hex-orientation: \"flat\".")
    assert(size.n != none, message: "shape \"tri-cut\" requires size: (n: ...).")
    let n = size.n
    let tri-a = (x0, y0)
    let base-len = 3 * s * n
    let tri-b = (x0 + base-len, y0)
    let tri-c = ((tri-a.at(0) + tri-b.at(0)) / 2, y0 + base-len * sqrt3 / 2)
    let tri-center = ((tri-a.at(0) + tri-b.at(0) + tri-c.at(0)) / 3, (tri-a.at(1) + tri-b.at(1) + tri-c.at(1)) / 3)
    let ox = x0 + half
    let oy = y0 + diag
    let axial-to-center-cut = (q, r) => (ox + 1.5 * s * q, oy + sqrt3 * s * (r + q / 2))

    let line-normal = (p1, p2) => {
      let d = sub(p2, p1)
      let n0 = (pt-y(d), -pt-x(d))
      if dot(sub(tri-center, p1), n0) < 0 {
        (-pt-x(n0), -pt-y(n0))
      } else {
        n0
      }
    }

    let intersect = (p1, p2, p0, n0) => {
      let d = sub(p2, p1)
      let denom = dot(d, n0)
      if denom == 0 {
        p2
      } else {
        let t = dot(sub(p0, p1), n0) / denom
        add(p1, mul(d, t))
      }
    }

    let clip-poly = (poly, p0, n0) => {
      let out = ()
      if poly.len() == 0 { return out }
      let prev = poly.last()
      let prev-in = dot(sub(prev, p0), n0) >= 0
      for curr in poly {
        let curr-in = dot(sub(curr, p0), n0) >= 0
        if curr-in != prev-in {
          out += (intersect(prev, curr, p0, n0),)
        }
        if curr-in {
          out += (curr,)
        }
        prev = curr
        prev-in = curr-in
      }
      out
    }

    let n-base = line-normal(tri-a, tri-b)
    let n-right = line-normal(tri-b, tri-c)
    let n-left = line-normal(tri-c, tri-a)
    let eps = 1e-6
    let inside-tri = (p) => {
      let inside-base = dot(sub(p, tri-a), n-base) >= -eps
      let inside-right = dot(sub(p, tri-b), n-right) >= -eps
      let inside-left = dot(sub(p, tri-c), n-left) >= -eps
      inside-base and inside-right and inside-left
    }

    let q-min = -2
    let q-max = 2 * n + 2
    let r-min = -n - 2
    let r-max = 2 * n + 2

    for aq in range(q-min, q-max + 1) {
      for ar in range(r-min, r-max + 1) {
        let center = axial-to-center-cut(aq, ar)
        let full-verts = all-corners.map((corner) => add(center, vertex-offsets.at(corner)))
        let clipped = clip-poly(full-verts, tri-a, n-base)
        let clipped = clip-poly(clipped, tri-b, n-right)
        let clipped = clip-poly(clipped, tri-c, n-left)
        if clipped.len() >= 3 {
          let qubit-corners = ()
          for corner in all-corners {
            if inside-tri(full-verts.at(corner)) {
              qubit-corners += (corner,)
            }
          }
          face-seeds += ((
            aq: aq,
            ar: ar,
            center: center,
            vertices: clipped,
            "qubit-corners": qubit-corners,
            kind: "clipped-hex",
            meta: (shape: "tri-cut"),
          ),)
        }
      }
    }
  } else {
    assert(false, message: "color-code-2d: unsupported shape \"" + shape + "\" for tiling \"6.6.6\".")
  }

  let append-unique = (items, value) => if value in items { items } else { items + (value,) }
  let qubit-by-key = (:)
  let qubit-by-id = (:)
  let qubit-order = ()
  let faces = ()

  for seed in face-seeds {
    let face-id = "f-" + str(seed.aq) + "-" + str(seed.ar)
    let ckey = center-key(seed.aq, seed.ar)
    let face-qubits = ()
    for corner in seed.at("qubit-corners") {
      let key-vec = add-int(ckey, vertex-key-offsets.at(corner))
      let vertex-key = str(key-vec.at(0)) + "-" + str(key-vec.at(1))
      let vertex-pos = add(seed.center, vertex-offsets.at(corner))
      let qid = if vertex-key in qubit-by-key {
        qubit-by-key.at(vertex-key)
      } else {
        let new-id = "q-" + vertex-key
        qubit-by-key.insert(vertex-key, new-id)
        qubit-order.push(new-id)
        qubit-by-id.insert(new-id, (
          id: new-id,
          pos: vertex-pos,
          "incident-faces": (),
          "boundary-tags": (),
          meta: (vertex-key: vertex-key),
        ))
        new-id
      }
      let current = qubit-by-id.at(qid)
      let incidents = append-unique(current.at("incident-faces"), face-id)
      qubit-by-id.insert(qid, (
        id: current.id,
        pos: current.pos,
        "incident-faces": incidents,
        "boundary-tags": current.at("boundary-tags"),
        meta: current.meta,
      ))
      face-qubits = append-unique(face-qubits, qid)
    }
    let color-index = mod3(seed.aq + 2 * seed.ar)
    let color-tag = if color-index == 0 { "c0" } else if color-index == 1 { "c1" } else { "c2" }
    faces.push((
      id: face-id,
      kind: seed.kind,
      color: color-tag,
      center: seed.center,
      vertices: seed.vertices,
      qubits: face-qubits,
      meta: (
        aq: seed.aq,
        ar: seed.ar,
        color-index: color-index,
        shape: shape,
        source: seed.meta,
      ),
    ))
  }

  for qid in qubit-order {
    let qubit = qubit-by-id.at(qid)
    let degree = qubit.at("incident-faces").len()
    let boundary-tags = if degree < 3 { ("boundary",) } else { () }
    qubit-by-id.insert(qid, (
      id: qubit.id,
      pos: qubit.pos,
      "incident-faces": qubit.at("incident-faces"),
      "boundary-tags": boundary-tags,
      meta: (
        vertex-key: qubit.meta.vertex-key,
        degree: degree,
      ),
    ))
  }

  let qubits = qubit-order.map((qid) => qubit-by-id.at(qid))
  let boundary-qubits = qubits.filter((qubit) => qubit.at("boundary-tags").len() > 0).map((qubit) => qubit.id)

  (
    faces: faces,
    qubits: qubits,
    boundaries: (
      qubits: boundary-qubits,
    ),
    basis: (
      hex-orientation: hex-orientation,
      scale: scale,
      axial: (
        center-key: if hex-orientation == "pointy" { "u=2q+r,v=3r" } else { "u=3q,v=2r+q" },
      ),
      vertex-key-offsets: vertex-key-offsets,
    ),
  )
}

#let color-code-2d(
  loc,
  tiling: "6.6.6",
  shape: "rect",
  size: none,
  hex-orientation: "flat",
  scale: 1,
  color1: yellow,
  color2: aqua,
  color3: olive,
  name: "color-code",
  stroke: black,
  show-stabilizers: false,
  stabilizer-offset: 0.35,
  show-qubits: false,
  qubit-radius: 0.12,
  qubit-color: black,
) = {
  let params = (
    loc: loc,
    tiling: tiling,
    shape: shape,
    size: size,
    hex-orientation: hex-orientation,
    scale: scale,
    color1: color1,
    color2: color2,
    color3: color3,
    name: name,
    stroke: stroke,
    show-stabilizers: show-stabilizers,
    stabilizer-offset: stabilizer-offset,
    show-qubits: show-qubits,
    qubit-radius: qubit-radius,
    qubit-color: qubit-color,
  )

  let canonical = if tiling == "6.6.6" {
    color-code-666-canonical(
      loc,
      shape: shape,
      size: size,
      hex-orientation: hex-orientation,
      scale: scale,
    )
  } else {
    none
  }

  let faces = if canonical == none { () } else { canonical.faces }
  let qubits = if canonical == none { () } else { canonical.qubits }
  let boundaries = if canonical == none { () } else { canonical.boundaries }
  let basis = if canonical == none {
    (
      hex-orientation: hex-orientation,
      scale: scale,
    )
  } else {
    canonical.basis
  }

  let format-id = (id) => {
    if type(id) == array and id.len() > 0 {
      str(id.at(0)) + id.slice(1).fold("", (acc, part) => acc + "-" + str(part))
    } else {
      str(id)
    }
  }

  let normalize-face-id = (id) => {
    let id-text = format-id(id)
    if canonical != none and not id-text.starts-with("f-") {
      "f-" + id-text
    } else {
      id-text
    }
  }

  let normalize-qubit-id = (id) => {
    let id-text = format-id(id)
    if canonical != none and not id-text.starts-with("q-") {
      "q-" + id-text
    } else {
      id-text
    }
  }

  let face-name = (id) => name + "-face-" + normalize-face-id(id)
  let qubit-name = (id) => name + "-qubit-" + normalize-qubit-id(id)
  let face-anchor-name = (id) => name + "-face-anchor-" + normalize-face-id(id)
  let qubit-anchor-name = (id) => name + "-qubit-anchor-" + normalize-qubit-id(id)
  let face-anchor = (id) => (name: (face-anchor-name)(id), anchor: "center")
  let qubit-anchor = (id) => (name: (qubit-anchor-name)(id), anchor: "center")

  let pick-face-color = (face) => {
    if face.color == "c0" {
      color1
    } else if face.color == "c1" {
      color2
    } else {
      color3
    }
  }

  let resolve-face = (id) => {
    let target-id = normalize-face-id(id)
    let found = none
    for face in faces {
      if found == none and face.id == target-id {
        found = face
      }
    }
    found
  }

  let resolve-qubit = (id) => {
    let target-id = normalize-qubit-id(id)
    let found = none
    for qubit in qubits {
      if found == none and qubit.id == target-id {
        found = qubit
      }
    }
    found
  }

  let draw-background = () => {
    import draw: line, content, circle
    if tiling == "6.6.6" {
      let qubit-r = qubit-radius * scale
      for face in faces {
        line(..face.vertices, close: true, fill: pick-face-color(face), stroke: stroke, name: (face-name)(face.id))
        circle(face.center, radius: 0, fill: none, stroke: none, name: (face-anchor-name)(face.id))
        if show-stabilizers {
          content((face.center.at(0), face.center.at(1) + stabilizer-offset * scale), [X])
          content((face.center.at(0), face.center.at(1) - stabilizer-offset * scale), [Z])
        }
      }
      for qubit in qubits {
        circle(qubit.pos, radius: 0, fill: none, stroke: none, name: (qubit-anchor-name)(qubit.id))
        if show-qubits {
          circle(qubit.pos, radius: qubit-r, fill: qubit-color, stroke: none, name: (qubit-name)(qubit.id))
        }
      }
    } else {
      color-code-2d-render(
        loc,
        tiling: tiling,
        shape: shape,
        size: size,
        hex-orientation: hex-orientation,
        scale: scale,
        color1: color1,
        color2: color2,
        color3: color3,
        name: name,
        stroke: stroke,
        show-stabilizers: show-stabilizers,
        stabilizer-offset: stabilizer-offset,
        show-qubits: show-qubits,
        qubit-radius: qubit-radius,
        qubit-color: qubit-color,
      )
    }
  }

  let highlight-face = (id, radius: none, fill: none, stroke: (paint: red, thickness: 1pt)) => {
    import draw: line, circle
    if tiling == "6.6.6" {
      let face = (resolve-face)(id)
      assert(face != none, message: "Unknown face id \"" + normalize-face-id(id) + "\".")
      line(..face.vertices, close: true, fill: fill, stroke: stroke)
      if radius != none {
        circle(face.center, radius: radius, fill: none, stroke: stroke)
      }
    } else {
      circle((face-anchor)(id), radius: if radius == none { scale * 0.42 } else { radius }, fill: fill, stroke: stroke)
    }
  }

  let highlight-qubit = (id, radius: none, fill: none, stroke: (paint: red, thickness: 1pt)) => {
    import draw: circle
    if tiling == "6.6.6" {
      let qubit = (resolve-qubit)(id)
      assert(qubit != none, message: "Unknown qubit id \"" + normalize-qubit-id(id) + "\".")
      circle(qubit.pos, radius: if radius == none { scale * 0.2 } else { radius }, fill: fill, stroke: stroke)
    } else {
      circle((qubit-anchor)(id), radius: if radius == none { scale * 0.2 } else { radius }, fill: fill, stroke: stroke)
    }
  }

  (
    tiling: tiling,
    shape: shape,
    params: params,
    faces: faces,
    qubits: qubits,
    boundaries: boundaries,
    basis: basis,
    face-anchor: face-anchor,
    qubit-anchor: qubit-anchor,
    draw-background: draw-background,
    highlight-face: highlight-face,
    highlight-qubit: highlight-qubit,
  )
}

#let stabilizer-label(loc, size:1, color1:yellow, color2:aqua) = {
  import draw: *
  let x = loc.at(0)
  let y = loc.at(1)
  content((x, y), box(stroke: black, inset: 10pt, [$X$ stabilizers],fill: color2, radius: 4pt))
  content((x, y - 1.5*size), box(stroke: black, inset: 10pt, [$Z$ stabilizers],fill: color1, radius: 4pt))
}

#let toric-code(loc, m, n, size:1,circle-radius:0.2,color1:white,color2:gray,line-thickness:1pt,name: "toric") = {
  import draw: *
    for i in range(m){
    for j in range(n){
            let x = loc.at(0) + i * size
      let y = loc.at(1) - j * size
 rect((x, y), (x + size, y - size), fill: color1, stroke: black,name: name + "-square" + "-" + str(i) + "-" + str(j))
    }}
  for i in range(m){
    for j in range(n){
      let x = loc.at(0) + i * size
      let y = loc.at(1) - j * size

      circle((x + size/2, y), radius: circle-radius, fill: color1, stroke: (thickness: line-thickness),name: name + "-point-vertical-" + str(i) +"-" + str(j))
      circle((x, y - size/2), radius: circle-radius, fill: color2, stroke: (thickness: line-thickness),name: name + "-point-horizontal-" + str(i) +"-" + str(j))
    }
  }
}

#let plaquette-code-label(loc, posx,posy, ver-vec:((-1,0),(-1,1)), hor-vec:((0,0),(-1,0)), size:1,circle-radius:0.2, color1:white, color2:gray, color3:yellow,line-thickness:1pt,name: "toric") = {
  import draw: *
      let x = loc.at(0) + posx * size
      let y = loc.at(1) - posy * size
  rect((x, y), (x - size, y - size), fill: color3, stroke: black,name: name + "-plaquette")
  
  circle(name+"-point-vertical-" + str(posx - 1) + "-" + str(posy),radius: circle-radius, fill: color1, stroke: (thickness: line-thickness))
  circle(name+"-point-vertical-" + str(posx - 1) + "-" + str(posy+1),radius: circle-radius, fill: color1, stroke: (thickness: line-thickness))
  circle(name+"-point-horizontal-" + str(posx) + "-" + str(posy),radius: circle-radius, fill: color2, stroke: (thickness: line-thickness))
  circle(name+"-point-horizontal-" + str(posx - 1) + "-" + str(posy),radius: circle-radius, fill: color2, stroke: (thickness: line-thickness))

  for (i,j) in ver-vec {
    circle(name+"-point-vertical-" + str(i+posx) + "-" + str(j+posy),radius: circle-radius, fill: color3, stroke: (thickness: line-thickness))
  }
  for (i,j) in hor-vec {
    circle(name+"-point-horizontal-" + str(i+posx) + "-" + str(j+posy),radius: circle-radius, fill: color3, stroke: (thickness: line-thickness))
  }
}


#let vertex-code-label(loc, posx,posy, ver-vec:((-1,0),(0,0)), hor-vec:((0,0),(0,-1)), size:1, circle-radius:0.2, color1:white, color2:gray, color3:aqua,line-thickness:1pt,name: "toric") = {
  import draw: *
  let x = loc.at(0) + posx * size
  let y = loc.at(1) - posy * size
  rect((x - circle-radius, y - circle-radius), (x + circle-radius, y + circle-radius), fill: color3, stroke: black,name: name + "-vertex")

  for (i,j) in ver-vec {
    circle(name+"-point-vertical-" + str(i+posx) + "-" + str(j+posy),radius: circle-radius, fill: color3, stroke: (thickness: line-thickness))
  }
  for (i,j) in hor-vec {
    circle(name+"-point-horizontal-" + str(i+posx) + "-" + str(j+posy),radius: circle-radius, fill: color3, stroke: (thickness: line-thickness))}
}
