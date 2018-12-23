using Documenter: makedocs, deploydocs
import OnlinePackage

makedocs(
    modules = [OnlinePackage],
    sitename = "OnlinePackage.jl",
    root = joinpath(dirname(@__DIR__), "docs"),
    strict = true
)

deploydocs(
    repo = "github.com/bramtayl/OnlinePackage.jl.git",
)
