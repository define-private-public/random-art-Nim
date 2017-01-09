import opengl
import stb_image_write as stbiw


proc shaderTypeString*(shaderType: GLenum): string=
  case shaderType:
  of GL_VERTEX_SHADER: return "vertex"
  of GL_FRAGMENT_SHADER: return "fragment"
  else : return "unkown"


## Success on non-zero return.  You will need to cleanup the shader
## yourself if so.
proc makeShader*(shaderType: GLenum; source: string): GLuint=
  # Setup the shader source
  let shaderSrcArray = allocCstringArray([source])
  defer:
    deallocCStringArray(shaderSrcArray)

  var
    shaderID: GLuint
    isCompiled: GLint

  # Compile the shader
  shaderID = glCreateShader(shaderType)
  glShaderSource(shaderID, 1, shaderSrcArray, nil)
  glCompileShader(shaderID)
  glGetShaderiv(shaderID, GL_COMPILE_STATUS, isCompiled.addr)

  # Error checking
  if isCompiled == 0:
    stderr.writeLine("Error: ", shaderTypeString(shaderType), " shader wasn't compiled.  Reason:")

    # Get the log size
    var logSize: GLint
    glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, logSize.addr)

    # Get log data
    var
      logStr = cast[ptr GLchar](alloc(logSize))
      logLen: GLsizei
    glGetShaderInfoLog(shaderID, logSize.GLsizei, logLen.addr, logStr)
    defer: dealloc(logStr)

    # Print the log
    stderr.writeLine(logStr)

    # Delete the shader
    glDeleteShader(shaderID)
    shaderID = 0
  
  return shaderID
  

## Makes an OpenGL program out of a vertex and fragment shader.  upon success
## will return non-zero.  You'll have to cleanup the stuff if so.
##
## Will also bind the attrib locations
proc makeProgram*(vertexShader, fragmentShader: GLuint): GLuint=
  # Make and attach
  var programID = glCreateProgram()
  glAttachShader(programID, vertexShader)
  glAttachShader(programID, fragmentShader)

  # Add locations
  glBindAttribLocation(programID, 0, "vertexPos")

  # Link
  glLinkProgram(programID)

  # Check for errors
  var isLinked: GLint
  glGetProgramiv(programID, GL_LINK_STATUS, isLinked.addr)
  if isLinked == 0:
    stderr.writeLine("Shader program linking failed.  Reason:")

    # Get the log size
    var logSize: GLint
    glGetProgramiv(programID, GL_INFO_LOG_LENGTH, logSize.addr)

    # Get log data
    var
      logStr = cast[ptr GLchar](alloc(logSize))
      logLen: GLsizei
    glGetProgramInfoLog(programID, logSize.GLsizei, logLen.addr, logStr)
    defer: dealloc(logStr)

    # Print the log
    stderr.writeLine(logStr)

    # Delete the program
    glDeleteProgram(programID)
    programID = 0

  return programID


## Adapted from: https://github.com/fowlmouth/nimlibs/blob/master/fowltek/pointer_arithm.nim
## Used for pointer arithmatic
proc offset(some: pointer; b: int): pointer {.inline.} =
  result = cast[pointer](cast[int](some) + b)


## Takes a screenshot and save it to disk with the given name as a PNG file.
## the width and height of the screen are required for this to work.  Returns
## true on file saving success, false otherwise.
##
## Note: There is an issue that this will not save pixels that are not visible
##       on the screen.  It seems to stem from the glReadPixels() call.  Maybe
##       render to an offscreen buffer would work.
proc takeScreenshot*(filename: string; width, height: int): bool {.discardable.} =
  # Allocate some space
  let buffSize = width * height * stbiw.RGBA
  var data = alloc(buffSize)
  defer: dealloc(data)

  # Read the pixels
  glReadPixels(0, 0, width.cint, height.cint, GL_RGBA, GL_UNSIGNED_BYTE, data)

  # Convert to a format stb_image_write can understand
  var pixels = newSeq[uint8](buffSize)

  # Need to flip the pixels along the horizontal...
  for y in 0..<height:
    let
      lineSize = width * stbiw.RGBA
      yDest = y * lineSize
      ySrc = buffSize - yDest - lineSize
    copyMem(pixels[yDest].unsafeAddr, data.offset(ySrc), lineSize)

  # Save
  return stbiw.writePNG(filename, width, height, stbiw.RGBA, pixels)

