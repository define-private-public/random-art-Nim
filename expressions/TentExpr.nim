import strfmt
import Expr
import ../util
import ../Quadruplet


type
  TentExpr* = ref object of Expr


# This will create a new Tent Expression ( a tent-like graph)
proc newTentExpr*(): TentExpr =
  # Set the base stuff
  var e = TentExpr()
  e.keyword = "tent"
  e.leafs = @[]
  e.arity = 1

  return e


method eval*(e: TentExpr, vars: VarTable): Quadruplet =
  let
    a = e.leafs[0].eval(vars)

  # TODO tent the alpha value too?
  return newQuadruplet(
    1,# tent(a.w),
    tent(a.x),
    tent(a.y),
    tent(a.z)
  )


method code*(e: TentExpr): string =
  let a = e.leafs[0].code()

  return "(tent {0})".fmt(a)


method glsl*(e: TentExpr): string =
  let a = e.leafs[0].glsl()

  return "tent({0})".fmt(a)


proc buildTent*(
  tokens: var seq[string],
  buildEquation: proc(tokens: var seq[string]): Expr
): TentExpr =
  # Remove the "tent"
  tokens.delete(0)

  # Create the tent and it's child
  var
    t = newTentExpr()
    child = buildEquation(tokens)

  t.leafs.add(child)

  return t

