<<<<<<< HEAD
import Documenter

Documenter.deploydocs(
    repo = "github.com/bramtayl/OnlinePackage.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
    julia = "0.6"
=======
using Documenter, OnlinePackage

makedocs(;
    modules=[OnlinePackage],
    format=:html,
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/bramtayl/OnlinePackage.jl/blob/{commit}{path}#L{line}",
    sitename="OnlinePackage.jl",
    authors="Brandon Taylor",
    assets=[],
)

deploydocs(;
    repo="github.com/bramtayl/OnlinePackage.jl",
    target="build",
    julia="0.6",
    deps=nothing,
    make=nothing,
>>>>>>> lost
)
