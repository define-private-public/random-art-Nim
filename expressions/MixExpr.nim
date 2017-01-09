import strfmt
import Expr
import ../Quadruplet


type
  MixExpr* = ref object of Expr


# This will create a new Mix Expression
proc newMixExpr*(): MixExpr =
  # Set the base stuff
  var e = MixExpr()
  e.keyword = "mix"
  e.leafs = @[]
  e.arity = 3

  return e


method eval*(e: MixExpr, vars: VarTable): Quadruplet =
  let
    w = e.leafs[0].eval(vars).x   # TODO pick a weight other than X/R?
    a = e.leafs[1].eval(vars)
    b = e.leafs[2].eval(vars)

  # TODO in the orignal python code, the weight wasn't actually applied, so
  #      in the future, be sure to enable it.  Right now this does the same as
  #      the SumExpr`
#  return average(a, b, w)
  return average(a, b)


method code*(e: MixExpr): string =
  let
    w = e.leafs[0].code()
    a = e.leafs[1].code()
    b = e.leafs[2].code()
  return "(mix {0} {1} {2})".fmt(w, a, b)


method glsl*(e: MixExpr): string =
  let
    w = e.leafs[0].glsl()
    a = e.leafs[1].glsl()
    b = e.leafs[2].glsl()

  # Note: mix() is already a function in GLSL
  return "weightedMix({0}, {1}, {2})".fmt(w, a, b)


proc buildMix*(
  tokens: var seq[string],
  buildEquation: proc(tokens: var seq[string]): Expr
): MixExpr =
  # Remove the "mix"
  tokens.delete(0)

  # Create the mix and its children
  var
    m = newMixExpr()
    weight = buildEquation(tokens)
    left = buildEquation(tokens)
    right = buildEquation(tokens)

  m.leafs.add(weight)
  m.leafs.add(left)
  m.leafs.add(right)

  return m

