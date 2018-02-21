######################################:ne_connection####################################################################
# The purpose of this file is to define commonly used and created constraints used in water flow models
##########################################################################################################

" Constraint that states a flow direction must be chosen "
function constraint_flow_direction_choice{T}(wm::GenericWaterModel{T}, i)
    yp = wm.var[:yp][i]
    yn = wm.var[:yn][i]

    c = @constraint(wm.model, yp + yn == 1)

    if !haskey(wm.constraint, :flow_direction_choice)
        wm.constraint[:flow_direction_choice] = Dict{Int,ConstraintRef}()
    end
    wm.constraint[:flow_direction_choice][i] = c
end



" constraints on head drop across pipes "
function constraint_on_off_head_drop{T}(wm::GenericWaterModel{T}, pipe_idx)

    pipe = wm.ref[:connection][pipe_idx]
    i_junction_idx = pipe["f_junction"]
    j_junction_idx = pipe["t_junction"]

    yp = wm.var[:yp][pipe_idx]
    yn = wm.var[:yn][pipe_idx]

    hi = wm.var[:h][i_junction_idx]
    hj = wm.var[:h][j_junction_idx]

    hd_min = pipe["hd_min"]
    hd_max = pipe["hd_max"]

    c1 = @constraint(wm.model, (1-yp) * hd_min <= hi - hj)
    c2 = @constraint(wm.model, hi - hj <= (1-yn)* hd_max)

    if !haskey(wm.constraint, :on_off_head_drop1)
        wm.constraint[:on_off_head_drop1] = Dict{Int,ConstraintRef}()
        wm.constraint[:on_off_head_drop2] = Dict{Int,ConstraintRef}()
    end
    wm.constraint[:on_off_head_drop1][pipe_idx] = c1
    wm.constraint[:on_off_head_drop2][pipe_idx] = c2
end

" constraints on head due to elevation "
function constraint_elevation_bound_regular{T}(wm::GenericWaterModel{T}, i)
    junction = wm.ref[:junction][i]

    h = wm.var[:h][i]


    c = @constraint(wm.model, h >= junction["head"] )

    if !haskey(wm.constraint, :elevation_bound_reg)
        wm.constraint[:elevation_bound_reg] = Dict{Int,ConstraintRef}()
    end
    wm.constraint[:elevation_bound_reg][i] = c
end

" constraints on head due to elevation "
function constraint_elevation_bound_source{T}(wm::GenericWaterModel{T}, i)
    junction = wm.ref[:junction][i]

    h = wm.var[:h][i]

    c = @constraint(wm.model, h == junction["head"] )

    if !haskey(wm.constraint, :elevation_bound_src)
        wm.constraint[:elevation_bound_src] = Dict{Int,ConstraintRef}()
    end
    wm.constraint[:elevation_bound_src][i] = c
end


" constraints on flow across pipes "
function constraint_on_off_pipe_flow_direction{T}(wm::GenericWaterModel{T}, pipe_idx)
    pipe = wm.ref[:connection][pipe_idx]

    i_junction_idx = pipe["f_junction"]
    j_junction_idx = pipe["t_junction"]

    yp = wm.var[:yp][pipe_idx]
    yn = wm.var[:yn][pipe_idx]
    f  = wm.var[:f][pipe_idx]

    max_flow = wm.ref[:max_flow]
    hd_max = pipe["hd_max"]
    hd_min = pipe["hd_min"]
    w = pipe["resistance"]

    c1 = @constraint(wm.model, -(1-yp)*min(max_flow, sqrt(w*max(hd_max, abs(hd_min)))) <= f)
    c2 = @constraint(wm.model, f <= (1-yn)*min(max_flow, sqrt(w*max(hd_max, abs(hd_min)))))

    if !haskey(wm.constraint, :on_off_pipe_flow_direction1)
        wm.constraint[:on_off_pipe_flow_direction1] = Dict{Int,ConstraintRef}()
        wm.constraint[:on_off_pipe_flow_direction2] = Dict{Int,ConstraintRef}()
    end
    wm.constraint[:on_off_pipe_flow_direction1][pipe_idx] = c1
    wm.constraint[:on_off_pipe_flow_direction2][pipe_idx] = c2
end

" constraints on flow across pipes due to pipe diameter"
function constraint_on_off_pipe_flow_direction_diameter{T}(wm::GenericWaterModel{T}, pipe_idx)
    pipe = wm.ref[:connection][pipe_idx]

    i_junction_idx = pipe["f_junction"]
    j_junction_idx = pipe["t_junction"]
    D = pipe["diameter"]

    yp = wm.var[:yp][pipe_idx]
    yn = wm.var[:yn][pipe_idx]
    f  = wm.var[:f][pipe_idx]

    max_flow = (pi/4)*(D^2)
    hd_max = pipe["hd_max"]
    hd_min = pipe["hd_min"]


    c1 = @constraint(wm.model, -(1-yp)*max_flow <= f)
    c2 = @constraint(wm.model, f <= (1-yn)*max_flow)

    if !haskey(wm.constraint, :on_off_pipe_flow_direction1)
        wm.constraint[:on_off_pipe_flow_direction_diameter1] = Dict{Int,ConstraintRef}()
        wm.constraint[:on_off_pipe_flow_direction_diameter2] = Dict{Int,ConstraintRef}()
    end
    wm.constraint[:on_off_pipe_flow_direction_diameter1][pipe_idx] = c1
    wm.constraint[:on_off_pipe_flow_direction_diameter2][pipe_idx] = c2
end

" standard flow balance equation where demand is fixed "
function constraint_junction_flow_balance{T}(wm::GenericWaterModel{T}, i)
    junction = wm.ref[:junction][i]
    junction_branches = wm.ref[:junction_connections][i]

    f_branches = collect(keys(filter( (a, connection) -> connection["f_junction"] == i, wm.ref[:connection])))
    t_branches = collect(keys(filter( (a, connection) -> connection["t_junction"] == i, wm.ref[:connection])))

    h = wm.var[:h]
    f = wm.var[:f]

    c = @constraint(wm.model, junction["demand"] == sum(f[a] for a in t_branches) - sum(f[a] for a in f_branches) )

    if !haskey(wm.constraint, :junction_flow_balance)
        wm.constraint[:junction_flow_balance] = Dict{Int,ConstraintRef}()
    end
    wm.constraint[:junction_flow_balance][i] = c
end


" Make sure there is at least one direction set to take flow away from a junction (typically used on source nodes) "
function constraint_source_flow{T}(wm::GenericWaterModel{T}, i)
    f_branches = collect(keys(filter( (a,connection) -> connection["f_junction"] == i, wm.ref[:connection])))
    t_branches = collect(keys(filter( (a,connection) -> connection["t_junction"] == i, wm.ref[:connection])))

    yp = wm.var[:yp]
    yn = wm.var[:yn]

    if length(t_branches)!=0 && length(f_branches)!=0
      c = @constraint(wm.model, sum(yp[a] for a in f_branches) + sum(yn[a] for a in t_branches) >= 1)
    end

    if length(t_branches)==0 && length(f_branches)!=0
      c = @constraint(wm.model, sum(yp[a] for a in f_branches)  >= 1)
    end

    if length(t_branches)!=0 && length(f_branches)==0
      c = @constraint(wm.model, sum(yn[a] for a in t_branches) >= 1)
    end


    if !haskey(wm.constraint, :source_flow)
        wm.constraint[:source_flow] = Dict{Int,ConstraintRef}()
    end
    wm.constraint[:source_flow][i] = c
end


" Make sure there is at least one direction set to take flow to a junction (typically used on sink nodes) "
function constraint_sink_flow{T}(wm::GenericWaterModel{T}, i)
    f_branches = collect(keys(filter( (a,connection) -> connection["f_junction"] == i, wm.ref[:connection])))
    t_branches = collect(keys(filter( (a,connection) -> connection["t_junction"] == i, wm.ref[:connection])))

    yp = wm.var[:yp]
    yn = wm.var[:yn]

    c = @constraint(wm.model, sum(yn[a] for a in f_branches) + sum(yp[a] for a in t_branches) >= 1)
    if !haskey(wm.constraint, :sink_flow)
        wm.constraint[:sink_flow] = Dict{Int,ConstraintRef}()
    end
    wm.constraint[:sink_flow][i] = c
end


" This constraint is intended to ensure that flow is on direction through a node with degree 2 and no production or consumption "
function constraint_conserve_flow{T}(wm::GenericWaterModel{T}, idx)
    first = nothing
    last = nothing

    for i in wm.ref[:junction_connections][idx]
        connection = wm.ref[:connection][i]
        if connection["f_junction"] == idx
            other = connection["t_junction"]
        else
            other = connection["f_junction"]
        end

        if first == nothing
            first = other
        elseif first != other
            if last != nothing && last != other
                error(string("Error: adding a degree 2 constraint to a node with degree > 2: Junction ", idx))
            end
            last = other
        end
    end

    yp_first = filter(i -> wm.ref[:connection][i]["f_junction"] == first, wm.ref[:junction_connections][idx])
    yn_first = filter(i -> wm.ref[:connection][i]["t_junction"] == first, wm.ref[:junction_connections][idx])
    yp_last  = filter(i -> wm.ref[:connection][i]["t_junction"] == last,  wm.ref[:junction_connections][idx])
    yn_last  = filter(i -> wm.ref[:connection][i]["f_junction"] == last,  wm.ref[:junction_connections][idx])

    yp = wm.var[:yp]
    yn = wm.var[:yn]

    c1 = nothing
    c2 = nothing
    c3 = nothing
    c4 = nothing
    if length(yn_first) > 0 && length(yp_last) > 0
        for i1 in yn_first
            for i2 in yp_last
                c1 = @constraint(wm.model, yn[i1]  == yp[i2])
                c2 = @constraint(wm.model, yp[i1]  == yn[i2])
                c3 = @constraint(wm.model, yn[i1] + yn[i2] == 1)
                c4 = @constraint(wm.model, yp[i1] + yp[i2] == 1)
            end
        end
    end


   if length(yn_first) > 0 && length(yn_last) > 0
        for i1 in yn_first
            for i2 in yn_last
                c1 = @constraint(wm.model, yn[i1] == yn[i2])
                c2 = @constraint(wm.model, yp[i1] == yp[i2])
                c3 = @constraint(wm.model, yn[i1] + yp[i2] == 1)
                c4 = @constraint(wm.model, yp[i1] + yn[i2] == 1)
            end
        end
    end

    if length(yp_first) > 0 && length(yp_last) > 0
        for i1 in yp_first
            for i2 in yp_last
                c1 = @constraint(wm.model, yp[i1]  == yp[i2])
                c2 = @constraint(wm.model, yn[i1]  == yn[i2])
                c3 = @constraint(wm.model, yp[i1] + yn[i2] == 1)
                c4 = @constraint(wm.model, yn[i1] + yp[i2] == 1)
            end
        end
    end

    if length(yp_first) > 0 && length(yn_last) > 0
        for i1 in yp_first
            for i2 in yn_last
                c1 = @constraint(wm.model, yp[i1] == yn[i2])
                c2 = @constraint(wm.model, yn[i1] == yp[i2])
                c3 = @constraint(wm.model, yp[i1] + yp[i2] == 1)
                c4 = @constraint(wm.model, yn[i1] + yn[i2] == 1)
            end
        end
    end

    if !haskey(wm.constraint, :conserve_flow1)
        wm.constraint[:conserve_flow1] = Dict{Int,ConstraintRef}()
        wm.constraint[:conserve_flow2] = Dict{Int,ConstraintRef}()
        wm.constraint[:conserve_flow3] = Dict{Int,ConstraintRef}()
        wm.constraint[:conserve_flow4] = Dict{Int,ConstraintRef}()
    end

    wm.constraint[:conserve_flow1][idx] = c1
    wm.constraint[:conserve_flow2][idx] = c2
    wm.constraint[:conserve_flow3][idx] = c3
    wm.constraint[:conserve_flow4][idx] = c4
end


" ensures that parallel lines have flow in the same direction "
function constraint_parallel_flow{T}(wm::GenericWaterModel{T}, idx)
    connection = wm.ref[:connection][idx]
    i = min(connection["f_junction"], connection["t_junction"])
    j = max(connection["f_junction"], connection["t_junction"])

    f_connections = filter(i -> wm.ref[:connection][i]["f_junction"] == connection["f_junction"], wm.ref[:parallel_connections][(i,j)])
    t_connections = filter(i -> wm.ref[:connection][i]["f_junction"] != connection["f_junction"], wm.ref[:parallel_connections][(i,j)])

    yp = wm.var[:yp]
    yn = wm.var[:yn]

    if length(wm.ref[:parallel_connections][(i,j)]) <= 1
        return nothing
    end

    c = @constraint(wm.model, sum(yp[i] for i in f_connections) + sum(yn[i] for i in t_connections) == yp[idx] * length(wm.ref[:parallel_connections][(i,j)]))
    if !haskey(wm.constraint, :parallel_flow)
        wm.constraint[:parallel_flow] = Dict{Int,ConstraintRef}()
    end
    wm.constraint[:parallel_flow][idx] = c
end