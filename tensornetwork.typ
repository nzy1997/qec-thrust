#import "@preview/cetz:0.3.4": canvas,draw

#figure(canvas({
  import draw: *
  
  let r = 0.5
  for j in range(7) {
    circle((2*j,0), radius: r, fill: aqua, stroke: black,name: "x-" + str(j+1))

    circle((2*j,3), radius: r, fill: yellow, stroke: black,name: "z-" + str(j+1))

    rect((2*j - r, 1), (2*j + r, 1+2*r), fill: green, stroke: black, name: "rect-" + str(j+1))

    line("x-" + str(j+1), "rect-" + str(j+1), stroke: black)

    line("z-" + str(j+1), "rect-" + str(j+1), stroke: black)
  }

  for j in range(7) {
    content((rel: (0, 0), to: "x-" + str(j+1)), [#(j+1)])
    content((rel: (0, 0), to: "z-" + str(j+1)), [#(j+1)])
  }

  let checkv = ((1,2,5,7), (2,3,6,7), (4,5,6,7))
  for k in range(3) {
    rect((3*(k+1) - r, 5), (3*(k+1) + r, 5+2*r), fill: purple, stroke: black, name: "xcheck-t-" + str(k+1))
    circle((3*(k+1), 7 + r), radius: r, fill: silver, stroke: black, name: "xcheck-" + str(k+1))
    line("xcheck-t-" + str(k+1), "xcheck-" + str(k+1), stroke: black)
    for i in checkv.at(k) {
      line("xcheck-t-" + str(k+1), "z-" + str(i), stroke: black)
    }
  }

  for k in range(3) {
    rect((3*(k+1) - r, -3), (3*(k+1) + r, -3+2*r), fill: purple, stroke: black, name: "zcheck-t-" + str(k+1))
    circle((3*(k+1), -5 + r), radius: r, fill: gray, stroke: black, name: "zcheck-" + str(k+1))
    line("zcheck-t-" + str(k+1), "zcheck-" + str(k+1), stroke: black)
    for i in checkv.at(k) {
      line("zcheck-t-" + str(k+1), "x-" + str(i), stroke: black)
    }
  }

  rect((-r,5), (+r,5+2*r), fill: purple, stroke: black, name: "xlogical-t-0")
  circle((0,7 + r), radius: r, fill: maroon, stroke: black, name: "xlogical-0")
  line("xlogical-t-0", "xlogical-0", stroke: black)
  rect((-r,-3), (+r,-3+2*r), fill: purple, stroke: black, name: "zlogical-t-0")
  circle((0,-5 + r), radius: r, fill: navy, stroke: black, name: "zlogical-0")
  line("zlogical-t-0", "zlogical-0", stroke: black)

  for k in range(3) {
    line("xlogical-t-0", "z-" + str(k+1), stroke: black)
    line("zlogical-t-0", "x-" + str(k+1), stroke: black)
  }

  circle((15,7+r), radius: r, fill: none, stroke: black, name: "edge-label")
  content((rel: (3, 0), to: "edge-label"), [Variable])

  circle((15,5+r), radius: r, fill: aqua, stroke: black, name: "xqubit-label")
  content((rel: (3, 0), to: "xqubit-label"), [$X$ error])

  circle((15,3+r), radius: r, fill: yellow, stroke: black, name: "zqubit-label")
  content((rel: (3, 0), to: "zqubit-label"), [$Z$ error])

  circle((15, 1 + r), radius: r, fill: silver, stroke: black, name: "xcheck-label")
  content((rel: (3, 0), to: "xcheck-label"), [$X$ check])

  circle((15, -1 + r), radius: r, fill: gray, stroke: black, name: "zcheck-label")
  content((rel: (3, 0), to: "zcheck-label"), [$Z$ check])

  circle((15, -3 + r), radius: r, fill: maroon, stroke: black, name: "xlogical-label")
  content((rel: (3, 0), to: "xlogical-label"), [$X$ Logical Operator])

  circle((15, -5 + r), radius: r, fill: navy, stroke: black, name: "zlogical-label")
  content((rel: (3, 0), to: "zlogical-label"), [$Z$ Logical Operator])


  rect((0 - r, -8), (0+r, -8+2*r), fill: none, stroke: black, name: "tensor-label")
  content((rel: (0, -1), to: "tensor-label"), [Tensor])

  rect((4 - r, -8), (4 + r, -8 + 2 * r), fill: green, stroke: black, name: "rect-label")
  content((rel: (0, -1), to: "rect-label"), [Depolarization Probability])

  rect((8 - r, -8), (8 + r, -8 + 2 * r), fill: purple, stroke: black, name: "check-label")
  content((rel: (0, -1), to: "check-label"), [Parity Tensor])
}))


#figure(canvas({
  import draw: *

  let r = 0.5
  rect((0 - r, 0), ( r, 2 * r), fill: green, stroke: black, name: "rect-label")
  line("rect-label",(rel: (0, -1), to: "rect-label"), stroke: black)
  line("rect-label",(rel: (0, 1), to: "rect-label"), stroke: black)
  content((rel: (3, -0.2), to: "rect-label"), text(25pt)[$= mat(p_I, p_Z ;p_X, p_Y)$])

  rect((8 - r, 0), ( 8 + r, 2 * r), fill: purple, stroke: black, name: "check-label")

  line("check-label",(rel: (0, 1.2), to: "check-label"), stroke: black)
  content((rel: (0, 1.6), to: "check-label"), text(15pt)[$j_1$])

  line("check-label",(rel: (1.2, 0), to: "check-label"), stroke: black)
  content((rel: (1.6, 0), to: "check-label"), text(15pt)[$j_2$])

  line("check-label",(rel: (1, -1), to: "check-label"), stroke: black)
  content((rel: (1.4, -1.4), to: "check-label"), text(15pt)[$j_3$])

  line("check-label",(rel: (-1, -1), to: "check-label"), stroke: black)
  content((rel: (-1.4, -1.4), to: "check-label"), text(15pt)[$j_k$])

  content((rel: (0, -1.1), to: "check-label"), text(25pt)[$...$])

  content((rel: (2.1, 0.2), to: "check-label"), text(30pt)[$:$])

  content((rel: (7.1, 0), to: "check-label"), text(18pt)[$T_(j_1 j_2 j_3...j_k) = (j_1 + j_2 + ... + j_k) % 2
 $])
}))