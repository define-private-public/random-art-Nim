# This file contains functions that will generate an expression

import random
import algorithm
import expressions/Expr

# Terminal
import expressions/ZeroExpr
import expressions/ConstExpr
import expressions/VarExpr

# Non-Terminal
import expressions/SumExpr
import expressions/ProductExpr
import expressions/MixExpr
import expressions/TentExpr
import expressions/WellExpr
import expressions/LevelExpr
import expressions/ModExpr
import expressions/SinExpr


# Generate a (random) expression tree with `k` Nodes
proc generate*(k: int = 50): Expr =
  if k <= 0:
    # Generate terminals (0 arity)
    case random(2):
      # Constant value
      of 0:
        return newConstExpr()

      # Variable (x or y)
      of 1:
        # Chose between X or Y:
        var name = ""
        if random(2) == 0:
          name = "x"
        else:
          name = "y"

        return newVarExpr(name)

      # It should never hit this
      else:
        return newZeroExpr()

  else:
    # generate non-terminals (+1 arity)
    var op: Expr

    case random(8):
      # Sum
      of 0: op = newSumExpr()

      # Product
      of 1: op = newProductExpr()

      # Mix
      of 2: op = newMixExpr()

      # Tent
      of 3: op = newTentExpr()

      # Well
      of 4: op = newWellExpr()

      # Level
      of 5: op = newLevelExpr()

      # Mod
      of 6: op = newModExpr()

      # Sin
      of 7: op = newSinExpr()

      # It should never hit this 
      else:
        return newZeroExpr()

    # Add some leaves
    var
      i = 0
      childKs: seq[int] = @[]

    for x in countup(1, op.arity - 1):
      childKs.add(random(k))
    
    for j in sorted(childKs, cmp[int]):
      op.leafs.add(generate(j - i))
      i = j

    op.leafs.add(generate(k - 1 - i))

    return op

