# This file contains code for running random_art in GLSL (GPU rendering)


let
  GLSLFunctions*:string = """
vec4 rgb(vec3 t) {
  return vec4(
    (t.r + 1.0) / 2.0,
    (t.g + 1.0) / 2.0,
    (t.b + 1.0) / 2.0,
    1
  );
}


vec3 average(vec3 t, vec3 u, float weight) {
  return vec3(
    weight * t.x + (1.0 - weight) * u.x,
    weight * t.y + (1.0 - weight) * u.y,
    weight * t.z + (1.0 - weight) * u.z
  );
}


vec3 average(vec3 t, vec3 u) {
  return average(t, u, 0.5);
}


float well(float x) {
  return (1.0 - (2.0 / pow(1.0 + (x * x), 8.0)));
}


vec3 well(vec3 v) {
  return vec3(
    well(v.x),
    well(v.y),
    well(v.z)
  );
}


float tent(float x) {
  return (1.0 - (2.0 * abs(x)));
}


vec3 tent(vec3 v) {
  return vec3(
    tent(v.x),
    tent(v.y),
    tent(v.z)
  );
}


vec3 level(float threshold, vec3 level, vec3 t, vec3 u) {
  return vec3(
    (level.x < threshold) ? t.x : u.x,
    (level.y < threshold) ? t.y : u.y,
    (level.z < threshold) ? t.z : u.z
  );
}


// mix() function it taken by GLSL
vec3 weightedMix(vec3 weight, vec3 t, vec3 u) {
  // TODO the original source didn't use the `w` parameter (I think it was a
  //      typo).  I decided to leave it in here incase w should be used, because
  //      right now the MixExpr is the same as the SumExpr
//  float w = 0.5 * (weight.x + 1);
  return average(t, u);
}

"""


  vertexShaderSrc*:string = """
#version 300 es

layout(location = 0) in vec3 vertexPos;

out vec2 vPos;

void main() {
  gl_Position = vec4(vertexPos, 1); 
  vPos = gl_Position.xy;
}
"""


proc fragmentShaderSrc*(glslExpr:string): string =
  return """
#version 300 es

precision highp float;

in vec2 vPos;
out vec4 fragmentColor;

""" & GLSLFunctions & "void main() { fragmentColor = rgb(" & glslExpr & "); }"

