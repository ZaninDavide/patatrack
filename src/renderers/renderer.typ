// -----------------------------> RENDERER
//
// This file contains all the renderer-independent logic of the rendering stage.

/*
This is the constructor for a renderer. This constructor takes
one positional argument which is expected to be a `dictionary-of-drawing-functions`
having string keys (corresponding to object types) and function
valued fields. These functions take one positional parameter, which is
expected to be an object (not a group of objects), and one named argument
called `style` of type dictionary, that is meant to specify styling options. 
The result of these functions is a graphical representation of the inputted 
object according to the specified style.

A renderer is a function that takes an arbitrary number of
positional arguments, that are expected to be objects and/or 
group of objects, and renders them according to
a `dictionary-of-drawing-functions`. The result is an array
of rendered objects that does not retain grouping (TODO: reconsider). 
The renderer (not the renderer constructor) also takes an arbitrary 
number of named arguments meant to specify the drawing style. These 
named arguments will be passed as a dictionary to the named parameter `style` 
of every drawing-function.

Observations:
 - This design implies that styling options are shared between all elements
   that are drawn using the same call to a renderer. This has the intended
   consequence that multiple calls to the renderer are required to draw
   objects that require different styling options. 
 - The active anchor of an object can be used as available information 
   when drawing. This should be generally avoided but has some reasonable
   applications, for example for the placement of labels.
*/
#let renderer(dictionary-of-drawing-functions) = (..args) => {
  let objects = args.pos().flatten()
  let style = args.named()

  return objects.map(obj => {
    // Not an object
    if type(obj) != function {
      panic("Only objects can be rendered and objects are functions but type " + repr(type(obj)) + " was found")
    }
    // Unknown object type
    if not(obj("type") in dictionary-of-drawing-functions) {
      panic("This renderer has no drawing function for objects of type " + repr(obj("type")) + ". The supported object types are " + repr(dictionary-of-drawing-functions.keys()))
    } 

    return dictionary-of-drawing-functions.at(obj("type"))(obj, style: style)
  })
}