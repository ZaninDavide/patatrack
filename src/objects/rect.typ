#import "../anchors.typ" as anchors: anchor, to-anchor
#import "../objects/object.typ": object

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