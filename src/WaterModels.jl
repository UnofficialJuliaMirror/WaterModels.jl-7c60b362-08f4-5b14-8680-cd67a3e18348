isdefined(Base, :__precompile__) && __precompile__()

module WaterModels

using JSON
using InfrastructureModels
using MathProgBase
using JuMP
using Memento

# Create and initialize the module level logger.
const LOGGER = getlogger(@__MODULE__)
__init__() = Memento.register(LOGGER)

include("io/common.jl")
include("io/epanet.jl")

include("core/base.jl")
include("core/constraint.jl")
include("core/constraint_template.jl")
include("core/data.jl")
include("core/objective.jl")
include("core/solution.jl")
include("core/variable.jl")

include("form/cvxnlp.jl")
include("form/micp.jl")
#include("form/milp.jl")
include("form/milp_r.jl")
include("form/minlp_b.jl")
include("form/nlp.jl")
include("form/shared.jl")
include("form/equality.jl")
include("form/exact.jl")
include("form/relaxed.jl")

include("prob/cvx.jl")
include("prob/ne.jl")
include("prob/wf.jl")

include("alg/repair.jl")
include("alg/solve_global.jl")

end
