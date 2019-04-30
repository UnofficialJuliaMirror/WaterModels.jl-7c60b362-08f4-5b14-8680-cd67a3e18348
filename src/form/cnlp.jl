# Define CNLP (convex nonlinear programming) implementations of water distribution models.
export CNLPWaterModel, StandardCNLPForm

"AbstractCNLPForm is derived from AbstractWaterFormulation"
abstract type AbstractCNLPForm <: AbstractWaterFormulation end

"StandardCNLPForm is derived from AbstractCNLPForm"
abstract type StandardCNLPForm <: AbstractCNLPForm end

"The CNLP model relaxes constraints into the objective."
const CNLPWaterModel = GenericWaterModel{StandardCNLPForm}

"CNLP constructor."
CNLPWaterModel(data::Dict{String, Any}; kwargs...) = GenericWaterModel(data, StandardCNLPForm; kwargs...)

function variable_head(wm::GenericWaterModel{T}, n::Int=wm.cnw; alpha::Float64=1.852) where T <: AbstractCNLPForm
end

function variable_flow(wm::GenericWaterModel{T}, n::Int=wm.cnw; alpha::Float64=1.852) where T <: AbstractCNLPForm
    variable_directed_flow(wm, n, alpha=alpha, bounded=false)
    variable_undirected_flow(wm, n, alpha=alpha, bounded=false)
end

function variable_flow_ne(wm::GenericWaterModel{T}, n::Int=wm.cnw; alpha::Float64=1.852) where T <: AbstractCNLPForm
end

function constraint_resistance_selection_ne(wm::GenericWaterModel{T}, a::Int, n::Int=wm.cnw) where T <: AbstractCNLPForm
end

function constraint_potential_loss(wm::GenericWaterModel{T}, a::Int, n::Int=wm.cnw; alpha::Float64=1.852) where T <: AbstractCNLPForm
end

function constraint_potential_loss_ne(wm::GenericWaterModel{T}, a::Int, n::Int=wm.cnw; alpha::Float64=1.852) where T <: AbstractCNLPForm
end

function constraint_flow_conservation(wm::GenericWaterModel{T}, i::Int, n::Int=wm.cnw) where T <: AbstractCNLPForm
    constraint_directed_flow_conservation(wm, i, n)
end

function constraint_flow_conservation_ne(wm::GenericWaterModel{T}, i::Int, n::Int=wm.cnw) where T <: AbstractCNLPForm
end

function constraint_link_flow_ne(wm::GenericWaterModel{T}, a::Int, n::Int=wm.cnw) where T <: AbstractCNLPForm
end

function constraint_link_flow(wm::GenericWaterModel{T}, a::Int, n::Int=wm.cnw; alpha::Float64=1.852) where T <: AbstractCNLPForm
    constraint_link_directed_flow(wm, a, n, alpha=alpha)
end

function constraint_source_flow(wm::GenericWaterModel{T}, i::Int, n::Int=wm.cnw) where T <: AbstractCNLPForm
end

function constraint_sink_flow(wm::GenericWaterModel{T}, i::Int, n::Int=wm.cnw) where T <: AbstractCNLPForm
end

function objective_wf(wm::GenericWaterModel{T}, n::Int = wm.cnw) where T <: StandardCNLPForm
    links = wm.ref[:nw][n][:links]
    linear_expr = JuMP.@expression(wm.model, 0.0)

    for (i, reservoir) in wm.ref[:nw][n][:reservoirs]
        for (a, link) in filter(a -> i == a.second["node1"], links)
            q⁻ = wm.var[:nw][n][:q⁻][a]
            q⁺ = wm.var[:nw][n][:q⁺][a]
            linear_expr -= reservoir["head"] * (q⁺ - q⁻)
        end

        for (a, link) in filter(a -> i == a.second["node2"], links)
            q⁻ = wm.var[:nw][n][:q⁻][a]
            q⁺ = wm.var[:nw][n][:q⁺][a]
            linear_expr -= reservoir["head"] * (q⁻ - q⁺)
        end
    end

    linear_term = JuMP.@variable(wm.model, base_name = "linear_cnlp_objective_term")
    JuMP.@constraint(wm.model, linear_expr == linear_term)

    # Initialize the objective.
    objective_expr = JuMP.@NLexpression(wm.model, linear_term +
        sum(link["length"] * wm.ref[:nw][n][:resistance][a][1] *
        (if_alpha(wm.var[:nw][n][:q⁻][a]) + if_alpha(wm.var[:nw][n][:q⁺][a]))
        for (a, link) in wm.ref[:nw][n][:links]))

    return JuMP.@NLobjective(wm.model, MOI.MIN_SENSE, objective_expr)
end
