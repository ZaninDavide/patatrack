#import "../anchors.typ" as anchors: anchor, to-anchor
#import "../objects/object.typ": object

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