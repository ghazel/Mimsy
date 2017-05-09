# Vertices of the dodecahedron are labeled 0 to 19.
#   0 to 4 run cc-wise around a fixed starting face.
#   5 to 9 are the respective nearest neighbor vertices.
#   10 to 14 are the next nearest, with a cc-wise half shift, respectively.
#   15 to 19 are the next nearest, respectively.
# Edges are tuples (a,b) of vertex labels with a < b.
# Faces are tuples (a,b,c,d,e) of vertex labels with a == min(a,b,c,d,e).

# Symmetries are represented by permutations of the vertices, in turn
# represented by tuples of labels: g sends vertex i to vertex g[i].

# First comes the group law.

Id = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19)

def mul(g,h):
  return tuple(g[h[i]] for i in range(len(h)))

def inv(g):
    return tuple(g.index(i) for i in range(len(g)))

def pow(g, n):
  if n > 0: return mul(g, pow(g, n-1))
  if n < 0: return inv(pow(g, -n))
  return Id

# Next come some symmetries.

# Rotation 180 degrees about the edge (0,1)
bR_e = (1, 0, 5, 10, 6, 2, 4, 14, 15, 11, 3, 9, 19, 16, 7, 8, 13, 18, 17, 12)

# Rotation cc-wise of the face (0,1,2,3,4)
bR_f = (1, 2, 3, 4, 0, 6, 7, 8, 9, 5, 11, 12, 13, 14, 10, 16, 17, 18, 19, 15)

# Rotation cc-wise around the vertex 0
bR_v = inv(mul(bR_e, bR_f))

# Inversion about the origin (anti-chiral)
I = (17, 18, 19, 15, 16, 12, 13, 14, 10, 11, 8, 9, 5, 6, 7, 3, 4, 0, 1, 2)

# Using bR_e and bR_f, a table of symmetries satisfying Ref[i][0] == i
#
# Note: Each symmetry is of the form
#   mul(pow(I, i), mul(Ref[j], pow(bR_v, k)))
# for unique i=0,1, j=0,...,19, and k=0,1,2 and chiral exaclty when i==0.
Ref = (
  Id,
  bR_f,
  pow(bR_f, 2),
  pow(bR_f, 3),
  pow(bR_f, 4),
  mul(pow(bR_f, 4), mul(bR_e, pow(bR_f, 4))),
  mul(bR_e, pow(bR_f, 4)),
  mul(bR_f, mul(bR_e, pow(bR_f, 4))),
  mul(pow(bR_f, 2), mul(bR_e, pow(bR_f, 4))),
  mul(pow(bR_f, 3), mul(bR_e, pow(bR_f, 4))),
  mul(bR_e, pow(bR_f, 3)),
  mul(bR_f, mul(bR_e, pow(bR_f, 3))),
  mul(pow(bR_f, 2), mul(bR_e, pow(bR_f, 3))),
  mul(pow(bR_f, 3), mul(bR_e, pow(bR_f, 3))),
  mul(pow(bR_f, 4), mul(bR_e, pow(bR_f, 3))),
  mul(bR_e, mul(pow(bR_f, 2), mul(bR_e, pow(bR_f, 4)))),
  mul(bR_f, mul(bR_e, mul(pow(bR_f, 2), mul(bR_e, pow(bR_f, 4))))),
  mul(pow(bR_f, 2), mul(bR_e, mul(pow(bR_f, 2), mul(bR_e, pow(bR_f, 4))))),
  mul(pow(bR_f, 3), mul(bR_e, mul(pow(bR_f, 2), mul(bR_e, pow(bR_f, 4))))),
  mul(pow(bR_f, 4), mul(bR_e, mul(pow(bR_f, 2), mul(bR_e, pow(bR_f, 4))))))

# Rotation cc-wise around the vertex v:
def R_v(v):
  return mul(Ref[v], mul(bR_v, inv(Ref[v])))

# Rotation 180 degrees about the edge e:
def R_e(e):
  e1 = inv(Ref[e[0]])[e[1]]
  i = 0
  if e1 == 4: i = 1
  if e1 == 5: i = 2
  g = mul(Ref[e[0]], pow(bR_v, i))
  return mul(g, mul(bR_e, inv(g)))

# Rotation cc-wise of the face f:
def R_f(f):
  f1 = inv(Ref[f[0]])[f[1]]
  i = 0
  if f1 == 4: i = 1
  if f1 == 5: i = 2
  g = mul(Ref[f[0]], pow(bR_v, i))
  return mul(g, mul(bR_f, inv(g)))

# We turn to the action of the symmetry group on the geometric objects.

# The result of letting the symmetry g act on the vertex v
def act_v(g, v):
  return g[v]

def edge(e):
  if e[0] < e[1]: return e
  return (e[1],e[0])

# The result of letting the symmetry g act on the edge e
def act_e(g, e):
  return edge((g[e[0]], g[e[1]]))

def face(f):
  m = min(f)
  if m == f[0]: return f
  if m == f[1]: return (f[1], f[2], f[3], f[4], f[0])
  if m == f[2]: return (f[2], f[3], f[4], f[0], f[1])
  if m == f[3]: return (f[3], f[4], f[0], f[1], f[2])
  return (f[4], f[0], f[1], f[2], f[3])

# The result of letting the symmetry g act on the face f
def act_f(g, f):
  return face((g[f[0]], g[f[1]], g[f[2]], g[f[3]], g[f[4]]))

# Examples:

# Symmetries built from our explicit cases above
g = mul(R_e((7, 11)), mul(R_f((3, 8, 13, 9, 4)), R_v(19)))
h = mul(I, g)
g_inv = inv(g)

# Some base objects
base_v = 0
base_e = (0, 1)
base_f = (0, 1, 2, 3, 4)

# See how they act!
print act_v(g, base_v)
print act_e(h, base_e)
print act_f(g_inv, base_f)









faces = [

    [0,1,2,3,4],
  
    [0,1,6,10,5],
    [1,2,7,11,6],
    [2,3,8,12,7],
    [3,4,9,13,8],
    [4,0,5,14,9],
  
    [15,16,11,6,10],
    [16,17,12,7,11],
    [17,18,13,8,12],
    [18,19,14,9,13],
    [19,15,10,5,14],
    
    [15,16,17,18,19],
  ]
