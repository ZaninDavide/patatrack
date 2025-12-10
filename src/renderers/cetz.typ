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

    let points = obj("anchors")
    let radii = obj("data").radii
    let path = none

    // Utilities
    let point-circle-tangent-directions(point, center, radius) = {
      let d = anchors.distance(point, center)
      let r = radius
      let alpha = calc.asin(r / d)
      let theta = calc.atan2(center.x - point.x, center.y - point.y)
      let beta1 = -90deg + theta - alpha
      let beta2 = +90deg + theta + alpha
      return (beta1, beta2)
    }
    let zero-threesixty-angle(angle) = 1deg * calc.rem(calc.rem(angle/1deg, 360) + 360, 360)
    let angle-between-angles(angle1, angle2, clockwise: false) = {
      // Finds positive angle you have to travel from angle1 to reach angle2
      let angle1 = zero-threesixty-angle(angle1)
      let angle2 = zero-threesixty-angle(angle2)
      // Assume counter-clockwise
      let delta = if angle2 > angle1 { angle2 - angle1 } else { 360deg - (angle1 - angle2) }
      // Handle clockwise
      if clockwise { delta = 360deg - delta }
      return delta
    }

    let i = 0
    let tip = none // tip of the pen
    while i < obj("data").count {
      let current = points.at(str(i))
      let current-radius = radii.at(str(i))
      let after = if i + 1 < obj("data").count { points.at(str(i + 1)) } else { none }
      let after-radius = if i + 1 < obj("data").count { radii.at(str(i + 1)) } else { none }
      
      if tip == none {
        // This is the first point: position the tip and do nothing
        tip = current

      } else if after == none {
        // This is the last point: draw to it
        path += cetz.draw.line((tip.x, tip.y), (current.x, current.y))
        tip = current

      } else if current-radius == 0 {
        // This point has zero radius: draw to it
        path += cetz.draw.line((tip.x, tip.y), (current.x, current.y))
        tip = current

      } else if current-radius != 0 {
        // This point has a finite radius: draw
        //  (1) straight line from tip to in-point
        //  (2) arc from in-point to out-point

        // Find possible in-going directions
        let (beta1, beta2) = point-circle-tangent-directions(tip, current, current-radius)
        beta1 = zero-threesixty-angle(beta1)
        beta2 = zero-threesixty-angle(beta2)

        // Choose ingoing direction according to anchor's rotation
        let beta = if (
          calc.abs(beta1 - zero-threesixty-angle(current.rot)) <
          calc.abs(beta2 - zero-threesixty-angle(current.rot))
        ) { beta1 } else { beta2 }
        
        // Find in-point on the circle
        let in-point = anchors.slide(current, current-radius, 0, rot: beta)

        // Draw (1)
        path += cetz.draw.line((tip.x, tip.y), (in-point.x, in-point.y))

        // Determine if we are traveling clockwise or counter-clockwise
        let clockwise = {
          let tip-to-current = anchors.term-by-term-difference(current, tip)
          let tip-to-in-point = anchors.term-by-term-difference(in-point, tip)
          let cross-product = tip-to-current.x*tip-to-in-point.y - tip-to-current.y*tip-to-in-point.x
          cross-product > 0
        } 

        // Find the possible outgoing directions
        if after-radius == 0 {
          // The next point is a point of zero radius
          
          // Find the possible out-going directions
          let (gamma1, gamma2) = point-circle-tangent-directions(after, current, current-radius)
          gamma1 = zero-threesixty-angle(gamma1)
          gamma2 = zero-threesixty-angle(gamma2)

          let out-point1 = anchors.slide(current, current-radius, 0, rot: gamma1)
          let out-point2 = anchors.slide(current, current-radius, 0, rot: gamma2)

          // Choose the out-going direction that matches in and out clockwise/counter-clockwise
          let clockwise1 = {
            let after-to-out-point = anchors.term-by-term-difference(out-point1, after)
            let after-to-current = anchors.term-by-term-difference(current, after)
            let cross-product = after-to-current.x*after-to-out-point.y - after-to-current.y*after-to-out-point.x
            cross-product < 0 // inverse that before since we go out not in this time
          }
          // let clockwise2 = not(clockwise1)

          // Choose the out-going direction which minimizes the arc length
          let gamma = if clockwise == clockwise1 { gamma1 } else { gamma2 }
          let out-point = if clockwise == clockwise1 { out-point1 } else { out-point2 }

          // Find mid-point on the circle
          let delta = angle-between-angles(beta, gamma, clockwise: clockwise)
          if clockwise { delta *= -1 }
          let mid-point = anchors.slide(current, current-radius, 0, rot: beta + delta/2)

          // Draw (2)
          path += cetz.draw.arc-through(
            (in-point.x, in-point.y), // start
            (mid-point.x, mid-point.y), // mid
            (out-point.x, out-point.y) // end
          )

          tip = out-point
        } else {
          // The next point is another circle
          panic("TODO")
        }
      }

      i += 1
    }

    return cetz.draw.merge-path(path, stroke: style.stroke + blue)
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