# MatrixChainMultiply

[![Build Status](https://travis-ci.org/AustinPrivett/MatrixChainMultiply.jl.svg?branch=master)](https://travis-ci.org/AustinPrivett/MatrixChainMultiply.jl)

[![Coverage Status](https://coveralls.io/repos/AustinPrivett/MatrixChainMultiply.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/AustinPrivett/MatrixChainMultiply.jl?branch=master)

[![Build status](https://ci.appveyor.com/api/projects/status/e1y8l6w9bjcuwame?svg=true)](https://ci.appveyor.com/project/AustinPrivett/matrixchainmultiply-jl)

[![codecov.io](http://codecov.io/github/AustinPrivett/MatrixChainMultiply.jl/coverage.svg?branch=master)](http://codecov.io/github/AustinPrivett/MatrixChainMultiply.jl?branch=master)

The cost of multiplying a chain of matrices can vary significantly depending on the order in which the multiplication steps are applied. The [Matrix chain multiplication](https://www.wikiwand.com/en/Matrix_chain_multiplication) algorithm applied here (described in *Introduction to Algorithms, 3rd Edition* by Cormen et al.) finds the optimal multiplication sequence.
