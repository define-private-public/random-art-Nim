import tables
import strfmt
import Expr
import ../Quadruplet

type
  VarExpr* = ref object of Expr
    name*: string


# This will create a new Var Expression
proc newVarExpr*(name: string): VarExpr =
  # Set the base stuff
  var e = VarExpr()
  e.keyword = "var"
  e.leafs = @[]
  e.arity = 0

  e.name = name

  return e


method eval*(e: VarExpr, vars: VarTable): Quadruplet =
  return newQuadruplet(vars[e.name])


method code*(e: VarExpr): string =
  return "(var {0})".fmt(e.name)


method glsl*(e: VarExpr): string =
  case e.name:
    of "x": return "vec3(vPos.x, vPos.x, vPos.x)"
    of "y": return "vec3(-vPos.y, -vPos.y, -vPos.y)"
    else: return "vec3(0, 0, 0)"


proc buildVar*(
  tokens: var seq[string],
  buildEquation: proc(tokens: var seq[string]): Expr
): VarExpr =
  # Remove the "var"
  tokens.delete(0)

  # pull out the variable name
  let name = tokens[0]
  tokens.delete(0)

  # Create the variable
  return newVarExpr(name)

