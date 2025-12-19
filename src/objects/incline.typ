#import "../anchors.typ" as anchors: anchor, to-anchor
#import "../objects/object.typ": object

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