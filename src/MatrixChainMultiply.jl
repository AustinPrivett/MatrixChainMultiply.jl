module MatrixChainMultiply

export matrixchainmultiply

"""
Matrix-style sizes. Return type looks like `(i,j)` where `i` and `j` are `Ints`.

If other packages with matrix types (e.g., OpenCl or ArrayFire) inherit from
AbstractArray, there shouldn't be issues with other packages using this one.
"""
msize{T}(m::AbstractArray{T,2}) = size(m)
msize{T}(v::AbstractArray{T,1}) = (size(v)[1], 1)
msize{T<:Number}(s::T) = (1, 1)

"The matrix sizes for matrixchainmultiply."
function makep(mats...)
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

"""
  `matrixchainmultiply(A,B,C,D,...; printout=false)`

Algorithm for *Matrix-chain multiplication* (where matrices are also
generalizations of scalars and vectors). Using Cormen Ed. 3, p. 371.

`A,B,C,...` are matrices, vectors, or scalars of appropriate sizes.

`printout` skips the computation and returns the expression that would be
evaluated.
"""
function matrixchainmultiply(A...; printout::Bool=false)
  p = makep(A...)
  m, s, n = mcm_cost_matrices(p)
  # With these results, now do the multiplication.
  if printout
    println("Operation: ", mcm_print(s,1,n, "x"))
    cost = m[1,n]
    println("Cost: $cost")
  end
  mcm_compute(s, 1, n, A...)
  # In case this function is used regularly, it would be ideal to produce a new
  # function that can be used multiple times. I don't think the compiler
  # currently does this.
end

"Get cost information."
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
function mcm_print(s::Matrix, i::Int, j::Int, A::String="A")
  str = ""
  if i!=j
    str *= "("
    str *= mcm_print(s, i, s[i, j-1], A)
    str *= "*"
    str *= mcm_print(s, s[i, j-1] + 1, j, A)
    str *= ")"
  else
    return "$A[$i]"
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

end # module
