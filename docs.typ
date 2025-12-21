#import "src/lib.typ" as patatrac

#show title: it => {
  set text(size: 50pt)
  align(center, it)
}

#show quote: it => {
  set text(style: "italic", size: 15pt)
  align(center, pad(it, top: 0pt, bottom: 20pt))
}

#set text(size: 12pt)
#set page(margin: (left: 4cm, top: 3cm, bottom: 3cm, right: 4cm), footer:  context {
  set align(center)
  v(1fr)
  counter(page).display("1")
  v(1fr)
})
#set par(justify: true)
#set heading(numbering: "1.1")

#import "@preview/zebraw:0.6.1": zebraw
#show raw.where(block: false): set raw(lang: "typc")
#show raw.where(block: true): zebraw.with(background-color: luma(96%), numbering-separator: true, lang: false)

#let canvas = (..args) => {
  set text(size: 15pt)
  align(center, patatrac.cetz.canvas(length: 0.5mm, ..args))
}

#place(top + center, scope: "parent", float: true, {
  title[patatrac]

  v(-20pt)
  text(size: 20pt, fill: luma(70%))[|pataˈtrak|]


  canvas({
    import "src/lib.typ" as patatrac: *
    let draw = patatrac.cetz.standard(
      rect: style => {
        if "color" in style {
          style.fill = style.color
          style.stroke = 2pt + style.color.darken(60%)
        }
        style
      }
    )

    let sideA = 20
    let sideB = 15
    let radiusC = 5
    let hang = 15

    let I = incline(150, 25deg)

    let A = rect(sideA,sideA)
    A = stick(A("bl"), I("tl"))
    A = slide(A, -40, 0)

    let centerC = anchors.slide(I("tr")(), hang, sideA/2 - radiusC)
    let C = place(circle(radiusC), centerC)
    let L = rope(C(), I("tr"))
    
    let B = move(place(rect(sideB, sideB), C("r")), 0, -40)
    let R = rope(A("r"), C("t"), B("t"))

    draw(L, stroke: 2pt)
    draw(I, C, stroke: 2pt, fill: luma(90%))
    draw(R, stroke: 2pt + rgb("#995708"))
    
    let tension1 = arrow(A("r"), 20)
    let tension2 = arrow(B("t"), 20)
    
    draw(tension1, tension2, stroke: 2pt)
    draw(point(tension1("end"), rot: false), lx: -8, ly: 2, label: math.arrow($T_1$), align: bottom)
    draw(point(tension2("c"), rot: false), lx: 10, label: math.arrow($T_2$), align: bottom)
    draw(point(C("c")))
    
    draw(A, color: blue)
    draw(B, color: red)
    draw(point(A("c")), label: text(fill: white, $M$))
    draw(point(B("c")), label: text(fill: white, $m$), ly: 1)
    
    let coord(a) = { let a = anchors.to-anchor(a); return (a.x, a.y) }
    cetz.angle.angle(label: $alpha$, radius: 30, label-radius: 38, stroke: 2pt, 
      coord(I("bl")), 
      coord(I("br")), 
      coord(I("tr")), 
    )
    
  })

  v(10pt)

  quote[
    the funny sound of something messy\ suddenly collapsing onto itself
  ]

  v(70pt)
})

= Introduction
This Typst package provides help with the typesetting of physics diagrams depicting classical mechanical systems. The goal: 

#align(center, [_drawing beautiful physics diagrams without trigonometry._])

The workflow is based on a strict separation between the composition and the rendering of the diagrams. The package is 100% #link("https://typst.app/universe/package/cetz")[`cetz`]-compatible.

= Tutorial
In this tutorial we will assume that `cetz` is the rendering engine of choice, which at the moment is the only one supported out of the box. The goal is to draw the figure below: two boxes connected by a spring laying on a sloped surface. 

#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  let floor = incline(100, 20deg)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = stick(A("bl"), floor("tl"))
  B = stick(B("br"), floor("tr"))

  A = slide(A, -20, 0)
  B = slide(B, +20, 0)
  
  let k = spring(A("r"), B("l"))

  draw(floor, fill: luma(90%), stroke: none)
  draw(k, radius: 6, pitch: 4, pad: 3)
  draw(A, stroke: 2pt, fill: red)
  draw(B, stroke: 2pt, fill: blue)
})

== Getting started
Let's start with the boilerplate required to import `patatrac` and set up a canvas. Under the namespace `patatrac.cetz`, the package exposes a complete `cetz` version plus all cetz-based renderers.

```typ
#import "@preview/patatrac:0.0.0"

#patatrac.cetz.canvas(length: 0.5mm, {
  import patatrac: *
  let draw = cetz.standard()

  // Composition & Rendering
})
```

At line 3, we create a new cetz canvas. At line 5, we define draw to be the cetz standard renderer provided by `patatrac` without giving any default styling option: we will go back to defaults later in the tutorial. The function `draw` will take care of outputting `cetz` elements that the canvas can print. From now on, we will only show what goes in the place of line 7, but remember that the boilerplate is still there. Let's start by adding the floor to our scene.

```typc
let floor = rect(100, 20)
draw(floor)
```

Line 1 creates a new patatrac `object` of type `"rect"`, which under the hood is a special function that represents our $100 times 20$ rectangle. The output of `draw` is a cetz-element that is then picked up by the canvas and printed.

#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let floor = rect(100, 20)
  draw(floor)
})

== Introducing anchors
Every object carries with it a set of anchors. Every anchor is a point in space with a specified orientation. As anticipated, objects are functions. In particular, if you call an object on the string `"anchors"`, a complete dictionary of all its anchors is returned. For example, `floor("anchors")` gives

#raw(repr(patatrac.rect(100,20)("anchors")), lang: "typc")

As a general rule of thumb, anchors are placed both at the vertices and at the centers of the sides of the objects and their rotations specify the tangent direction at every point./* If you pay attention you will see that the rotation of the anchors is an angle which increases as one rotates counter-clockwise and with zero corresponding to the right direction. */ If you use the renderer `patatrac.cetz.debug` you will see exactly where and how the anchors are placed: red corresponds to the tangent (local-$x$) direction and green to the normal (local-$y$) direction.

```typc
let debug = cetz.debug()
draw(floor)
debug(floor)
```
#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  let debug = patatrac.cetz.debug()
  let floor = rect(100, 20)
  draw(floor)
  debug(floor)
})

As you can see, the central anchor is drawn a bit bigger and thicker. The reason is that `c` is, by default, what we call the _active anchor_. We can change the active anchor of an object by calling the object itself on the name of the anchor. For example if we instead draw the anchors of the object `floor("t")` what we get is the following.

```typc
let debug = cetz.debug()
draw(floor)
debug(floor("t"))
```
#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  let debug = patatrac.cetz.debug()
  let floor = rect(100, 20)
  draw(floor)
  debug(floor("t"))
})

When doing so, we have to remember that Typst functions are pure: don't forget to reassign your objects if you want the active anchor to change "permanently"! 

== Composition
Now, let's add in the two blocks. First of all, we need to place the blocks on top of the floor. To do so we use the `place` function which takes two objects and gives as a result the first object translated such that its active anchor location overlaps with that of the second object.
```typc
let floor = rect(100, 20)

let A = rect(15, 15)
let B = rect(15, 15)

A = place(A("bl"), floor("tl"))
B = place(B("br"), floor("tr"))

draw(floor, A, B)
```

#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  let floor = rect(100, 20)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = place(A("bl"), floor("tl"))
  B = place(B("br"), floor("tr"))
  
  draw(floor, A, B)
})


Now we should move the blocks a bit closer and add the spring.
```typc
let floor = rect(100, 20)
let A = rect(15, 15)
let B = rect(15, 15)

A = place(A("bl"), floor("tl"))
B = place(B("br"), floor("tr"))

A = move(A, +20, 0)
B = move(B, -20, 0)

let k = spring(A("r"), B("l"))

draw(floor, A, B, k)
```

#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  let floor = rect(100, 20)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = place(A("bl"), floor("tl"))
  B = place(B("br"), floor("tr"))

  A = move(A, +20, 0)
  B = move(B, -20, 0)
  
  let k = spring(A("r"), B("l"))

  draw(floor, A, B, k)
})

== Styling
The styling is pretty self-explanatory. The only thing to notice is that objects drawn with the same call to `draw` share the same styling options, therefore multiple calls to `draw` are required for total stylistic freedom.
```typc
// ...

draw(floor, fill: luma(90%), stroke: none)
draw(k, radius: 6, pitch: 4, pad: 3)
draw(A, stroke: 2pt, fill: red)
draw(B, stroke: 2pt, fill: blue)
```

#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  let floor = rect(100, 20)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = place(A("bl"), floor("tl"))
  B = place(B("br"), floor("tr"))

  A = move(A, +20, 0)
  B = move(B, -20, 0)
  
  let k = spring(A("r"), B("l"))

  draw(floor, fill: luma(90%), stroke: none)
  draw(k, radius: 6, pitch: 4, pad: 3)
  draw(A, stroke: 2pt, fill: red)
  draw(B, stroke: 2pt, fill: blue)
})

Remember that since you are inside a `cetz` canvas you are free to add whatever detail you like to make your picture more expressive. This picture is nice but drawing it without `patatrac` wouldn't have been much harder (well, drawing the spring is not a piece of cake but bare with me). I want you to see where `patatrac` shines so `stick` with me while I exchange the floor for an incline.
```typc
let floor = incline(100, 20deg)
let A = rect(15, 15)
let B = rect(15, 15)

A = stick(A("bl"), floor("tl"))
B = stick(B("br"), floor("tr"))

A = slide(A("c"), +20, 0)
B = slide(B("c"), -20, 0)

// ...
```
#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let floor = incline(100, 20deg)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = stick(A("bl"), floor("tl"))
  B = stick(B("br"), floor("tr"))

  A = slide(A("c"), +20, 0)
  B = slide(B("c"), -20, 0)
  
  let k = spring(A("r"), B("l"))

  draw(floor, fill: luma(90%), stroke: none)
  draw(k, radius: 6, pitch: 4, pad: 3)
  draw(A, stroke: 2pt, fill: red)
  draw(B, stroke: 2pt, fill: blue)
})

What have I done? At line 1, I used an `incline` instead of a rectangle which I create by giving its width and steepness. Then, at lines 5 and 6, I replaced the calls to `place` with an identical call to `stick`. This function, instead of simply translating the object, also rotates it to make sure that its active anchor faces the second anchor. By doing so, I'm sure that the two blocks rest on the incline correctly. Then, at lines 8 and 9, I replaced the calls to `move` with identical (up to a change of active anchors) calls to `slide`. This function, instead of translating the objects in the global coordinate system, translates them inside the rotated coordinate system of their active anchors. By doing so, I make the two blocks slide along the incline surface.

== Defaults
The picture is done but there's another thing I'd like to show you and that will come in handy for more complex pictures. As promised, we have to go back to the boilerplate. Do you remember the line where we defined `draw`? Instead of specifying `stroke: 2pt` every time we draw a rectangle, we can put inside the call to `patatrac.cetz.standard` the information that by default all rectangles should have `2pt` of stroke. Even if we have only one spring it makes sense to do the same for the styling options of `k`, so that if we create a second spring it will look the same.
```typc
let draw = cetz.standard(
  rect: (stroke: 2pt),
  spring: (radius: 6, pitch: 4, pad: 3),
)

// ...

draw(floor, fill: luma(90%), stroke: none)
draw(k)
draw(A, fill: red)
draw(B, fill: blue)
```
Here is the full code.
```typ
#import "@preview/patatrac:0.0.0"

#patatrac.cetz.canvas(length: 0.5mm, {
  import patatrac: *
  let draw = cetz.standard(
    rect: (stroke: 2pt),
    spring: (radius: 6, pitch: 4, pad: 3),
  )

  let floor = incline(100, 20deg)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = stick(A("bl"), floor("tl"))
  B = stick(B("br"), floor("tr"))

  A = slide(A("c"), +20, 0)
  B = slide(B("c"), -20, 0)

  let k = spring(A("r"), B("l"))

  draw(floor, fill: luma(90%), stroke: none)
  draw(k)
  draw(A, fill: red)
  draw(B, fill: blue)
})
```


Okay, now that we have the final drawing we can spend a few words to clarify what's going on. Read @system to understand better.

#set enum(spacing: 15pt, indent: 15pt)
#set list(spacing: 15pt, indent: 15pt)

= Core system <system>
The whole `patatrac` package is structured around three things:
1. anchors, 
2. objects,
3. renderers.
Let's define them one by one. 

== Anchors
Anchors are simply dictionaries with three entries `x`, `y` and `rot` that are meant to specify a 2D coordinate system. The values associated with `x` and `y` are either lengths or numbers and the package assumes that this choice is unique for all the anchors used in the drawing. These two entries specify the origin of the local coordinate system on the canvas. `rot` on the other hand always takes values of type `angle` and specifies the direction in which the local-x axis is pointing. Whenever `patatrac` expects the argument of a method to be an anchor it automatically calls `anchors.to-anchor` on that argument. This allows you, the end user, to specify anchors in many different styles:
- `(x: ..., y: ..., rot: ...)`,
- `(x: ..., y: ...)`,
- `(..., ..., ...)`,
- `(..., ...)`.
All options where the rotation is not specified default to `0deg`. Moreover, objects can automatically be converted to anchors: `to-anchor` simply results in the object's active anchor. The local coordinate system is right-handed if the positive $z$-direction is taken to point from the screen towards our eyes.

== Objects
Objects are special functions created with a call to an object constructor. All object constructors ultimately reduce to a call to `object`, so that all objects behave in the same way. The result is a callable function, let's call it `obj`, such that:
 - `obj()` returns the active anchor,
 - `obj("anchor-name")` returns an equivalent object but with the specified anchor as active,
 - `obj("anchors")` returns the full dictionary of anchors,
 - `obj("active")` returns the key of the active anchor,
 - `obj("type")` returns the object type,
 - `obj("data")` returns the carried metadata,
 - `obj("repr")` returns a dictionary representation of the object meant only for debugging purposes.

If you want to create an object from scratch all you need to do is to use the `object` constructor yourself.
```typc
let custom = patatrac.objects.object(
  "custom-type-name", 
  "active-anchor-name",
  dictionary-of-anchors,
  data: payload-of-metadata 
)
```

== Renderers
A renderer is a function whose job is to take default styling options and return a function capable of rendering objects. This function will take one or more objects, associate each object to a drawing function according to the object's type and return the rendered result, all of this while taking care of any styling option. The journey from a set of drawing functions to an actual drawing starts with a call to `renderer`.
```typc
let my-renderer = patatrac.renderer((
  // drawing functions
  rect: (obj, style) => { ... },
  circle: (obj, style) => { ... },
  ...
))
```
For example, this is the way in which `patatrac.cetz.standard` is defined. `my-renderer` is not yet ready to render stuff: we need to specify any default styling option. We do this by calling `my-renderer` itself.
```typc
let draw = my-renderer(rect: (stroke: 2pt))
```
The variable `draw` is the function we use to actually render objects. This step where we provide defaults is kept separate from the call to `renderer` so that the end user can put his own defaults into the renderer: the developer should expose `my-renderer` and not `draw`. Defaults that are set by the developer can simply be hardcoded inside the drawing functions definitions; and this is exactly how the package does for its own renderers. Now, use `draw` to print things.
```typc
draw(circle(10), fill: blue)
```
#align(center, patatrac.cetz.canvas(length: 0.5mm, {
  let draw = patatrac.cetz.standard()
  draw(patatrac.circle(10), fill: blue)
}))
If you want, you can extract from `my-renderer` the full dictionary of drawing functions that was used to for its definition.
```typc
my-renderer("functions")
```

#{
  patatrac.renderer((
    // drawing functions
    rect: (obj, style) => {},
    circle: (obj, style) => {},
  ))("functions")
}

This allows the user to extend, modify and combine existing renderers if needed. For example, we could start from the `cetz.standard` renderer and override the algorithm for drawing circles.
```typc
let my-renderer = renderer(cetz.standard("functions") + (
  circle: (obj, style) => { ... }
))
```

= Ropes
Normally, drawing #link("https://en.wikipedia.org/wiki/Atwood_machine")[Atwood machines] tends to be really cumbersome, but with `patatrack` pulleys are extremely easy to draw, thanks to the mechanics of `rope`s. The main idea behind how ropes work is the following:

#align(center)[_ropes are one dimensional strings that wrap around anchors and circles._]

To create a rope all you have to do is to provide the list of anchors and circles that 
you want the rope to wrap around. Since there are two ways in which any given rope can wrap around a circle, the rotation of the active anchor of the circle will tell the rope from which direction to start "orbiting" around the circle. An example will make everything very clear.

```typc
let C1 = circle(15)
let C2 = place(circle(10), (50, 0))
let R = rope((-50, 0), C1("b"), C2("t"), (+100, 0))
draw(C1, C2)
draw(R, stroke: 2pt + blue)
```
#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  
  let C1 = circle(15)
  let C2 = place(circle(10), (50, 0))
  let R = rope((-50, 0), C1("b"), C2("t"), (+100, 0))
  draw(C1, C2)
  draw(R, stroke: 2pt + blue)
})

Ropes provide many different anchors. Anchors are named with increasing whole numbers starting from one converted to strings and eventually followed by a letter `"i"`, `"m"`, `"o"`. The letter `"i"` specifies that we are either starting an arc of circumference around a circle or approaching a vertex. The letter `"m"` denotes anchors which are placed at the middle of an turn. The letter `"o"` is placed at the end of anchors that either specify the outgoing direction from a vertex or the last point on an arc. There are also two special anchors `start` and `end`, whose name is self-explanatory. Here is the full list of anchors for the previous example.

#{
  import patatrac: *
  let C1 = circle(15)
  let C2 = place(circle(10), (50, 0))
  let R = rope((-50, 0), C1("b"), C2("t"), (+100, 0))
  canvas({
    cetz.standard()(R, stroke: 2pt + blue)
    cetz.debug()(R)
  })
  [#R("anchors")]
}

Really, there isn't anything more to say about ropes: they just work.


#let stripes(fill, stroke, width, angle: 60deg) = {
  assert(angle >  0deg)
  assert(angle < 90deg)
  return tiling(
    size: (width, width*calc.tan(angle)), {
      place(rect(width: 100%, height: 100%, fill: fill))
      place(line(start: (0%, 0%), end: (100%, 100%), stroke: stroke))
      place(line(start: (100%, 0%), end: (200%, 100%), stroke: stroke))
      place(line(start: (0%, 100%), end: (100%, 200%), stroke: stroke))
      place(line(start: (-100%, 0%), end: (0%, 100%), stroke: stroke))
      place(line(start: (0%, -100%), end: (100%, 0%), stroke: stroke))
    }
  )
}

#pagebreak()

= Useful lists
In this section you'll find a few useful lists. This lists are generated semi-automatically and errors are possible; let me know if you find any. 

#let doc(filename) = {
  import "@preview/tidy:0.4.3" as tidy
  let docs = tidy.parse-module(read(filename))
  for fun in docs.functions.sorted(key: fun => fun.name) {
    ({
      raw({
        str(fun.name)
        "("
        for (key, value) in fun.args {
          (str(key) + if "default" in value {
            ": " + str(value.default)
          }, )
        }.join(", ")
        ")"
        if fun.return-types != none {
          " -> "
          for rt in fun.return-types {
            str(rt)
          }
        }
      })
    },)
  }
}

== Renderers
This is the complete list of available renderers

- `patatrac.cetz.debug` 
- `patatrac.cetz.standard` 

== Objects
Here is the list of all object constructors. These are all available directly under the namespace `patatrac`.
#{
  let str = read("src/objects/mod.typ")
  let objects = str.matches(regex("#import\s+\"([^\"]+)\""))
  list(
    ..objects
    .filter(obj => obj.captures.at(0) != "object.typ")
    .map(obj => "src/objects/" + obj.captures.at(0))
    .sorted()
    .map(filename => doc(filename))
    .flatten()
  )
}
Here is the list of all object related functions. These are all available directly under the namespace `patatrac`.
#list(..doc("src/objects/object.typ"))

== Anchors
Under the namespace `patatrac.anchors` you can find

#list(..doc("src/anchors.typ"))

#pagebreak()

#outline(title: "Index")