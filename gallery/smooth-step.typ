#import "../src/lib.typ" as patatrac

#set page(width: 8cm, height: 4cm)
#set text(size: 15pt)

#place(center + horizon, patatrac.cetz.canvas(length: 0.5mm, {
  import patatrac: *
  let draw = cetz.standard(
    rect: style => {
      if "color" in style {
        style.fill = style.color
        style.stroke = 2pt + style.color.darken(60%)
      }
      style
    }
  )
  let debug = cetz.debug()
  
  let factor = 2
  let floor = terrain(scale: 30, A: 20%, B: 80%,
    x => if x < 0 { 1.5 } 
    else if x > factor { 0.5 } 
    else { 1.5 - 3*x*x/factor/factor + 2*x*x*x/factor/factor/factor }, (-1, 3)
  )
  let ball1 = stick(circle(7)("b"), floor("A"))
  let ball2 = stick(circle(7)("b"), floor("B"))
  let velocity1 = rotate(arrow(ball1("c"), 20), -90deg)
  let velocity2 = rotate(arrow(ball2("c"), 40), -90deg)

  draw(floor, smooth: false)
  draw(ball1, ball2)
  draw(velocity1, velocity2,
    mark: (end: "triangle", fill: black, scale: 0.75)
  )
  draw(point(velocity1("c"), rot: false), label: $std.math.arrow(v)_1$, lx: 0, ly: 7)
  draw(point(velocity2("c"), rot: false), label: $std.math.arrow(v)_2$, lx: 0, ly: 7)
}))