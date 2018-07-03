using WaterModels
using Base.Test
using Gurobi
using JuMP, AmplNLWriter
using InfrastructureModels
using Ipopt
using Memento

# Suppress warnings during testing.
setlevel!(getlogger(InfrastructureModels), "error")
setlevel!(getlogger(WaterModels), "error")

# Solver setup.
solver = AmplNLSolver("bonmin")
# solver = GurobiSolver()
# solver = IpoptSolver()

# Perform the tests.
@testset "WaterModels" begin
    #include("data.jl")
    #include("expansion.jl")
    include("feasibility.jl")
end
