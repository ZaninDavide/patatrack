// -----------------------------> RENDERER
//
// This file contains all the renderer-independent logic of the rendering stage.

/*
Warning: this explanation is a mess: it will be rewritten.

This is the constructor for a renderer. This constructor takes
one positional argument which is expected to be a `dictionary-of-drawing-functions`
having string keys (corresponding to object types) and function
valued fields. These drawing functions take one positional parameter, which is
expected to be an object (not a group of objects), and one named argument
called `style` of type dictionary, that is meant to specify styling options. 
The result of these drawing functions is a graphical representation of the inputted 
object according to the specified style.

A renderer is a function that takes dictionary valued arguments named as 
object types and returns a renderer function which will call the drawing functions
specified in the construction of the renderer, taking into account
the given default styles.

A render function is a function that takes an arbitrary number of
positional arguments, that are expected to be objects and/or 
groups of objects, and renders them according to
a `dictionary-of-drawing-functions`. The result is an array
of rendered objects that does not retain grouping (TO RECONSIDER).
The render function (not the renderer constructor) also takes an arbitrary 
number of named arguments meant to specify the drawing style. These 
named arguments will be passed as a dictionary to the named parameter `style` 
of every drawing-function.

TO RECONSIDER: The render function does also something special: if it is called with no input arguments it returns the 
whole `dictionary-of-drawing-functions`. First of all, this is useful to retrieve the full
list of supported types. Moreover, given a render function `rendererA` and a
render function `rendererB`, `renderer(rendererB() + rendererA())` results in a new render function that tries
to render with `rendererB` when `rendererA` is unable to do so. 

Example:
```
let dictionary-of-drawing-functions = (
  rect: (obj, style: (:)) => {...},
  circle: (obj, style: (:)) => {...},
  ...
)
let renderer-builder = renderer(dictionary-of-drawing-functions)
let draw = renderer-builder(rect: (stroke: 2pt))
```

Remarks:
 - When a group of objects is given to a renderer all objects are rendered, one by one.
 - This design implies that styling options are shared between all elements
   that are drawn using the same call to a renderer. This has the intended
   consequence that multiple calls to the renderer are required to draw
   objects that require different styling options. 
 - The active anchor of an object can be used as available information 
   when drawing. This should be generally avoided but has some reasonable
   applications, for example for the placement of labels.
*/
#let renderer(dictionary-of-drawing-functions) = (..defaults) => {
  if defaults.pos().len() > 0 {
    panic("Unexpected positional arguments. You are calling a renderer not a rendering function! To turn a renderer into an actual rendering function either call the renderer without any parameter or specify named arguments to set the default styling for each object type. For example, a sensible definition of a rendering function `draw` could be `let draw = patatrac.renderers.cetz.standard()`.")
  }

  let defaults = defaults.named()
  
  return (..args) => {
    let objects = args.pos().flatten()
    let style = args.named()

    // TO RECONSIDER
    if objects.len() == 0 and style.keys().len() == 0 {
      return dictionary-of-drawing-functions
    }

    return objects.map(obj => {
      // Not an object
      if type(obj) != function {
        panic("Only objects can be rendered but type " + repr(type(obj)) + " was found.")
      }
      // Unknown object type
      if not(obj("type") in dictionary-of-drawing-functions) {
        panic("This renderer has no drawing function for objects of type " + repr(obj("type")) + ". The supported object types are " + repr(dictionary-of-drawing-functions.keys()))
      } 

      // Calculate default styling for this object type
      let final-obj-style = none
      let default = defaults.at(obj("type"), default: (:))
      if type(default) == dictionary {
        final-obj-style = default + style
      } else if type(default) == function {
        final-obj-style = default(style)
      }

      return dictionary-of-drawing-functions.at(obj("type"))(obj, final-obj-style)
    }).flatten()
  }
}