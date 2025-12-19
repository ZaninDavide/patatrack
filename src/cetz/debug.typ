#import "../renderer.typ": renderer
#import "../anchors.typ" as anchors
#import "cetz.typ" as cetz

// A debug renderer for cetz that draws the objects' anchors
#let debug = {
  let draw-anchors(obj, style) = {
    for (key, anc) in obj("anchors") {
      let factor = if key == obj("active") { 1.5 } else { 1 }
      // normal
      cetz.draw.line(
        (anc.x, anc.y),
        (
          (anc.x + 5*factor*calc.cos(anc.rot+90deg)), 
          (anc.y + 5*factor*calc.sin(anc.rot+90deg))
        ),
        stroke: 1pt*factor + green,
      )
      // tangent
      cetz.draw.line(
        (anc.x, anc.y),
        (
          (anc.x + 2*factor*calc.cos(anc.rot)), 
          (anc.y + 2*factor*calc.sin(anc.rot))
        ),
        stroke: 1pt*factor + red,
      )
    }
  };

  renderer((
    "rect": draw-anchors,
    "circle": draw-anchors,
    "incline": draw-anchors,
    "arrow": draw-anchors,
    "point": draw-anchors,
    "rope": draw-anchors,
    "polygon": draw-anchors,
    "spring": draw-anchors,
  ))
}