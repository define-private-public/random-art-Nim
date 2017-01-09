import util


type
  # [-1, 1] -> [0x00, 0xFF]
  Quadruplet* = ref object of RootObj
    w*: float
    x*: float
    y*: float
    z*: float


proc `$`*(q: Quadruplet): string =
  return $q.w & " " &
         $q.x & " " &
         $q.y & " " &
         $q.z


# Nice ARGB format for the Quadruplet
#proc a*(q: Quadruplet): float =
#  return q.w
#proc r*(q: Quadruplet): float =
#  return q.x
#proc g*(q: Quadruplet): float =
#  return q.y
#proc b*(q: Quadruplet): float =
#  return q.z


# Creates a black Quadruplet
proc newQuadruplet*(): Quadruplet =
  return Quadruplet(w: 1, x: -1, y: -1, z: -1)

# Creates an opaque Quadruplet
proc newQuadruplet*(x, y, z: float): Quadruplet =
  return Quadruplet(w: 1, x: x, y: y, z: z)


# Creates an opqaue grey Quadruplet
proc newQuadruplet*(grey: float): Quadruplet =
  return Quadruplet(w: 1, x: grey, y: grey, z: grey)

# Creates a Quadruplet (via ARGB)
proc newQuadruplet*(a, r, g, b: float): Quadruplet =
  return Quadruplet(w: a, x: r, y: g, z: b)


# Adds two Quadruplets
proc `+`*(a, b:Quadruplet): Quadruplet =
  return newQuadruplet(
    a.w + b.w,
    a.x + b.x,
    a.y + b.y,
    a.z + b.z
  )

# Multiplies two qudrpluets
proc `*`*(a, b:Quadruplet): Quadruplet =
  return newQuadruplet(
    a.w * b.w,
    a.x * b.x,
    a.y * b.y,
    a.z * b.z
  )


# Averages two Quadruplets.  It can give a stronger weight to one side more
# than the other.  By default it's even.  If weight is closer to 0, then it's
# stronger on the first, if it's closer to 1, then it's stronger on the right
proc average*(p, q: Quadruplet, weight: float = 0.5): Quadruplet =
  var w = weight.clamp(0, 1)

  return newQuadruplet(
    (w * q.w) + ((1 - w) * p.w),
    (w * q.x) + ((1 - w) * p.x),
    (w * q.y) + ((1 - w) * p.y),
    (w * q.z) + ((1 - w) * p.z)
  )


# NOTE: this function is not being used because nimPNG requires the bytes to
#       be in a different order.  I though packing them together like this
#       would be easier, but it turns out it's not...
## Returns a Quadruplet as a nicely formatted RGBA pixel.  Remember:
## [-1, 1] -> [0x00, 0xFF].  Anything out of that range will be clamped
#proc toRGBA*(q: Quadruplet): uint32 {.inline.} =
#  let
#    r = q.x.clamp(-1, 1).map(-1, 1, 0x00, 0xFF).uint32 shl 24
#    g = q.y.clamp(-1, 1).map(-1, 1, 0x00, 0xFF).uint32 shl 16
#    b = q.z.clamp(-1, 1).map(-1, 1, 0x00, 0xFF).uint32 shl 8
#    a = q.w.clamp(-1, 1).map(-1, 1, 0x00, 0xFF).uint32
#    pixel = r or g or b or a
#
#  return pixel


proc toR*(q: Quadruplet): uint8 {.inline.} =
  return q.x.clamp(-1, 1).map(-1, 1, 0x00, 0xFF).uint8

proc toG*(q: Quadruplet): uint8 {.inline.} =
  return q.y.clamp(-1, 1).map(-1, 1, 0x00, 0xFF).uint8

proc toB*(q: Quadruplet): uint8 {.inline.} =
  return q.z.clamp(-1, 1).map(-1, 1, 0x00, 0xFF).uint8

proc toA*(q: Quadruplet): uint8 {.inline.} =
  return q.w.clamp(-1, 1).map(-1, 1, 0x00, 0xFF).uint8

