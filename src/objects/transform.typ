// -----------------------------> TRANSFORM
// This files contains all provided methods that rigidly roto-translate objects:
//  - transform
//  - slide
//  - move
//  - rotate
//  - match
//  - stick
//

#import "../anchors.typ" as anchors
#import "object.typ": object

/*
Applies a given function to all the anchors of an object or all the anchors 
of all the objects in a group of objects. The result is the same object or group
but with the operation applied. Nested groups are preserved.

_Remark_: a group is just a tuple of groups and objects whose active anchor is the active anchor
of the first element of the tuple. 
*/
#let transform(obj, func) = {
  // Transform the anchors of a single object
  let tr = (o, f) => {
    let ancs = o("anchors")
    for anc in ancs.keys() {
      ancs.at(anc) = f(obj(anc)())
    }
    return object(o("type"), o("active"), ancs, data: o("data"))
  }

  return if type(obj) == array { 
    // Group of objects 
    obj.map(o => transform(o, func)) 
  } else { 
    // Single object 
    tr(obj, func) 
  }
}


// -----------------------------> TRANSLATIONS

/*
Translates the object in a rotated coordinate system.
If `rot` is `none`, the coordinate system is rotated
like the active anchor of the object. If `rot` is a 
specified angle, it will be used as the reference frame rotation.
*/
#let slide(obj, dx, dy, rot: none) = transform(obj, a => anchors.slide(
  a, dx, dy, rot: if rot == none { anchors.to-anchor(obj).rot } else { rot } 
))


/*
Translates the object in global coordinates. Its equivalent to `slide.with(rot: 0deg)`
*/
#let move = slide.with(rot: 0deg)

#let place(obj, target) = {
  let delta = anchors.term-by-term-difference(target, obj)
  return move(obj, delta.x, delta.y)
}

// -----------------------------> ROTATIONS

/*
Rotates the object around a given anchor by the specified angle. The anchor is taken to be the
active anchor of the object if `ref` is `none` otherwise `ref` itself is used as origin.
*/
#let rotate(obj, angle, ref: none) = {
  let origin = if ref == none { anchors.to-anchor(obj) } else { anchors.to-anchor(ref) }
  return transform(obj, a => anchors.pivot(a, origin, angle))
}


// -----------------------------> ROTO-TRANSLATIONS

/*
Translates and rotates an object to ensure that the active 
anchor of `obj` becomes equal to the `target`ed anchor.
The named parameters `x`, `y` and `rot` take boolean values
that determine if the corresponding anchor parameter can be 
changed or not: `true` is the default and `false` means
that the parameter has to remain fixed.
*/
#let match(obj, target, x: true, y: true, rot: true) = {
  let delta = anchors.term-by-term-difference(target, obj)
  return move(rotate(obj, delta.rot, ref: anchors.to-anchor(obj)), delta.x, delta.y)
}

/*
Translates and rotates an object to ensure that the active anchor of the object becomes 
equal in origin and opposite in direction with respect to the `target`ed anchor.
*/
#let stick(obj, target) = match(obj, anchors.rotate(target, 180deg))