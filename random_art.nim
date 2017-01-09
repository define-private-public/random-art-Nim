# random_art.nim, it makes nice pretty pictures

import os
import parseopt2
import strutils
import tables
import opengl
import glfw3 as glfw
import stopwatch
import strfmt
import stb_image_write as stbiw
import Quadruplet
import expressions/Expr
import expressions/ZeroExpr
import expressions/ConstExpr
import expressions/VarExpr
import expressions/SumExpr
import expressions/ProductExpr
import expressions/MixExpr
import expressions/TentExpr
import expressions/WellExpr
import expressions/LevelExpr
import expressions/ModExpr
import expressions/SinExpr
import util
import equationParser
import equationGenerator
import glsl_code
import opengl_helpers


# Runtime configuration settings
var
  # By default CPU rendering is on
  useOpenGL = false

  # Size of the render
  imageWidth = 256
  imageHeight = 256
  imagePixelCount:int
  imageByteCount:int

  # Bounds
  xMin = -1.0
  xMax = 1.0
  yMin = -1.0
  yMax = 1.0

  # Files
  readFromSTDIn = false
  equationFileName = ""
  renderFileName = "render.png" # Must be a .png

  # Other
  generateEquation = false


# A help message for the user
proc helpMessage() =
  echo "Usage:"
  echo "  ./random_art [input] [options..]"
  echo ""
  echo "  input : a path to an equation file, or provide `stdin` to read input"
  echo "          from standard input"
  echo ""
  echo "  Options:"
  echo "  -r, --renderer : cpu | opengl"
  echo "                   render on the CPU or with a GPU (using OpenGL)"
  echo "  -s, --size     : <width>x<height"
  echo "                   the dimension of the render, must be a positive int"
  echo "  -b, --bounds   : <xMin>,<xMax>,<yMin>,<yMax>"
  echo "                   the bounds to use to render, must be a float"
  echo "  -o, --output   : <filename>.png"
  echo "                   the file to save the render as, must end with .png"


# Parse the command line options
for kind, key, value in getopt():
  if kind == cmdArgument:
    # All non-named options are considered the input file (except for "help")
    if key == "help":
      helpMessage();
      quit(QuitSuccess)
    elif key == "stdin":
      # Read from standard input if told to
      readFromSTDIn = true
    else:
      # else, assume it comes from a file
      readFromSTDIn = false
      equationFileName = key

  elif (kind == cmdShortOption) or (kind == cmdLongOption):
    case key
      of "r", "renderer":
        # Choose a rendering method
        var v = value.toLowerAscii
        case v
          of "cpu":
            # Use a software renderer
            useOpenGL = false
          of "opengl":
            # Use OpenGL to render
            useOpenGL = true
          else:
            discard

      of "s", "size":
        # render size
        let dim = value.toLowerAscii.split('x')
        imageWidth = dim[0].parseInt
        imageHeight = dim[1].parseInt

      of "b", "bounds":
        # Bounds
        let bounds = value.split(',')
        xMin = bounds[0].parseFloat
        xMax = bounds[1].parseFloat
        yMin = bounds[2].parseFloat
        yMax = bounds[3].parseFloat

      of "o", "output":
        # render file
        renderFileName = value

      else:
        discard

echo ""

# If the filename is empty, then make an equation
generateEquation = (equationFileName == "") and (not readFromSTDIn)

# Verify what we got from the command line is good
# Check render size
if (imageWidth < 1) or (imageHeight < 1):
  # not good, we need an image with some dimension
  echo "Supplied render size \"", imageWidth, "x", imageHeight, "\" isn't good."
  echo "Please supply something that is at least 1x1."
  quit(QuitFailure)

# Check that the input exists
if (not readFromSTDIn) and (not fileExists(equationFileName)) and (not generateEquation):
  # not good, couldn't find the equation file
  echo "Could not file the file \"", equationFileName, "\"."
  echo "Please supply a file that exists."
  quit(QuitFailure)

# Make sure output is a PNG image
if not renderFileName.toLowerAscii.endsWith(".png"):
  # not good, only save PNGs
  echo "Output render doesn't end with \".png\"."
  echo "This can only save PNG files."
  quit(QuitFailure)


# Calculate what we'll need
imagePixelCount = imageWidth * imageHeight
imageByteCount = 4 * imagePixelCount

# Print some info
echo "Input file: ", if equationFileName != "": equationFileName else: "[None]"
echo "Render destination: ", renderFileName
echo "Render size: ", imageWidth, "x", imageHeight
echo "Bounds: x=[", xMin, ", ", xMax, "] y=[", yMin, ", ", yMax, "]"
echo ""


# Create the variable table and parse the equation
var
  vars = newVarTable() 
  root:Expr
  

# Get the equation from the desired data source
if generateEquation:
  echo "Generating a random equation..."
  root = generate(randrange(20, 150))
  echo "Equation:"
  echo "--------"
  echo root.code()
  echo "--------"
elif readFromSTDIn:
  echo "Reading from standard input."
  echo "Please enter an equation (press Ctrl-D when done):"
  root = parseEquation(readAll(stdin))
else:
  # Read from a file
  root = parseEquation(readFile(equationFileName))


# This is the function that does CPU rendering
proc cpuRender()=
  var
    sw = stopwatch(false)
    pixels: seq[uint8]

  newSeq(pixels, imageByteCount)

  let
    xLimit = imageWidth - 1
    yLimit = imageHeight - 1

  var i = 0
  for py in countup(0, yLimit):
    let y = py.float.map(0.0, yLimit.float, yMin, yMax)

    for px in countup(0, xLimit):
      let
        x = px.float.map(0.0, xLimit.float, xMin, xMax)

      # Set variable table
      vars["x"] = x
      vars["y"] = y

      # Do a render
      sw.start()
      let q = root.eval(vars)
      sw.stop()

      pixels[i] = q.toR()
      pixels[i + 1] = q.toG()
      pixels[i + 2] = q.toB()
      pixels[i + 3] = q.toA()
      i += 4

  # Print some info
  echo "Render time: ", sw.totalSecs, "s"

  # Save it
  if stbiw.writePNG(renderFileName, imageWidth, imageHeight, stbiw.RGBA, pixels):
    echo "Saved the render!"
  else:
    echo "There was an error in saving the render."


# This will use OpenGL to render the image
# this includes setting up the GLFW context n stuff
proc openGLRender()=
  if glfw.Init() == 0:
    raise newException(Exception, "Failed to initialize GLFW")

  # Create a window
  var window = glfw.CreateWindow(imageWidth.cint, imageHeight.cint, "Random Art w/ OpenGL (in Nim)", nil, nil)
  glfw.MakeContextCurrent(window)

  # Load opengl
  loadExtensions()

  # Data
  var
    # A square
    vertices: array[12, GLfloat] = [
      -1'f32,  1'f32, 0'f32,
      -1'f32, -1'f32, 0'f32,
       1'f32, -1'f32, 0'f32,
       1'f32,  1'f32, 0'f32
    ]

    # Indices to draw (Triangle Fan order)
    indices: array[4, GLushort] = [
      0'u16, 1'u16, 2'u16, 3'u16
    ]

    # OpenGL stuff
    vbo: GLuint = 0
    vao: GLuint = 0
    vertexShader: GLuint
    fragmentShader: GLuint
    shaderProgram: GLuint

  # Create a vbo
  glGenBuffers(1, vbo.addr)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, vertices.sizeof, vertices.addr, GL_STATIC_DRAW)

  # The array object
  glGenVertexArrays(1, vao.addr)
  glBindVertexArray(vao)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glVertexAttribPointer(0, 3, cGL_FLOAT, GL_FALSE, 0, nil)
  glEnableVertexAttribArray(0)

  # Create the shaders & program
  vertexShader = makeShader(GL_VERTEX_SHADER, vertexShaderSrc)
  fragmentShader = makeShader(GL_FRAGMENT_SHADER, fragmentShaderSrc(root.glsl))
  shaderProgram = makeProgram(vertexShader, fragmentShader)

  # Verify we're good
  let goodToGo = (vertexShader != 0) and (fragmentshader != 0) and (shaderProgram != 0)
  if goodToGo:
    echo "Shaders are compiled and program is linked!"
  else:
    echo "Shaders are not good and/or the program too."
    return

  # Do the render (time it!)
  var sw = stopwatch()

  # Clear and setup drawing
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glUseProgram(shaderProgram)

  # Do the drawing
  sw.start()
  glBindVertexArray(vao)
  glDrawElements(GL_TRIANGLE_FAN, indices.len.GLsizei, GL_UNSIGNED_SHORT, indices.addr)
  sw.stop()

  # Reset drawing state
  glBindVertexArray(0);
  glUseProgram(0);

  # Info
  echo "Render time: ", sw.secs, "s"

  # Save the render
  if takeScreenshot(renderFileName, imageWidth, imageHeight):
    echo "Saved the render!"
  else:
    echo "There was an error in saving the render."

  # Note: Uncomment this code if you want to display the render
#  # Main loop (For display)
#  while glfw.WindowShouldClose(window) == 0:
#    # Exit on ESC press
#    if glfw.GetKey(window, glfw.KEY_ESCAPE) == 1:
#      glfw.SetWindowShouldClose(window, 1)
#
#    # Poll n' swap
#    glfw.PollEvents()
#    glfw.SwapBuffers(window)

  # Cleanup GL stuff
  glDeleteProgram(shaderProgram)
  glDeleteShader(vertexShader)
  glDeleteShader(fragmentShader)
  glDeleteBuffers(1, vbo.addr)
  glDeleteVertexArrays(1, vao.addr)

  # Cleanup GLFW
  glfw.DestroyWindow(window)
  glfw.Terminate()


# Chose how to render
if useOpenGL:
  echo "Rendering with OpenGL..."
  openGLRender()
else:
  echo "Rendering with the CPU..."
  cpuRender()


