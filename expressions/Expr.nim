import tables
import ../Quadruplet


# TODO maybe the VarTable should point to Quadruplets instead of floats?
#      it's kind of boring that the VarExpression can only do a greyscale
#      right now, and it's because of this (sort of)  Think about chaning
#      it, and VarExpr::eval() too!
type
  VarTable* = TableRef[string, float]


proc newVarTable*(): VarTable =
  return newTable[string, float]()


type
  Expr* = ref object of RootObj
    leafs*: seq[Expr]
    keyword*: string
    arity*: int


method `$`*(e: Expr): string {.base.} =
  return e.keyword


proc newExpr*(): Expr =
  var e = Expr()
  e.leafs = @[]
  e.keyword = "expr"
  e.arity = 0
  return e


## Finds the value of the expression, with the given variables
method eval*(e: Expr, vars: VarTable): Quadruplet {.base.} =
  return newQuadruplet(1, 0, 0, 0)


## Returns the equation as a string
method code*(e: Expr): string {.base.} =
  return "(expr)"


## Returns the equation as GLSL code
method glsl*(e: Expr): string {.base.} =
  return ""


# NOTE: Every expression should have its own "build," function that follows
#       this pattern. the passed in `tokens` paramter will be modified by
#       the function.  It should (at least) remove the first element from the
#       sequence.  Any other tokens it needs to take should also be removed
#       from the beginning.  See of the expressions (e.g. SinExpr) for examples
#       
#       If the expression has leafs, then it should call the "buildExpression"
#       proc (that is passed in) to build those leafs as well.
#proc buildExpr*(
#  tokens: var seq[string],
#  buildEquation: proc(tokens: var seq[string]): Expr
#): Expr =
#  return newExpr()

