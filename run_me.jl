const depot = joinpath(@__DIR__, "depot")

const julia_binary = Base.julia_cmd()[1]

const env2 = copy(ENV);

delete!(env2, "JULIA_PROJECT");
env2["JULIA_LOAD_PATH"] = "@:@stdlib"
env2["JULIA_DEPOT_PATH"] = depot

cmd = `$(julia_binary) --startup-file=no mwe.jl`
run(setenv(cmd, env2))
