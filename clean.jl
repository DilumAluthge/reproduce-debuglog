const depot = joinpath(@__DIR__, "depot")

rm(depot; force = true, recursive = true)

for (root, _, files) in walkdir(".")
    r = r"^(?:Julia)?Manifest(?:\-v\d*?\.\d*?)?\.toml$"
    for file in files
        path = joinpath(root, file)
        is_manifest_file = occursin(r, strip(file))
        if file == "Manifest.toml"
            @info "Deleting manifest: $(path)"
            rm(path; force = true)
        end
    end
end
