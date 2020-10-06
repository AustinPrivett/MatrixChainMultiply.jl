module MatrixChainMultiply

export matrixchainmultiply

### mcm = matrix chain multiply

"""
  `matrixchainmultiply(A,B,C,D,...)`

Algorithm for **Matrix-chain multiplication** (where matrices are also
generalizations of scalars and vectors). Using *Cormen* Ed. 3, p. 371.

Arguments
---------
`A,B,C,...` are matrices, vectors, or scalars of appropriate sizes.

"""
function matrixchainmultiply(A...)
  p = mcm_makep(A...)
  m, s, n = mcm_cost_matrices(p)
  mcm_compute(s, 1, n, A...)
end
"""
  `matrixchainmultiply(fn_name::String, A...)`

Print out the optimal matrix order as an expresion and its
cost. Also use this to...

Construc a function for repeated use (Julia v0.6-?)
---------------------------------------------------
Sometimes, you will do a chain multiplication many times with matrices of the same size. Another use case for this is to do the analysis on the CPU but use the generated function on the GPU. In either case, you only need to find the optimal order and JIT compile that function once. To save this function to the global scope:

```julia
a = rand(Float32, 10000,2000)
b = rand(Float32, 2000,100)
c = rand(Float32, 100)

eval(matrixchainmultiply("mcm_abc", a,b,c))

mcm_abc(a,b,c)

# multiple-dispatch is nice; taking advantage below
using ArrayFire
aa = AFArray(a)
ab = AFArray(b)
ac = AFArray(c)

mcm_abc(aa,ab,ac)  # no new analysis; ke
```
"""
function matrixchainmultiply(fn_name::String, A...)
  matrixchainmultiply_fn(fn_name, A...)
end
function matrixchainmultiply_fn(fn_name::String, A...)
  p = mcm_makep(A...)
  m, s, n = mcm_cost_matrices(p)
  ex = parse(fn_name * "(A...) = " * mcm_print(s, 1, n))
  cost = m[1,n]
  println("Operation: $ex")
  println("Cost: $cost")
  ex
end

"Cost information tells which order to do."
function mcm_cost_matrices(p::Vector{Int})
  ∞ = typemax(Int)  # watch for overflow?
  n = length(p) - 1  # number of matrices
  @assert (n > 1) "TODO: allow to use for short lists"
  # stores costs
  m = zeros(Int, (n, n))
  # records corresponding indices
  s = zeros(Int, (n-1, n-1))  # Cormen has 2nd index going 2..n
  # zero on diagonals
  for i ∈ 1:n
    m[i,i] = 0
  end
  # l is chain length
  for l ∈ 2:n
    for i ∈ 1:(n-l+1)
      j = i + l - 1
      m[i,j] = ∞  # this should be replaced?!
      for k ∈ i:(j-1)
        q1 = m[i,k]
        q2 = m[k+1,j]
        q3 = p[i] * p[k+1] * p[j+1]  # Cormen p vec indexed from 0
        q = +(q1, q2, q3)
        if q < m[i,j]
          m[i,j] = q
          s[i,j-1] = k
        end
      end
    end
  end
  m, s, n
end

"Use this if you want to see what the operation looks like."
function mcm_print(s::Matrix, i::Int, j::Int)
  str = ""
  if i!=j
    a = mcm_print(s, i, s[i, j-1])
    b = mcm_print(s, s[i, j-1] + 1, j)
    return "($a * $b)"
  else
    return "A[$i]"
  end
end

"""
The function describing the optimal order for the input of a specific size.
"""
function mcm_optimalorder(s, i, j, mats...)
  if i!=j
    m1 = mcm_compute(s, i, s[i, j-1], mats...)
    m2 = mcm_compute(s, s[i, j-1] + 1, j, mats...)
    return :(m1 * m2)
  else
    return mats[i]
  end
end

"Do the actual matrix chain multiplication computation."
function mcm_compute(s, i, j, mats...)
  if i!=j
    m1 = mcm_compute(s, i, s[i, j-1], mats...)
    m2 = mcm_compute(s, s[i, j-1] + 1, j, mats...)
    return (m1 * m2)
  else
    return mats[i]
  end
end

"The matrix sizes."
function mcm_makep(mats...)
  # Made some assumptions below that disallow these
  lenmats = length(mats)
  # convert to matrix-style sizes
  msizes = map(msize, mats)
  # produce unique number list
  p = zeros(Int, lenmats + 1)
  for i in 1:lenmats
    firstiter::Bool = (i==1)
    if firstiter
      p[1] = msizes[1][1]
    else
      check1 = msizes[i-1][2]
      check2 = msizes[i][1]
      @assert (check1 == check2) "Matrix sizes don't match ($check1 != $check2)!"
    end
    p[i+1] = msizes[i][2]
  end
  p
end

###

"""
Matrix-style sizes. Return type looks like `(i,j)` where `i` and `j` are `Ints`.

If other packages with matrix types (e.g., OpenCl or ArrayFire) inherit from
AbstractArray, there shouldn't be issues with other packages using this one.
"""
msize(m::AbstractMatrix) = size(m)
msize(v::AbstractVector) = (size(v,1), 1)
msize(s::Number) = (1, 1)


end # module
