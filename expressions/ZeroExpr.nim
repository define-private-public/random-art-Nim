import tables
import Expr
import ../Quadruplet


# Produces a middle grey expression
type
  ZeroExpr* = ref object of Expr


proc newZeroExpr*(): ZeroExpr =
  var e = ZeroExpr()
  e.keyword = "zero"
  e.leafs = @[]
  e.arity = 0
  return e


method eval*(e: ZeroExpr, vars: VarTable): Quadruplet =
  return newQuadruplet(0)


method code*(e: ZeroExpr): string =
  return "(zero)"


method glsl*(e: ZeroExpr): string =
  return "vec3(0, 0, 0)"


proc buildZero*(
  tokens: var seq[string],
  buildEquation: proc(tokens: var seq[string]): Expr
): ZeroExpr =
  # Remove the "zero"
  tokens.delete(0)
  return newZeroExpr()

