#import "renderer.typ": renderer
#import "@preview/cetz:0.3.4" as cetz
#import "../anchors.typ" as anchors

// A debug renderer for cetz that draws the objects' anchors
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
    "polygon": draw-anchors,
  ))
}

// The standard renderer for cetz
#let standard = {

  let draw-rect = (obj, style: (:)) => {
    let style = (stroke: auto, fill: auto) + style

    let points = obj("anchors")
    cetz.draw.line(close: true, stroke: style.stroke, fill: style.fill,
      (points.tl.x, points.tl.y),
      (points.tr.x, points.tr.y),
      (points.br.x, points.br.y),
      (points.bl.x, points.bl.y), 
    )
  }

  let draw-circle = (obj, style: (:)) => {
    let style = (stroke: auto, fill: auto) + style
    
    let points = obj("anchors")
    cetz.draw.circle(stroke: style.stroke, fill: style.fill,
      (points.c.x, points.c.y), 
      radius: obj("data").radius
    )
  }
  
  let draw-incline = (obj, style: (:)) => {
    let style = (stroke: auto, fill: auto) + style

    let points = obj("anchors")
    cetz.draw.line(close: true, stroke: style.stroke, fill: style.fill,
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
    let style = (
      radius: if style.at("label", default: none) == none { 1 } else { 0 },
      stroke: none,
      fill: black, 
      align: center + horizon, 
      label: none,
      lx: 0,
      ly: 0,
    ) + style

    let align-to-cetz-anchor(align) = (
            if align in (left, left + horizon) { "west" }
      else if align in (right, right + horizon) { "east" }
      else if align in (center, center + horizon) { "center" }
      else if align in (top, top + center) { "north" }
      else if align in (horizon, horizon + center) { "center" }
      else if align in (bottom, bottom + center) { "south" }
      else if align == top + left { "north-west" }
      else if align == bottom + left { "south-west" }
      else if align == top + right { "north-east" }
      else if align == bottom + right { "south-east" }
      else { align }
    )

    let points = obj("anchors")
    cetz.draw.circle(stroke: style.stroke, fill: style.fill, radius: style.radius,
      (points.c.x, points.c.y)
    );

    if style.label != none {
      cetz.draw.content( 
        anchor: align-to-cetz-anchor(style.align), 
        angle: points.c.rot,
        (points.c.x + style.lx, points.c.y + style.ly), style.label
      )
    }
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

  let draw-polygon(obj, style: (:)) = {
    let style = (stroke: auto, fill: auto) + style
    
    let ancs = obj("anchors")
    return cetz.draw.line(close: true, stroke: style.stroke, fill: style.fill,
      ..for i in range(0, obj("data").count) {
        ((ancs.at(str(i + 1) + "l").x, ancs.at(str(i + 1) + "l").y), )
      }
    )
  }

  renderer((
    "rect": draw-rect,
    "circle": draw-circle,
    "incline": draw-incline,
    "arrow": draw-arrow,
    "point": draw-point,
    "rope": draw-rope,
    "polygon": draw-polygon,
  ))
}