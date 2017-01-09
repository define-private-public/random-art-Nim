import strutils
import tables
import strfmt
import Expr
import ../Quadruplet
import ../util


type
  LevelExpr* = ref object of Expr
    threshold*: float


method `$`*(e: LevelExpr): string =
  return e.keyword


proc newLevelExpr*(): LevelExpr =
  var e = LevelExpr()
  e.leafs = @[]
  e.keyword = "level"
  e.arity = 3
  e.threshold = random(-1, 1)

  return e


proc newLevelExpr*(threshold: float): LevelExpr =
  var e = newLevelExpr()
  e.threshold = threshold

  return e


method eval*(e: LevelExpr, vars: VarTable): Quadruplet =
  let
    level = e.leafs[0].eval(vars)   # leveler
    a = e.leafs[1].eval(vars)
    b = e.leafs[2].eval(vars)

  # TODO tent W too?
  return newQuadruplet(
    1, #if level.w < e.threshold: a.w else: b.w,
    if level.x < e.threshold: a.x else: b.x,
    if level.y < e.threshold: a.y else: b.y,
    if level.z < e.threshold: a.z else: b.z,
  )
  

method code*(e: LevelExpr): string =
  let
    a = e.leafs[0].code()
    b = e.leafs[1].code()
    c = e.leafs[2].code()

  return "(level {0} {1} {2} {3})".fmt(e.threshold, a, b, c)


method glsl*(e: LevelExpr): string =
  let
    level = e.leafs[0].glsl()
    a = e.leafs[1].glsl()
    b = e.leafs[2].glsl()

  return "level({0}, {1}, {2}, {3})".fmt(e.threshold, level, a, b)


proc buildLevel*(
  tokens: var seq[string],
  buildEquation: proc(tokens: var seq[string]): Expr
): LevelExpr =
  # Remove the "level"
  tokens.delete(0)

  # Get the threshold
  let threshold = tokens[0].parseFloat
  tokens.delete(0)

  # Create the level and its children
  var
    lvl = newLevelExpr(threshold)
    a = buildEquation(tokens)
    b = buildEquation(tokens)
    c = buildEquation(tokens)

  lvl.leafs.add(a)
  lvl.leafs.add(b)
  lvl.leafs.add(c)

  return lvl

