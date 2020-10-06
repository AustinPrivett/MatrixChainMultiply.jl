using MatrixChainMultiply
using Test, LinearAlgebra

# case on readme
function readme_example(use_arrayfire=false)
  if use_arrayfire
    T = AFArray{Float64}
  else
    T = Float64
  end
  a = rand(T, 1000, 1000)
  b = rand(T, 1000, 100)
  c = rand(T, 100, 500)
  d = rand(T, 500)

  # get results
  result1 = *(a,b,c,d)
  result2 = matrixchainmultiply(a,b,c,d)
  difference = result1 - result2

  # do again to get timings
  t1 = time()
  *(a,b,c,d);
  stdtime = time() - t1
  t2 = time()
  matrixchainmultiply(a,b,c,d);
  chaintime = time() - t2
  speedup = stdtime / chaintime
  print("Speedup = $speedup")

  difference, speedup
end

difference, speedup = readme_example()

@test norm(difference) < 1e-5
@test speedup > 1.0
