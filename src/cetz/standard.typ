#import "../renderer.typ": renderer
#import "../anchors.typ" as anchors
#import "cetz.typ" as cetz

// The standard renderer for cetz
#let standard = {
  let draw-rect(obj, style) = {
    let style = (stroke: auto, fill: auto) + style

    let points = obj("anchors")
    cetz.draw.line(close: true, stroke: style.stroke, fill: style.fill,
      (points.tl.x, points.tl.y),
      (points.tr.x, points.tr.y),
      (points.br.x, points.br.y),
      (points.bl.x, points.bl.y), 
    )
  }

  let draw-circle(obj, style) = {
    let style = (stroke: auto, fill: auto) + style
    
    let points = obj("anchors")
    cetz.draw.circle(stroke: style.stroke, fill: style.fill,
      (points.c.x, points.c.y), 
      radius: obj("data").radius
    )
  }
  
  let draw-incline(obj, style) = {
    let style = (stroke: auto, fill: auto) + style

    let points = obj("anchors")
    cetz.draw.line(close: true, stroke: style.stroke, fill: style.fill,
      (points.tr.x, points.tr.y),
      (points.tl.x, points.tl.y),
      (points.br.x, points.br.y),
    )
  }
  
  let draw-arrow(obj, style) = {
    let paint = stroke(style.at("stroke", default: black)).paint
    let style = (
      stroke: auto, 
      mark: (end: "triangle", fill: if paint == auto { black } else { paint }),
    ) + style


    let points = obj("anchors")
    cetz.draw.line(stroke: style.stroke, mark: style.mark,
      (points.start.x, points.start.y),
      (points.end.x, points.end.y),
    )
  }
  
  let draw-point(obj, style) = {
    let style = (
      radius: if style.at("label", default: none) == none { 1 } else { 0 },
      stroke: none,
      fill: black, 
      align: center + horizon, 
      label: none,
      lx: 0 * obj().x,
      ly: 0 * obj().x,
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
  
  let draw-rope(obj, style) = {
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

  let draw-polygon(obj, style) = {
    let style = (stroke: auto, fill: auto) + style
    
    let ancs = obj("anchors")
    return cetz.draw.line(close: true, stroke: style.stroke, fill: style.fill,
      ..for i in range(0, obj("data").count) {
        ((ancs.at(str(i + 1) + "l").x, ancs.at(str(i + 1) + "l").y), )
      }
    )
  }

  let draw-spring(obj, style) = {
    let style = (
      stroke: auto, 
      pitch: auto, // distance between windings
      n: auto, // number of windings
      pad: auto, // length of flat bit at the start and at the end
      radius: auto, // size of the windings
      curliness: 70%, // set to none for a zig-zag pattern
    ) + style

    if style.pitch == auto and style.n == auto {
      // Default to 10 revolutions
      style.n = 10
    } else if style.pitch != auto and style.n != auto {
      panic("At least one between `n` and `pitch` has to be set to `auto`, but neither is.")
    }

    // Choose a radius
    if style.radius == auto {
      if style.pitch != auto { style.radius = style.pitch }
      else if style.n != auto { style.radius = obj("data").length / style.n * 1.25 }
    }
    // Choose a padding
    if style.pad == auto { style.pad = style.radius * 0.6 }

    // Calculate space to cover with the zig-zag pattern
    let free = obj("data").length - style.pad*2

    // Calculate number of windings or pitch if necessary
    if style.pitch != auto {
      style.n = calc.floor(free / style.pitch)
      // Compensate with extra padding for non integer free/pitch ratios
      style.pad += (free - style.pitch*style.n) / 2
    } else {
      style.pitch = free / style.n
    }

    // Actually draw the string
    let ancs = obj("anchors")

    let u = (x: +calc.cos(ancs.start.rot), y: calc.sin(ancs.start.rot))
    let v = (x: -u.y, y: u.x)

    let padded-start = (x: ancs.start.x + u.x*style.pad, y: ancs.start.y + u.y*style.pad)
    let padded-end = (x: ancs.end.x - u.x*style.pad, y: ancs.end.y - u.y*style.pad)

    if style.curliness == none {
      return cetz.draw.line(stroke: style.stroke,
        // padding
        (ancs.start.x, ancs.start.y),
        (padded-start.x, padded-start.y),
        ..for i in range(0, style.n) {(
          // higher point
          (
            x: padded-start.x + style.pitch*i*u.x + style.pitch/4*u.x + style.radius*v.x, 
            y: padded-start.y + style.pitch*i*u.y + style.pitch/4*u.y + style.radius*v.y,
          ),      
          // lower point
          (
            x: padded-start.x + style.pitch*i*u.x + style.pitch*3/4*u.x - style.radius*v.x, 
            y: padded-start.y + style.pitch*i*u.y + style.pitch*3/4*u.y - style.radius*v.y,
          )
        )},
        // half down
        // padding
        (padded-end.x, padded-end.y),
        (ancs.end.x, ancs.end.y),
      )
    } else {
      let delta = (style.curliness/100% + 1)*style.pitch/2
      let transformed(x, y) = (padded-start.x + u.x * x + v.x * y, padded-start.y + u.y * x + v.y * y)
      return cetz.draw.merge-path({
        cetz.draw.line(
          (ancs.start.x, ancs.start.y),
          (padded-start.x, padded-start.y)
        )
        cetz.draw.bezier(
          transformed(0,0), 
          transformed(style.pitch/2, -style.radius),
          transformed(0, -style.radius)
        )
        for k in range(1, style.n) {
          cetz.draw.bezier(
            transformed(style.pitch*(k - 1/2),-style.radius), 
            transformed(style.pitch*(k      ), +style.radius), 
            transformed(style.pitch*(k - 1/2) + delta, -style.radius), 
            transformed(style.pitch*(k - 1/2) + delta, +style.radius)
          )
          cetz.draw.bezier(
            transformed(style.pitch*(k    ), +style.radius), 
            transformed(style.pitch*(k+1/2), -style.radius), 
            transformed(style.pitch*(k+1/2) - delta, +style.radius), 
            transformed(style.pitch*(k+1/2) - delta, -style.radius)
          )
        }
        cetz.draw.bezier(
          transformed(style.pitch*(style.n - 1/2), -style.radius), 
          transformed(style.pitch*(style.n      ), 0),
          transformed(style.pitch*(style.n      ), -style.radius),
        )
        cetz.draw.line(
          (padded-end.x, padded-end.y),
          (ancs.end.x, ancs.end.y),
        )
      })
    }
  }

  renderer((
    rect: draw-rect,
    circle: draw-circle,
    incline: draw-incline,
    arrow: draw-arrow,
    point: draw-point,
    rope: draw-rope,
    polygon: draw-polygon,
    spring: draw-spring,
  ))
}