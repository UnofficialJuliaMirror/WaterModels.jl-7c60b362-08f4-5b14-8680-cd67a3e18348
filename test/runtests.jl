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
#solver = AmplNLSolver("couenne", filename="mymodel")
solver = GurobiSolver()

# Perform the tests.
@testset "WaterModels" begin
    #include("data.jl")
    include("feasibility.jl")
end
