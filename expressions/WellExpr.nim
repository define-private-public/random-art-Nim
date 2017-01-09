import strfmt
import Expr
import ../util
import ../Quadruplet


type
  WellExpr* = ref object of Expr


# This will create a new Well Expression ( a well-like graph)
proc newWellExpr*(): WellExpr =
  # Set the base stuff
  var e = WellExpr()
  e.keyword = "well"
  e.leafs = @[]
  e.arity = 1

  return e


method eval*(e: WellExpr, vars: VarTable): Quadruplet =
  let
    a = e.leafs[0].eval(vars)

  # TODO well the alpha value too?
  return newQuadruplet(
    1, #well(a.w),
    well(a.x),
    well(a.y),
    well(a.z)
  )


method code*(e: WellExpr): string =
  let a = e.leafs[0].code()
  return "(well {0})".fmt(a)


method glsl*(e: WellExpr): string =
  let a = e.leafs[0].glsl()

  return "well({0})".fmt(a)


proc buildWell*(
  tokens: var seq[string],
  buildEquation: proc(tokens: var seq[string]): Expr
): WellExpr =
  # Remove the "well"
  tokens.delete(0)

  # Create the well and it's child
  var
    w = newWellExpr()
    child = buildEquation(tokens)

  w.leafs.add(child)

  return w

