using MatrixChainMultiply
using Base.Test

# case on readme
function readme_example()
  a = rand(1000,1000)
  b = rand(1000,100)
  c = rand(100, 500)
  d = rand(500)

  # get results
  result1 = *(a,b,c,d)
  result2 = matrixchainmultiply(a,b,c,d)
  difference = result1 - result2

  # do again to get timings
  tic(); *(a,b,c,d); stdtime = toc()
  tic(); matrixchainmultiply(a,b,c,d); chaintime = toc()
  speedup = stdtime / chaintime
  print("Speedup = $speedup")

  difference, speedup
end

difference, speedup = readme_example()

@test norm(difference) < 1e-7
@test speedup > 1.0
