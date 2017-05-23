# MatrixChainMultiply

[![Build Status](https://travis-ci.org/AustinPrivett/MatrixChainMultiply.jl.svg?branch=master)](https://travis-ci.org/AustinPrivett/MatrixChainMultiply.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/e1y8l6w9bjcuwame?svg=true)](https://ci.appveyor.com/project/AustinPrivett/matrixchainmultiply-jl)
[![Coverage Status](https://coveralls.io/repos/github/AustinPrivett/MatrixChainMultiply.jl/badge.svg?branch=master)](https://coveralls.io/github/AustinPrivett/MatrixChainMultiply.jl?branch=master)

The cost of multiplying a chain of matrices can vary significantly depending on the order in which the multiplication steps are applied. The [Matrix chain multiplication](https://www.wikiwand.com/en/Matrix_chain_multiplication) algorithm applied here (described in *Introduction to Algorithms, 3rd Edition* by Cormen et al.) finds the optimal multiplication sequence.

With Julia, it is easy to allow for specialization on the matrix types.
For example, the types given in the ArrayFire.jl package or matrices of matrices (block matrices) should work, too.

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

a = rand(1000)
b = rand(1000,20)
c = rand(20,4500)
d = rand(4500)
e = 29.3 / 380.2

result1 = matrixchainmultiply(a',b,c,d,e; printout=true)
result2 = *(a',b,c,d,e)
```

Note that the optional keyword argument `printout=true` prints out the
optimal multiplication order and the number of FLOPS in case you want
to investigate. It is `false` by default.

## When to use this

To test this package and see an example speedup on your system,

```julia
Pkg.test("MatrixChainMultiply")
```

On my system, the `matrixchainmultiply(...)` generates results
**~17.4 times faster** than the standard Julia `*(...)` function (which
evaluates left-to-right instead of optimally). It is certainly
possible to see speedups of one or two orders of magnitude through the
use of the optimal operation order generated here.

If all matrices are the same size, the overhead of the optimization is
not worth the (non-existing) benefit.

## Future improvements

* Recognize situations that don't need the analysis to eliminate the
  overhead (allowing for a more ubiquitous use of `matrixchainmultiply(...)`
  instead of `*(...)`).
* For repeated uses, given some matrix size sequence, produce the
  function a single time so that the analysis isn't done unnecessarily.
* Faster or more general algorithms (i.e., those that apply to the general
  tensor problem) are certainly desirable if you would like to add them.
