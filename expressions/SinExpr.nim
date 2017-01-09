import strutils
import sequtils
import tables
import math
import strfmt
import Expr
import ../Quadruplet
import ../util


type
  SinExpr* = ref object of Expr
    phase*, frequency*: float


method `$`*(e: SinExpr): string =
  return e.keyword


proc newSinExpr*(): SinExpr =
  var e = SinExpr()
  e.leafs = @[]
  e.keyword = "sin"
  e.arity = 1
  e.phase = random(0, PI)
  e.frequency = random(1, 6)

  return e


proc newSinExpr*(phase, frequency: float): SinExpr =
  var e = newSinExpr()
  e.phase = phase
  e.frequency = frequency

  return e


method eval*(e: SinExpr, vars: VarTable): Quadruplet =
  let
    a = e.leafs[0].eval(vars)

  # TODO use sin W instead?
  return newQuadruplet(
    1, #sin(e.phase + (e.frequency * a.w)),
    sin(e.phase + (e.frequency * a.x)),
    sin(e.phase + (e.frequency * a.y)),
    sin(e.phase + (e.frequency * a.z)),
  )
  

method code*(e: SinExpr): string =
  let a = e.leafs[0].code()

  return "(sin {0} {1} {2})".fmt(e.phase, e.frequency, a)


method glsl*(e: SinExpr): string =
  let a = e.leafs[0].glsl()

  return "sin({0} + ({1} * {2}))".fmt(e.phase, e.frequency, a)


proc buildSin*(
  tokens: var seq[string],
  buildEquation: proc(tokens: var seq[string]): Expr
): SinExpr =
  # Remove the "sin"
  tokens.delete(0)

  # Pull out the data
  let
    phase = tokens[0].parseFloat
    freq = tokens[1].parseFloat

  # Remove used tokens
#  tokens.delete(0, 2)
  tokens.delete(0)
  tokens.delete(0)

  # Create the sin, build the child
  var
    s = newSinExpr(phase, freq)
    child = buildEquation(tokens)

  s.leafs.add(child)

  return s

