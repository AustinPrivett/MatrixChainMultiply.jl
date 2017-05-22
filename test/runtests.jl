using MatrixChainMultiply
using Base.Test

# write your own tests here
"Cost of analysis may outweigh savings for small/square matrices."
function mcm_test(bigtest=true)
  # Matching Cormen Ed. 3 p. 371
  smallm = [rand(30, 35), rand(35,15), rand(15, 5),
            rand(5,10), rand(10,20), rand(20,25)]
  # example where speedup should be obvious
  bigm =   [rand(5000,4000), rand(4000,3000), rand(3000, 2000),
            rand(2000, 1)]
  # compile once so not included in timing
  *(smallm...)
  # now do test and timing
  matrixchainmultiply(smallm...)
  bigtest ? (mats = bigm) : (mats = smallm)
  println("Default grouping...")
  tic(); defres = *(mats...); t_def = toc()
  println()
  println("Optimal grouping...")
  tic(); optres = matrixchainmultiply(mats...; printout=true); t_opt = toc()
  println()
  if t_def < t_def
    t = t_opt / t_def
    println("DEFAULT method is $t times FASTER.")
  else
    t = t_def / t_opt
    println("MatrixChainMultiplication method is $t times FASTER.")
  end
  defres - optres
end

@test norm(mcm_test()) < 1e-4
