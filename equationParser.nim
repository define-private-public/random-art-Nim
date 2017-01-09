# This is what transforms a string into an equation

import strutils
import sequtils
import tables
import expressions/Expr
import expressions/ZeroExpr
import expressions/ConstExpr
import expressions/VarExpr
import expressions/SumExpr
import expressions/ProductExpr
import expressions/MixExpr
import expressions/TentExpr
import expressions/WellExpr
import expressions/LevelExpr
import expressions/ModExpr
import expressions/SinExpr


# Function Prototypes
proc buildEquation(tokens: var seq[string]): Expr {.procvar.}


## Some instantiated expressions
#let
#  zeroEx = newZeroExpr()
#  constEx = newConstExpr()
#  varEx = newVarExpr("var")
#  sumEx = newSumExpr()
#  productEx = newProductExpr()
#  mixEx = newMixExpr()
#  tentEx = newTentExpr()
#  wellEx = newWellExpr()
#  levelEx = newLevelExpr()
#  modEx = newModExpr()
#  sinEx = newSinExpr()


proc parseEquation*(code: string): Expr =
  # Make all of the whitespace just spaces
  var cleanedCode = code
  for ws in Whitespace:
    if ws != ' ':
      cleanedCode = cleanedCode.replace(ws, ' ')

  # Tokenize the input
  let separators = {' ', '(', ')'}
  var tokens = cleanedCode.split(separators)
  keepIf(tokens, proc(x: string): bool = (x.len != 0))  # Make sure we have no empty tokens

  return buildEquation(tokens)


proc buildEquation(tokens: var seq[string]): Expr =
  # Make sure we've got something to work with
  if tokens.len == 0:
    return newZeroExpr()

  # NOTE: another implemetion I made used a hash/dictionary/table that mapped 
  #       keywords over to function pointers, so I've unfortunatley had to hard
  #       code in the the keywords.  I wish I understood the Nim langauge a bit
  #       more to do some dynamic dispatch.
  case tokens[0]:
    of "zero":
      return buildZero(tokens, buildEquation)
    of "const":
      return buildConst(tokens, buildEquation)
    of "sum":
      return buildSum(tokens, buildEquation)
    of "mul":
      return buildProduct(tokens, buildEquation)
    of "mod":
      return buildMod(tokens, buildEquation)
    of "well":
      return buildWell(tokens, buildEquation)
    of "tent":
      return buildTent(tokens, buildEquation)
    of "sin":
      return buildSin(tokens, buildEquation)
    of "level":
      return buildLevel(tokens, buildEquation)
    of "mix":
      return buildMix(tokens, buildEquation)
    of "var":
      return buildVar(tokens, buildEquation)
    else:
      # Hitting this should cause it to build an invalid equation
      discard

