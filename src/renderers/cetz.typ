#import "renderer.typ": renderer
#import "@preview/cetz:0.3.4" as cetz
#import "../anchors.typ" as anchors

#let wireframe = {

  let draw-rect = (obj, style: (:)) => {
    let style = (stroke: auto) + style

    let points = obj("anchors")
    cetz.draw.line(close: true, stroke: style.stroke,
      (points.tl.x, points.tl.y),
      (points.tr.x, points.tr.y),
      (points.br.x, points.br.y),
      (points.bl.x, points.bl.y), 
    )
  }

  let draw-circle = (obj, style: (:)) => {
    let style = (stroke: auto) + style
    
    let points = obj("anchors")
    cetz.draw.circle(stroke: style.stroke,
      (points.c.x, points.c.y), 
      radius: obj("data").radius
    )
  }
  
  let draw-incline = (obj, style: (:)) => {
    let style = (stroke: auto) + style

    let points = obj("anchors")
    cetz.draw.line(close: true, stroke: style.stroke,
      (points.tr.x, points.tr.y),
      (points.tl.x, points.tl.y),
      (points.br.x, points.br.y),
    )
  }
  
  let draw-arrow = (obj, style: (:)) => {
    let style = (stroke: auto) + style

    let points = obj("anchors")
    cetz.draw.line(stroke: style.stroke,
      (points.start.x, points.start.y),
      (points.end.x, points.end.y),
      mark: (end: "stealth", fill: black),
    )
  }
  
  let draw-point = (obj, style: (:)) => {
    let style = (fill: black) + style

    let points = obj("anchors")
    cetz.draw.circle(stroke: none, fill: style.fill, radius: 1,
      (points.c.x, points.c.y)
    );
  }
  
  let draw-rope = (obj, style: (:)) => {
    let style = (stroke: auto) + style

    let path = none

    let ancs = obj("anchors")
    let radii = obj("data").radii
    let count = obj("data").count

    let tip = none
    for i in range(0, count) {
      let id = str(i + 1)
      if tip == none {
        // This is the first point: 
        // position the tip and do nothing
        tip = ancs.at(id)
      } else if i == count - 1 or radii.at(id) == 0 {
        // This is the last point or this point has zero radius: 
        // draw to it and position the tip
        path += cetz.draw.line((tip.x, tip.y), (ancs.at(id).x, ancs.at(id).y))
        tip = ancs.at(id)
      } else if radii.at(id) != 0 {
        // This point has a finite radius:
        //  - draw a straight line from tip to in-point
        //  - draw an arc from in-point to out-point  
        //  - position the tip
        path += cetz.draw.line((tip.x, tip.y), (ancs.at(id + "i").x, ancs.at(id + "i").y))
        path += cetz.draw.arc-through(
          (ancs.at(id + "i").x, ancs.at(id + "i").y),
          (ancs.at(id + "m").x, ancs.at(id + "m").y),
          (ancs.at(id + "o").x, ancs.at(id + "o").y),
        )
        tip = ancs.at(id + "o")
      }    
    }

    return cetz.draw.merge-path(path, stroke: style.stroke)
  }

  renderer((
    "rect": draw-rect,
    "circle": draw-circle,
    "incline": draw-incline,
    "arrow": draw-arrow,
    "point": draw-point,
    "rope": draw-rope,
  ))
}

#let debug = {
  let draw-anchors(obj, style: (:)) = {
    for anc in obj("anchors").values() {
      // normal
      cetz.draw.line(
        (anc.x, anc.y),
        (
          (anc.x + 5*calc.cos(anc.rot+90deg)), 
          (anc.y + 5*calc.sin(anc.rot+90deg))
        ),
        stroke: 1pt + green,
      )
      // tangent
      cetz.draw.line(
        (anc.x, anc.y),
        (
          (anc.x + 2*calc.cos(anc.rot)), 
          (anc.y + 2*calc.sin(anc.rot))
        ),
        stroke: 1pt + red,
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
  ))
}