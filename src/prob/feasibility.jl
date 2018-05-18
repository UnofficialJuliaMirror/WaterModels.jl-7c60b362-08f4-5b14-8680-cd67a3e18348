export run_feasibility

function run_feasibility(file, model_constructor, solver; kwargs...)
    return run_generic_model(file, model_constructor, solver, post_feasibility; kwargs...)
end

function post_feasibility(wm::GenericWaterModel)
    variable_flow(wm)
    variable_flow_direction(wm)
    variable_head(wm)

    for id in keys(wm.ref[:nw][0][:junctions])
        constraint_flow_conservation(wm, id)
    end

    writeLP(wm.model, "test.lp", genericnames = false)
end
