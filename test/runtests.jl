using WaterModels
using Test
using Cbc
using JuMP
using InfrastructureModels
using Memento
using Ipopt

# Suppress warnings during testing.
setlevel!(getlogger(InfrastructureModels), "error")
setlevel!(getlogger(WaterModels), "error")

# Solver setup.
cbc = CbcSolver(logLevel = 1)
ipopt = IpoptSolver(print_level = 0)

# Perform the tests.
@testset "WaterModels" begin
    include("data.jl")
    include("wf_hw.jl")
    #include("wf_dw.jl")
    #include("ne_hw.jl")
end
