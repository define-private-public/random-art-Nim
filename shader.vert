#version 400

in vec3 pos;
out vec4 color;

void main() {
  gl_Position = vec4(pos, 1);
  color = vec4(0, 1, 0, 1);
}

