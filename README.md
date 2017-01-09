Random Art in Nim (& OpenGL)
============================

![A Complex Example](https://gitlab.com/define-private-public/random-art-Nim/raw/master/examples/complex.png)

The official repo can be found on GitLab:
  https://gitlab.com/define-private-public/random-art-Nim

Though there is a mirror on GitHub were issues can be addressed:
  https://github.com/define-private-public/random-art-Nim


What is this?
-------------

This is an implementation of [random art](http://random-art.org/) in the 
[Nim programming language](http://nim-lang.org/).  You can give it an equation
(or have it generate one) and it will spit out an image.  This can do rendering
on the CPU (normally) or on the GPU using OpenGL (ES 3.0).  It is also built
using GLFW (v3) and `stb_image`.

It is based off of the Python example found here:
  http://math.andrej.com/2010/04/21/random-art-in-python/


Building:
---------

From the root directory, run `nake release`.  Make sure you have the necesssary
packages and libraries specified in `random_art.nimble`.


Usage:
------

If you want a simple 256x256 randomly generated piece of art rendered on the
CPU, simply run `./random_art` and sit back.  An equation will pop out on
standard output and it will be saved to `render.png`.

Here are some more details from running `./random_art help`:

```
Usage:
  ./random_art [input] [options..]

  input : a path to an equation file, or provide `stdin` to read input
          from standard input

  Options:
  -r, --renderer : cpu | opengl
                   render on the CPU or with a GPU (using OpenGL)
  -s, --size     : <width>x<height>
                   the dimension of the render, must be a positive int
  -b, --bounds   : <xMin>,<xMax>,<yMin>,<yMax>
                   the bounds to use to render, must be a float
  -o, --output   : <filename>.png
                   the file to save the render as, must end with .png
```

If you render using the `-r:opengl` flag, please note that a window will pop up
very quickly and then close.  Rending with OpenGL is **much** faster, but note
that the images might appear a little different than if rendered by the CPU.
Take a look below; the first is rendered on the CPU, where the second is on the
GPU.

![A CPU Render](https://gitlab.com/define-private-public/random-art-Nim/raw/master/examples/cpu-render.png)
![A GPU Render](https://gitlab.com/define-private-public/random-art-Nim/raw/master/examples/cpu-render.png)

Though it looks pretty close, so it might not matter too much. :P


Examples:
---------

If you want get the image that is at the top of this README, that equation is
stored in `examples/complex.txt`, and run with the command:

```
./random_art examples/complex.txt -s:960x540 -b:-0.5,0.5,-1,1
```

Here's a much simplier example from `examples/simple.txt`:

```
(mul
  (var y)
  (mod
    (sum
      (var x)
      (var y)
    )
    (const 1 0.7 -0.1 0.95)
  )
)
```

It produces this:

!(A Simple Random Art Example)[https://gitlab.com/define-private-public/random-art-Nim/raw/master/examples/simple.png]


Known Issues
------------
 - When saving renders with `-r:opengl` there is an issue if you try to do a
   render that is larger than you screen size.  Go ahead and try it.  It
   probably has something to do with `glReadPixels()`
 - There is also some really odd bug when reading in equations directly from
   standard input.  If an equation is really long, it will turn some parts into
   `(zero)` expressions.  Reading in from files though is completely fine.


License
-------

This port is under the MIT license.  See the file `LICENSE.txt` for details.

