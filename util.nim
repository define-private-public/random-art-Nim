import math
import random


randomize()


# maps one value from one range to another
proc map*(x, a, b, p, q: float): float {.inline.} =
  return (x - a) * (q - p) / (b - a) + p


# makes a random value from the provided range
proc random*(min, max: float): float =
  var r = random(1_000_000.0)
  return map(r, 0, 1_000_000, min, max)


# makes a random value between [min, max)
proc randrange*(min, max: int): int =
  return (random(max - min) + min)


# Given an input, it can make a tent-like output (if graphed)
# x -- should be a value (normally) between [-1, 1] for best results
# Returns: A value between (-infinity, 1]
proc tent*(x: float): float =
  return (1 - (2 * abs(x)))


# Given an input, it can make a well-like output (if graphed)
# x -- a value that should (normally) be between [-2, 2] for best results
# Returns: value between [-1, 1]
proc well*(x: float): float =
  return (1 - (2 / pow(1 + (x * x), 8)))


# Preforms a modulo operation like the one found in Python (a.k.a "true")
# modulo, not remainder modulo like in C.  Also, because of the nature of
# this application, if M=0, this will return 0, instead of throwing a
# DivByZeroError like it should
# n -- numerator
# M -- denominator
proc pyMod*(n, M: float): float=
  if M == 0:
#    raise newException(DivByZeroError, "Can't modulo by 0")
    return 0

  return ((n mod M) + M) mod M


