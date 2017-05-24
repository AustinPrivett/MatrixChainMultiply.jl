# MatrixChainMultiply

[![Build Status](https://travis-ci.org/AustinPrivett/MatrixChainMultiply.jl.svg?branch=master)](https://travis-ci.org/AustinPrivett/MatrixChainMultiply.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/e1y8l6w9bjcuwame?svg=true)](https://ci.appveyor.com/project/AustinPrivett/matrixchainmultiply-jl)
[![Coverage Status](https://coveralls.io/repos/github/AustinPrivett/MatrixChainMultiply.jl/badge.svg?branch=master)](https://coveralls.io/github/AustinPrivett/MatrixChainMultiply.jl?branch=master)

The cost of multiplying a chain of matrices can vary significantly (e.g., by 1-2 orders of magnitude in real problems) depending on the order in which the multiplication steps are applied. The
[Matrix chain multiplication](https://www.wikiwand.com/en/Matrix_chain_multiplication)
algorithm applied here (described in *Introduction to Algorithms, 3rd Edition*
by Cormen et al.) finds the optimal multiplication sequence.

With Julia, it is easy to allow for specialization on the matrix types.
For example, the types given in the [ArrayFire.jl](https://github.com/JuliaComputing/ArrayFire.jl) package or matrices of matrices (block matrices) should work, too. To be clear, the `*(x, y)` that applies to a specific types of `x` and `y` is automatically used with Julia's multiple-dispatch system after the operation order is optimized.

## Installing this Package

Since this package is not registered, you must install it by cloning. To add this package, use:

```julia
Pkg.clone("https://github.com/AustinPrivett/MatrixChainMultiply.jl")
```

## Using this Package

The only function most users should need is `matrixchainmultiply`,
added to the scope by writing:

```julia
using MatrixChainMultiply
using BenchmarkTools

a = rand(1000,1000)
b = rand(1000,100)
c = rand(100, 500)
d = rand(500)

@benchmark result1 = matrixchainmultiply(a,b,c,d)
@benchmark result2 = *(a,b,c,d)
```

which gives

```
julia> @benchmark result1 = matrixchainmultiply(a,b,c,d)
BenchmarkTools.Trial:
  memory estimate:  18.45 KiB
  allocs estimate:  42
  --------------
  minimum time:     265.715 μs (0.00% GC)
  median time:      299.071 μs (0.00% GC)
  mean time:        329.042 μs (0.16% GC)
  maximum time:     4.162 ms (74.04% GC)
  --------------
  samples:          10000
  evals/sample:     1

julia> @benchmark result2 = *(a,b,c,d)
BenchmarkTools.Trial:
  memory estimate:  4.59 MiB
  allocs estimate:  5
  --------------
  minimum time:     4.178 ms (0.00% GC)
  median time:      4.765 ms (0.00% GC)
  mean time:        5.281 ms (8.05% GC)
  maximum time:     11.310 ms (18.85% GC)
  --------------
  samples:          944
  evals/sample:     1
```

You can see the optimal ordering and the cost of the operation

```
matrixchainmultiply(a',b,c,d; printout=true)
```

Note that the optional keyword argument `printout=true` prints out the
optimal multiplication order and the number of FLOPS in case you want
to investigate. It is `false` by default.

## When to use this

It is certainly
possible to see speedups of one or two orders of magnitude through the
use of the optimal operation order generated here.

If all matrices are the same size, the overhead of the optimization is
not worth the (non-existing) benefit.

## Future improvements

* Recognize situations that don't need the analysis to eliminate the
  overhead (allowing for a more ubiquitous use of `matrixchainmultiply(...)`
  instead of `*(...)`).
* For repeated uses, given some matrix size sequence (so at run time), produce
  the function a single time at run time so that the analysis isn't done
  unnecessarily.
* Faster or more general algorithms (i.e., those that apply to the general
  tensor problem) are certainly desirable if you would like to add them.
  
## Similar Package

It has come to my attention that another package implementing this
is [DynMultiply.jl](https://github.com/LMescheder/DynMultiply.jl.).
