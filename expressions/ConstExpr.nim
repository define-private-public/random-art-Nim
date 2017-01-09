import strutils
import sequtils
import strfmt
import ../util
import Expr
import ../Quadruplet


# TODO right now this only uses its RGB values, but not the A value (same with
#      the GLSL code.  Figure out a way to utilize it (if necessary)


# Produced a single constant expression
type
  ConstExpr = ref object of Expr
    quad*: Quadruplet


# This method will provide a random color to the constant
# If -2 is provided (or less), that means to give is a random alpha value.
# else it will be clamped between [-1, 1]
proc newConstExpr*(alpha: float = 1.0): ConstExpr =
  var e = ConstExpr()
  e.keyword = "const"
  e.leafs = @[]
  e.arity = 0

  # Check for random alpha
  var a = alpha
  if alpha <= -2:
    a = random(-1, 1)
  else:
    a = alpha.clamp(-1, 1)

  # Assign the Quadruplet color
  e.quad = newQuadruplet(
    a,
    random(-1, 1),
    random(-1, 1),
    random(-1, 1)
  )

  return e


# Create an opqaue constant expressions with a given RGB value [-1, 1]
proc newConstExpr*(r, g, b: float): ConstExpr =
  var e = newConstExpr()
  e.quad.x = r
  e.quad.y = g
  e.quad.z = b

  return e


# Create an opqaue constant expressions with a given ARGB value [-1, 1]
proc newConstExpr*(a, r, g, b: float): ConstExpr =
  var e = newConstExpr(a)
  e.quad.x = r
  e.quad.y = g
  e.quad.z = b

  return e


method eval*(e: ConstExpr, vars: VarTable): Quadruplet =
  return e.quad


method code*(e: ConstExpr): string =
  return "(const {0})".fmt($e.quad)


method glsl*(e: ConstExpr): string =
  return "vec3({0}, {1}, {2})".fmt(e.quad.x, e.quad.y, e.quad.z)


proc buildConst*(
  tokens: var seq[string],
  buildEquation: proc(tokens: var seq[string]): Expr
): ConstExpr =
  # Remove the "const"
  tokens.delete(0)

  # Get the ARGB values
  let
    a = tokens[0].parseFloat
    r = tokens[1].parseFloat
    g = tokens[2].parseFloat
    b = tokens[3].parseFloat

  # remove used tokens
  tokens.delete(0) 
  tokens.delete(0) 
  tokens.delete(0) 
  tokens.delete(0) 

  return newConstExpr(a, r, g, b)

