// -----------------------------> SHAPES
// This file contains the object constructors for all objects that have a 2D surface:
//  - rect
//  - circle
//  - incline
//  - polygon
//

#import "../anchors.typ" as anchors: anchor, to-anchor
#import "object.typ": object

/*
Creates an object of type "rectangle" centered at the origin with the given width and height
*/
#let rect(width, height) = object("rect", "c",
  (
    "c": anchor(width*0, height*0, 0deg), // do not use (0,0) which would assume unitless coordinates

    "tl": anchor(-width/2, +height/2, 0deg),
    "t": anchor(0*width, +height/2, 0deg),
    "tr": anchor(+width/2, +height/2, 0deg),

    "lt": anchor(-width/2, +height/2, 90deg),
    "l": anchor(-width/2, 0*height, 90deg),
    "lb": anchor(-width/2, -height/2, 90deg),
    
    "bl": anchor(-width/2, -height/2, 180deg),
    "b": anchor(0*width, -height/2, 180deg),
    "br": anchor(+width/2, -height/2, 180deg),

    "rt": anchor(+width/2, +height/2, 270deg),
    "r": anchor(+width/2, 0*height, 270deg),
    "rb": anchor(+width/2, -height/2, 270deg),
  ),
  data: ("width": width, "height": height)
)

/*
Creates an object of type "circle" centered at the origin with the given radius
*/
#let circle(radius) = {
  let sqrt2 = calc.sqrt(2)
  return object("circle", "c", data: ("radius": radius), (
    "c": anchor(radius*0, radius*0, 0deg), // do not use (0,0) which would assume unitless coordinates
    
    "t": anchor(radius*0, +radius, 0deg),

    "lt": anchor(-radius/sqrt2, +radius/sqrt2, 45deg),
    "tl": anchor(-radius/sqrt2, +radius/sqrt2, 45deg),
    
    "l": anchor(-radius, radius*0, 90deg),
    
    "bl": anchor(-radius/sqrt2, -radius/sqrt2, 90deg+45deg),
    "lb": anchor(-radius/sqrt2, -radius/sqrt2, 90deg+45deg),
    
    "b": anchor(radius*0, -radius, 180deg),

    "rb": anchor(+radius/sqrt2, -radius/sqrt2, 180deg+45deg),
    "br": anchor(+radius/sqrt2, -radius/sqrt2, 180deg+45deg),
    
    "r": anchor(+radius, radius*0, 270deg),

    "tr": anchor(+radius/sqrt2, +radius/sqrt2, 270deg+45deg-360deg),
    "rt": anchor(+radius/sqrt2, +radius/sqrt2, 270deg+45deg-360deg),
  ))
}

/*
Creates an object of type "incline". It represents a right-angle triangle
with base of length `width` and base to hypotenuse angle of |`angle`|.
The parameter `angle` can be 
 - in the range (0, 90deg): the incline goes upward moving clockwise on the surface,
 - in the range (-90deg, 0): the incline goes downward moving clockwise on the surface.
*/
#let incline(width, angle) = {
  if angle > 90deg or angle < -90deg {
    panic("Incline angle must be between -90deg and 90deg")
  } else if angle > 0deg {
    return object("incline", "bl", 
      (
        "tl": anchor(width*0, width*0, angle),
        "t":  anchor(width/2, width/2*calc.tan(angle), angle),
        "tr": anchor(width, width*calc.tan(angle), angle),
        
        "rt": anchor(width, width*calc.tan(angle), -90deg),
        "r":  anchor(width, width/2*calc.tan(angle), -90deg),
        "rb": anchor(width, width*0, -90deg),
        
        "bl": anchor(width*0, width*0, 180deg),
        "b": anchor(width/2, width*0, 180deg),
        "br": anchor(width, width*0, 180deg),
      ), 
      data: (
        "width": width, 
        "height": width*calc.tan(angle), 
        "angle": angle
      )
    ) 
  } else if angle < 0deg {
    panic("TODO")
  }
}

/*
Creates an object of type `polygon`. It represents a 2D closed shape
whose contour passes through the specified anchors. Conventionally,
the anchors should be given in clockwise order.
*/
#let polygon(..args) = {
  let points = args.pos().map(to-anchor)

  if points.len() < 3 {
    panic("A polygon is a shape made of at least three vertices but " + str(points.len()) + " where given.")
  }

  let ancs = (:)

  for i in range(0, points.len()) {
    let current = points.at(i)
    let after = points.at(i + 1, default: points.first())
    let middle = anchors.lerp(current, after, 50%)

    let left = anchors.x-look-from(current, after)
    let center = anchors.anchor(middle.x, middle.y, left.rot)
    let right = anchors.anchor(after.x, after.y, left.rot)

    ancs.insert(str(i + 1) + "l", left)
    ancs.insert(str(i + 1), center)
    ancs.insert(str(i + 1) + "r", right)
  }

  return object("polygon", "1", ancs, data: (count: points.len()))
}