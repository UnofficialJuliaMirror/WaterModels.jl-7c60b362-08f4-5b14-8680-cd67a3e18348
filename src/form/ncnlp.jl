# Define NCNLP (non-convex nonlinear programming) implementations of water distribution models.

function variable_head(wm::GenericWaterModel{T}, n::Int=wm.cnw) where T <: AbstractNCNLPForm
    variable_pressure_head(wm, n)
    variable_head_gain(wm, n)
end

function variable_flow(wm::GenericWaterModel{T}, n::Int=wm.cnw) where T <: AbstractNCNLPForm
    variable_undirected_flow(wm, n, bounded=true)
end

function variable_flow_ne(wm::GenericWaterModel{T}, n::Int=wm.cnw) where T <: AbstractNCNLPForm
    variable_undirected_flow_ne(wm, n, bounded=true)
end

function variable_pump(wm::GenericWaterModel{T}, n::Int=wm.cnw) where T <: AbstractNCNLPForm
    variable_fixed_speed_pump_operation(wm, n)
end

function constraint_potential_loss_ub_pipe_ne(wm::GenericWaterModel{T}, n::Int, a::Int) where T <: AbstractNCNLPForm
end

function constraint_potential_loss_pipe_ne(wm::GenericWaterModel{T}, a::Int, n::Int=wm.cnw) where T <: AbstractNCNLPForm
    if !haskey(con(wm, n), :potential_loss_ne)
        con(wm, n)[:potential_loss_ne] = Dict{Int, JuMP.ConstraintRef}()
    end

    i = ref(wm, n, :pipes, a)["f_id"]
    h_i = var(wm, n, :h, i)

    j = ref(wm, n, :pipes, a)["t_id"]
    h_j = var(wm, n, :h, j)

    L = ref(wm, n, :pipes, a)["length"]
    q_ne = var(wm, n, :q_ne, a)
    resistances = ref(wm, n, :resistance, a)

    c = JuMP.@NLconstraint(wm.model, sum(r * f_alpha(q_ne[r_id]) for (r_id, r)
                           in enumerate(resistances)) - inv(L) * (h_i - h_j) == 0.0)

    con(wm, n, :potential_loss_ne)[a] = c
end


function constraint_head_difference(wm::GenericWaterModel{T}, n::Int, a::Int) where T <: AbstractNCNLPForm
end

function constraint_potential_loss_ub_pipe(wm::GenericWaterModel{T}, n::Int, a::Int) where T <: AbstractNCNLPForm
end

function constraint_potential_loss_check_valve(wm::GenericWaterModel{T}, n::Int, a::Int, f_id::Int, t_id::Int, len, r_min) where T <: AbstractNCNLPForm
    L = len
    r = r_min

    h_i = var(wm, n, :h, f_id)
    h_j = var(wm, n, :h, t_id)
    q = var(wm, n, :q, a)
    x_cv = var(wm, n, :x_cv, a)

    ## TODO: Possible formulation below (expand out...)?
    #c = JuMP.@NLconstraint(wm.model, x_cv * r * f_alpha(q) - inv(L) * x_cv * (h_i - h_j) == 0.0)
    #con(wm, n, :potential_loss)[a] = c

    q_ub = max(abs(JuMP.upper_bound(q)), abs(JuMP.lower_bound(q)))
    JuMP.@NLconstraint(wm.model, x_cv >= inv(q_ub) * abs(q))
    #JuMP.@NLconstraint(wm.model, x_cv <= q_ub * q^2)

    M = 1.0e9
    m = 1.0e-9

    c_1 = JuMP.@NLconstraint(wm.model, r * f_alpha(q) - inv(L) * (h_i - h_j) <= M * x_cv)
    c_2 = JuMP.@NLconstraint(wm.model, r * f_alpha(q) - inv(L) * (h_i - h_j) >= -M * x_cv)
end

function constraint_potential_loss_pipe(wm::GenericWaterModel{T}, n::Int, a::Int) where T <: AbstractNCNLPForm
    if !haskey(con(wm, n), :potential_loss)
        con(wm, n)[:potential_loss] = Dict{Int, JuMP.ConstraintRef}()
    end

    i = ref(wm, n, :pipes, a)["f_id"]
    h_i = var(wm, n, :h, i)

    j = ref(wm, n, :pipes, a)["t_id"]
    h_j = var(wm, n, :h, j)

    L = ref(wm, n, :pipes, a)["length"]
    r = minimum(ref(wm, n, :resistance, a))
    q = var(wm, n, :q, a)

    c = JuMP.@NLconstraint(wm.model, r * f_alpha(q) - inv(L) * (h_i - h_j) == 0.0)

    con(wm, n, :potential_loss)[a] = c
end

function constraint_potential_loss_pump(wm::GenericWaterModel{T}, n::Int, a::Int, f_id::Int, t_id::Int) where T <: AbstractNCNLPForm
    if !haskey(con(wm, n), :potential_loss_1)
        con(wm, n)[:potential_loss_1] = Dict{Int, JuMP.ConstraintRef}()
        con(wm, n)[:potential_loss_2] = Dict{Int, JuMP.ConstraintRef}()
        con(wm, n)[:potential_loss_3] = Dict{Int, JuMP.ConstraintRef}()
        con(wm, n)[:potential_loss_4] = Dict{Int, JuMP.ConstraintRef}()
        con(wm, n)[:potential_loss_5] = Dict{Int, JuMP.ConstraintRef}()
        con(wm, n)[:potential_loss_6] = Dict{Int, JuMP.ConstraintRef}()
    end

    h_i = var(wm, n, :h, f_id)
    h_j = var(wm, n, :h, t_id)

    q = var(wm, n, :q, a)
    g = var(wm, n, :g, a)
    x_pump = var(wm, n, :x_pump, a)

    # TODO: Big- and little-M values below need to be improved.
    M = 1.0e6
    m = 1.0e-6

    c_1 = JuMP.@constraint(wm.model, -(h_i - h_j) - g <= M * x_pump)
    c_2 = JuMP.@constraint(wm.model, -(h_i - h_j) - g >= -M * x_pump)
    con(wm, n, :potential_loss_1)[a] = c_1
    con(wm, n, :potential_loss_2)[a] = c_2

    # TODO: These can probably be stronger.
    c_3 = JuMP.@NLconstraint(wm.model, q*q <= M^2 * x_pump)
    c_4 = JuMP.@NLconstraint(wm.model, q*q >= m^2 * x_pump)
    con(wm, n, :potential_loss_3)[a] = c_3
    con(wm, n, :potential_loss_4)[a] = c_4

    #con(wm, n, :potential_loss_5)[a] = JuMP.@constraint(wm.model, q <= JuMP.upper_bound(q) * x_pump)
    #con(wm, n, :potential_loss_6)[a] = JuMP.@NLconstraint(wm.model, (1 - x_pump) * h_i <= (1 - x_pump) * h_j)
end

function get_function_from_pump_curve(pump_curve::Array{Tuple{Float64,Float64}})
    LsqFit.@. func(x, p) = p[1]*x*x + p[2]*x + p[3]
    fit = LsqFit.curve_fit(func, first.(pump_curve), last.(pump_curve), [0.0, 0.0, 0.0])
    return LsqFit.coef(fit)
end

function constraint_head_gain_pump_quadratic_fit(wm::GenericWaterModel{T}, n::Int, a::Int, A, B, C) where T <: AbstractNCNLPForm
    q = var(wm, n, :q, a)
    g = var(wm, n, :g, a)

    c = JuMP.@NLconstraint(wm.model, A * q^2 + B * q + C == g)
    con(wm, n, :head_gain)[a] = c
end

function objective_wf(wm::GenericWaterModel{T}, n::Int=wm.cnw) where T <: StandardNCNLPForm
    JuMP.set_objective_sense(wm.model, MOI.FEASIBILITY_SENSE)
end

function objective_owf(wm::GenericWaterModel{T}) where T <: StandardNCNLPForm
    expr = JuMP.AffExpr(0.0)

    for (n, nw_ref) in nws(wm)
        pump_ids = ids(wm, n, :pumps)
        costs = JuMP.@variable(wm.model, [a in pump_ids], base_name="costs[$(n)]",
                               start=get_start(ref(wm, n, :pumps), a, "costs", 0.0))

        efficiency = 0.85 # TODO: Change this after discussion. 0.85 follows Fooladivanda.
        rho = 1000.0 # Water density.
        g = 9.80665 # Gravitational acceleration.

        time_step = nw_ref[:options]["time"]["hydraulic_timestep"]
        constant = rho * g * time_step * inv(efficiency)

        for (a, pump) in nw_ref[:pumps]
            if haskey(pump, "energy_price")
                g = var(wm, n)[:g][a]
                q = var(wm, n)[:q][a]

                energy_price = pump["energy_price"]
                pump_cost = JuMP.@NLexpression(wm.model, constant * energy_price * g * abs(q))
                con = JuMP.@NLconstraint(wm.model, pump_cost == costs[a])
            else
                Memento.error(_LOGGER, "No cost given for pump \"$(pump["name"])\"")
            end
        end

        expr += sum(costs)
    end

    return JuMP.@objective(wm.model, MOI.MIN_SENSE, expr)
end
