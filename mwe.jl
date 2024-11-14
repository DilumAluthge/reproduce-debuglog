import Test

using Test: @testset, @test

const julia_binary = Base.julia_cmd()[1]

const env3 = copy(ENV)

env3["JULIA_DEBUG"] = "loading"
env3["JULIA_PKG_PRECOMPILE_AUTO"] = "0"

env3["JULIA_MAX_NUM_PRECOMPILE_FILES"] = "3"

projects = [
    "proj1-df1.1",
    "proj2-df1.2",
    "proj3-df1.3",
    "proj4-df1.4",
]

function my_read(cmd::Cmd, new_env::AbstractDict)
    new_cmd = setenv(cmd, new_env)

    run(new_cmd)

    iob_out = IOBuffer()
    iob_err = IOBuffer()
    # my_pipe = Pipe()
    # my_pipeline = pipeline(new_cmd; stdout=my_pipe, stderr=my_pipe)
    my_pipeline = pipeline(new_cmd; stdout=iob_out, stderr=iob_err)
    run(my_pipeline)
    # closewrite(my_pipe)
    # log_combined = read(my_pipe, String)
    log_out = String(take!(iob_out))
    log_err = String(take!(iob_err))
    log_combined = log_out * log_err
    res = (;
        log_out,
        log_err,
        log_combined,
    )
    return res
end

function run_project(proj_dir::AbstractString)
    @info "Beginning project: $(proj_dir)"
    proj_toml = joinpath(proj_dir, "Project.toml")
    manifest_toml = joinpath(proj_dir, "Manifest.toml")
    if !isfile(proj_toml)
        msg = "Project file not found at: $(proj_toml)"
        error(msg)
    end
    rm(manifest_toml; force = true)
    res1 = my_read(`$(julia_binary) --startup-file=no --project="$(proj_dir)" -e 'import Pkg; Pkg.instantiate()'`, env3)
    res3 = my_read(`$(julia_binary) --startup-file=no --project="$(proj_dir)" -e 'import DataFrames'`, env3)
    # res4 = my_read(`ls -la`, env3)
    # res5 = my_read(`ls -la`, env3)
    log1 = res1.log_combined
    log3 = res3.log_combined
    # log4 = res4.log_combined
    # log5 = res5.log_combined
    full_log = log1 * log3
    @info "Finished project: $(proj_dir)"
    return full_log
end

all_logs = run_project.(projects)

big_giant_log = reduce(*, all_logs)

@testset "mwe.jl" begin
    @test occursin("Debug: Evicting file from cache", big_giant_log)
end
