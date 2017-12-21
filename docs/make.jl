import Documenter

Documenter.deploydocs(
    repo = "github.com/bramtayl/OnlinePackage.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
    julia = "0.6"
)
