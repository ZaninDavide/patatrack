#import "src/lib.typ" as patatrack

#let draw(..objs, debug: false) = {
  import "@preview/cetz:0.3.4" as cetz
  cetz.canvas(length: 0.5mm, {
    patatrack.renderers.cetz.wireframe(..objs).flatten()
    if debug { patatrack.renderers.cetz.debug(..objs).flatten() }
  })
}

#{
  import patatrack: *

  let (I, A, B, C) = (none,)*4;
  I = incline(150, 20deg)
  A = rect(50, 30)
  A = stick(A("bl"), I("tl"))
  A = slide(A("c"), 30, 0)
  B = slide(stick(rect(10,10)("bl"),A("tl")), -5, 0)
  C = match(circle(10)("bl"),I("rt"), rot: false)
  C = rotate(move(C, 30, 15), -23deg)

  let weight = rotate(arrow(A("c"), 40, angle: 90deg), -90deg)
  let friction = rotate(arrow(A("c"), 45), -90deg)
  let normal = arrow(A("c"), 35)
  let P = point(anchors.x-inter-y(A("c"), I("tr")))
  let Q = point(anchors.lerp(P, I("rt"), 50%))

  let C2 = move(circle(5), 10, 50)

  let my-rope = rope(A("r"), C("tr"), I("br"), C2("t"), A("bl"))
  repr(my-rope("repr"))



  draw(I, A, B, C, weight, friction, normal, P, Q, C2, my-rope, stroke: 1pt, debug: false)
}

#{
  import patatrack: *
  let inc = rotate(incline(100, 15deg), 20deg, ref: (0,0))
  let force = arrow((0,0), 100)

  draw(force, debug: true)
}

#{
  import patatrack: *
  let block = rotate(rect(40, 20), 30deg)
  let force = arrow(block("c"), 90)

  draw(block, force, debug: true)
}