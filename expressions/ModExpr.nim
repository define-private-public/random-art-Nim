import tables
import strfmt
import Expr
import ../Quadruplet
import ../util


type
  ModExpr* = ref object of Expr


method `$`*(e: ModExpr): string =
  return e.keyword


proc newModExpr*(): ModExpr =
  var e = ModExpr()
  e.leafs = @[]
  e.keyword = "mod"
  e.arity = 2

  return e


proc newModExpr*(threshold: float): ModExpr =
  var e = newModExpr()

  return e


method eval*(e: ModExpr, vars: VarTable): Quadruplet =
  let
    a = e.leafs[0].eval(vars)
    b = e.leafs[1].eval(vars)

  # TODO use W instead?
  # TODO maybe this should use builtin modulo instead?
  return newQuadruplet(
    1, #pyMod(a.w, b.w),
    pyMod(a.x, b.x),
    pyMod(a.y, b.y),
    pyMod(a.z, b.z),
  )


method code*(e: ModExpr): string =
  let
    a = e.leafs[0].code()
    b = e.leafs[1].code()

  return "(mod {0} {1})".fmt(a, b)


method glsl*(e: ModExpr): string =
  let
    a = e.leafs[0].glsl()
    b = e.leafs[1].glsl()

  return "mod({0}, {1})".fmt(a, b)
  

proc buildMod*(
  tokens: var seq[string],
  buildEquation: proc(tokens: var seq[string]): Expr
): ModExpr =
  # Remove the "mod"
  tokens.delete(0)

  # Create the modulo and build the leafs
  var
    m = newModExpr()
    left = buildEquation(tokens)
    right = buildEquation(tokens)

  m.leafs.add(left)
  m.leafs.add(right)

  return m

