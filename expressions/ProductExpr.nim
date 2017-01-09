import strfmt
import Expr
import ../Quadruplet

# TODO in the future, maybe this should multiply more than two leafs
#      This can already be done by chaining products (e.g. (mul a (mul b c))
#      the only thing that may be odd is that I would need to modify the
#      arity.  Would also need to modify the eval() and code() methods

type
  ProductExpr* = ref object of Expr


# This will create a new Product Expression
proc newProductExpr*(): ProductExpr =
  # Set the base stuff
  var e = ProductExpr()
  e.keyword = "mul"
  e.leafs = @[]
  e.arity = 2

  return e


method eval*(e: ProductExpr, vars: VarTable): Quadruplet =
  let
    a = e.leafs[0].eval(vars)
    b = e.leafs[1].eval(vars)
  return a * b


method code*(e: ProductExpr): string =
  let
    a = e.leafs[0].code()
    b = e.leafs[1].code()
  
  return "(mul {0} {1})".fmt(a, b)


method glsl*(e: ProductExpr): string =
  let
    a = e.leafs[0].glsl()
    b = e.leafs[1].glsl()

  return "({0} * {1})".fmt(a, b)


proc buildProduct*(
  tokens: var seq[string],
  buildEquation: proc(tokens: var seq[string]): Expr
): ProductExpr =
  # Remove the "mul"
  tokens.delete(0)

  # Create the product and build the leafs
  var
    m = newProductExpr()
    left = buildEquation(tokens)
    right = buildEquation(tokens)

  m.leafs.add(left)
  m.leafs.add(right)

  return m

