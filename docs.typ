#import "src/lib.typ" as patatrack
#import "@preview/cetz:0.3.4" as cetz: canvas

#set text(size: 15pt)

#canvas(length: 0.5mm, {
  import "src/lib.typ" as patatrack: *
  let draw = patatrack.renderers.cetz.standard

  let (A, B, F) = 3 * (none, )
  A = rect(50*1.6, 50)
  B = place(rect(25,25)("bl"), A("br"))
  F = place(arrow((0,0), 50, angle: 0deg)("end"), A("l"))
  let floor = move(place(rect(200, 30)("t"), A("b")), 10, 0)
  
  draw(floor, fill: luma(90%), stroke: none)
  draw(A, fill: blue, stroke: 2pt + blue.darken(60%))
  draw(B, fill: red, stroke: 2pt + red.darken(60%))
  draw(point(A("c")), label: text(fill: white, $M$), fill: white)
  draw(move(point(B("c")), 0, 1.5), label: text(fill: white, $m$), fill: white, align: center)
  draw(F, stroke: 2pt)
  draw(point(F("c"), rot: false), align: bottom, label: pad(math.arrow($F$), 5pt))

}.flatten())


#canvas(length: 0.5mm, {
  import "src/lib.typ" as patatrack: *
  let draw = patatrack.renderers.cetz.standard

  let sideA = 20
  let sideB = 15
  let radiusC = 5
  let hang = 15

  let I = incline(150, 25deg)

  let A = rect(sideA,sideA)
  A = stick(A("bl"), I("tl"))
  A = slide(A, -40, 0)

  let centerC = anchors.slide(I("tr")(), hang, sideA/2 - radiusC)
  let C = place(circle(radiusC), centerC)
  let L = rope(C(), I("tr"))
  
  let B = move(place(rect(sideB, sideB), C("r")), 0, -40)
  let R = rope(A("r"), C("t"), B("t"))

  draw(L, R, stroke: 2pt)
  draw(I, C, stroke: 2pt, fill: luma(90%))
  
  let tension1 = rotate(arrow(R("start"), 20), -90deg)
  let tension2 = rotate(arrow(R("end"), 20), 90deg)
  
  draw(tension1, tension2, stroke: 2pt)
  draw(point(tension1("end"), rot: false), lx: -8, ly: 2, label: math.arrow($T_1$), align: bottom)
  draw(point(tension2("c"), rot: false), lx: 10, label: math.arrow($T_2$), align: bottom)
  draw(point(C("c")))

  draw(A, fill: blue, stroke: 2pt + blue.darken(60%))
  draw(B, fill: red, stroke: 2pt + red.darken(60%))
  draw(point(A("c")), label: text(fill: white, $M$))
  draw(move(point(B("c")), 0, 1), label: text(fill: white, $m$))
  
}.flatten())

#canvas(length: 0.5mm, {
  import "src/lib.typ" as patatrack: *
  let draw = patatrack.renderers.cetz.standard

  let ceiling = move(rect(130, 10), 30, 5)
  let radius = 15

  let C1 = move(circle(radius), 50, -30)
  let A = move(place(rect(15, 15), C1("r")), 0, -60)
  let L1 = rope(C1, anchors.y-inter-x(C1, ceiling("bl")))

  let C2 = circle(radius)
  C2 = stick(C2("r"), C1("l"))
  C2 = move(C2, 0, -50)

  let C3 = circle(radius)
  C3 = place(C3("r"), C2("c"))
  C3 = move(C3, 0, -50)

  let rope23 = rope(C2("c"), C3, (C3("l")().x, 0))
  let rope12 = rope(A("c"), C1("r"), C2("r"), (C2("l")().x, 0))

  let B = rect(20, 20)
  B = place(B, C3("c"))
  B = move(B, 0, -40)
  let ropeB = rope(B, C3("c"))

  draw(C1, C2, C3, stroke: 2pt)
  draw(rope12, stroke: 2pt + red.darken(30%))
  draw(rope23, stroke: 2pt + blue.darken(30%))
  draw(L1, ropeB, stroke: 2pt)
  draw(A, fill: red, stroke: 2pt + red.darken(30%))
  draw(B, fill: blue, stroke: 2pt + blue.darken(30%))

  let tensionA1 = arrow(A("t"), 20)
  let tensionA2 = arrow(C1("r"), 20, angle: -90deg)
  draw(stroke: 2pt + red.darken(30%),
    tensionA1, tensionA2,
    place(tensionA1, C2("r")),
    place(tensionA1, C2("l")),
    place(tensionA2, rope12("end")),
    place(tensionA2, C1("l")),
  )

  let tensionB1 = arrow(rope23("start"), 20, angle: -90deg)
  let tensionB2 = arrow(C3("r"), 20, angle: +90deg)
  draw(stroke: 2pt + blue.darken(30%),
    tensionB1,
    place(tensionB1, rope23("end")),
    tensionB2,
    place(tensionB2, C3("l"))
  )

  draw(point(rope23("end"), rot: false), label: math.arrow($T_1$), align: top + right, lx: -3, ly: -10)
  draw(point(tensionA1("end"), rot: false), label: math.arrow($T_2$), align: left, lx: 5, ly: -5)
  draw(point(C1("c")), point(C2("c")), point(C3("c")), radius: 2)
  draw(point(A("c")), label: text(fill: white, $m$), ly: 1)
  draw(point(B("c")), label: text(fill: white, $M$))
  draw(ceiling, fill: luma(90%), stroke: 2pt)

}.flatten())

/*
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
  let C3 = move(circle(20), -40, -10)
  let C4 = move(circle(10), 20, -50)

  let my-rope = rope(A("r"), C("tr"), I("br"), C2("t"), C3("r"), C4("t"), I("bl"), (20, -10))

  draw(I, A, B, C, weight, friction, normal, P, Q, C2, C3, C4, my-rope, stroke: 1pt)
}

#{
  import patatrack: *
  let C = move(circle(10), 50, 50)
  let R = rope((0,0), C("b"), (100, 150), (100, 0))
  let F1 = rotate(arrow(R("2i"), 30), +90deg)
  let F2 = rotate(arrow(R("2o"), 30), -90deg)
  let F3 = arrow(R("2m"), 35)
  draw(C, R, F1, F2, F3, debug: false)
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

#{
  import patatrack: *
  draw(rect(10, 10))
  draw(point((10, 10)), label: "Hello", align: "text")
}
*/
