import strfmt
import Expr
import ../Quadruplet

# TODO in the future, maybe this should add more than two leafs
#      This can already be done by chaining adds (e.g. (add a (add b c))
#      the only thing that may be odd is that I would need to modify the
#      arity.  Would also need to modify the eval() and code() methods

type
  SumExpr* = ref object of Expr


# This will create a new Sum Expression
proc newSumExpr*(): SumExpr =
  # Set the base stuff
  var e = SumExpr()
  e.keyword = "sum"
  e.leafs = @[]
  e.arity = 2

  return e


method eval*(e: SumExpr, vars: VarTable): Quadruplet =
  # TODO this should actually add the quads, not average them
  #      it's the same as MixExpr right now!
  let
    a = e.leafs[0].eval(vars)
    b = e.leafs[1].eval(vars)
  return average(a, b)


method code*(e: SumExpr): string =
  let
    a = e.leafs[0].code()
    b = e.leafs[1].code()

  return "(sum {0} {1})".fmt(a, b)


method glsl*(e: SumExpr): string =
  # TODO is it right to use the average function here?
  let
    a = e.leafs[0].glsl()
    b = e.leafs[1].glsl()

  return "average({0}, {1})".fmt(a, b)


proc buildSum*(
  tokens: var seq[string],
  buildEquation: proc(tokens: var seq[string]): Expr
): SumExpr =
  # Remove the "sum"
  tokens.delete(0)

  # Create the sum and build the leafs
  var
    s = newSumExpr()
    left = buildEquation(tokens)
    right = buildEquation(tokens)
  
  s.leafs.add(left)
  s.leafs.add(right)

  return s

