#import "../src/lib.typ" as patatrac

#set page(width: 12cm, height: 6cm)
#set text(size: 15pt)

#place(center + horizon, patatrac.cetz.canvas(length: 0.5mm, {
  import patatrac: *
  let draw = patatrac.cetz.standard()
  let debug = patatrac.cetz.debug()

  let A = rect(50*1.6, 50)
  let B = place(rect(25,25)("bl"), A("br"))
  let F = place(arrow((0,0), 50, angle: 0deg)("end"), A("l"))
  let floor = move(place(rect(200, 30)("t"), A("b")), 10, 0)
  
  import "@preview/fancy-tiling:1.0.0": diagonal-stripes
  draw(floor, 
    fill: diagonal-stripes(stripe-color: luma(90%), size: 10pt, thickness-ratio: 50%), 
    stroke: none
  )
  draw(A, fill: blue, stroke: 2pt + blue.darken(60%))
  draw(B, fill: red, stroke: 2pt + red.darken(60%))
  draw(point(A("c")), label: text(fill: white, $M$), fill: white)
  draw(point(B("c")), label: text(fill: white, $m$), fill: white, align: center, ly: 1.5)
  draw(F, stroke: 2pt)
  draw(point(F("c"), rot: false), align: bottom, label: math.arrow($F$), ly: 5)
}))