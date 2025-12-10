// -----------------------------> INDEX
// The objects constructors provided by the package are
//  - rect
//  - circle
//  - incline
//  - arrow
//  - point
//  - rope
//
// This file contains all the object constructors provided by the package. 

#import "anchors.typ" as anchors: anchor, to-anchor
#import "core.typ": object

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
Creates an object of type "arrow", representing an arrow
pointing from the location of the anchor `start` towards the normal
direction to `start` of total length `length`. If `angle` is not `none`
the anchor rotation is ignored and `angle` is used instead.
*/
#let arrow(start, length, angle: none) = {
  let start = to-anchor(start) 
  if angle != none { start = anchor(start.x, start.y, angle) }
  return object("arrow", "start", 
    (
      "start": start,
      "end": anchors.slide(start, length*0, length),
    ),
    data: ("length": length)
  )
}

#let point(at, rot: true) = {
  let anc = to-anchor(at)
  if not rot { anc = anchor(anc.x, anc.y, 0deg) }
  return object("point", "c", ("c": anc))
}

/*
Creates an object of type `rope`, representing a one dimensional string that wraps around
points and circles. 

Abstractly, a `rope` is completely specified by its anchors
and an associated list of non-negative radii associated with each anchor. The anchors 
location specify the points the rope wraps around and the associated radii specify 
the distance the rope keeps from the before mentioned points. The anchors rotation is
used to determine in which direction the rope must go around the points. If the anchor
has a zero radii that the rope passes through the anchor's location. If the anchor is 
the first or last anchor, the rope passes through the anchor's location even if a 
non-zero radii is specified. If the rope can wrap around an anchors' location with 
positive radii in two ways than the rotation of the anchor dictates the direction in 
which the rope wraps around it. Every way of going around the circle has a unique
starting point where the straight line becomes a curve. Each of this points lies
on the circumference described by the anchor location and radius.
Therefore each of this points describes an outgoing direction looking from the
center of the circle. The wrap-around direction chosen is the one whose starting 
outgoing direction is best aligned with the normal of the anchors.
_Intuitively, the rope wants to wrap from the direction pointed by anchors rotation_.
The heavy lifting of computing the wrapping is done by whatever drawing function
will create the drawing: the rope object itself is just a container of information.

This `rope(...)` function takes an arbitrary number of parameters. Every argument
specifies an anchor and its associated radii. In order to specify an anchor with 
an associated radii of zero, anything that can be converted to an anchor is fine, 
but if an anchor of non-zero radii is desired than a `circle` is required: the 
anchor's location is taken to be the circles center, the anchor's rotation is taken 
to be the rotation of the active anchor of the circle and the wrap-around radius 
is taken to be the circle's radius. The function returns an object of type `"rope"` with the 
inputted anchors as anchors and the associated radii stored in the metadata. 
The anchors names are consecutive numbers, starting from 0, converted to string. 
The first and last anchors appear twice: also renamed "start" and "end" respectively.
*/
#let rope(..args) = {
  let nodes = args.pos()

  if nodes.len() < 2 { panic("The function `rope` expects at least 2 positional arguments") }

  let ancs = (:)
  let radii = (:)

  for (i, node) in nodes.enumerate() {
    if type(node) == function and node("type") == "circle" {
      // this is a circle
      let anchor = node("anchors").at("c") // located at the circle's center
      anchor.rot = node().rot // rotated as the active anchor
      ancs.insert(str(i), anchor)
      radii.insert(str(i), node("data").radius)
    } else {
      // assume this can be converted to an anchor (radius = 0)
      let anc = anchors.to-anchor(node)
      ancs.insert(str(i), anc)
      radii.insert(str(i), anc.x*0)
    }
  }

  ancs.insert("start", ancs.at("0"))
  radii.insert("start", radii.at("0"))
  ancs.insert("end", ancs.at(str(nodes.len() - 1)))
  radii.insert("end", radii.at(str(nodes.len() - 1)))

  return object("rope", "start", ancs, data: ("count": nodes.len(), "radii": radii))
}