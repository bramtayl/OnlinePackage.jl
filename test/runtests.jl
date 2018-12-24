using Documenter: makedocs, deploydocs
import OnlinePackage

root = joinpath(dirname(@__DIR__), "docs"),

makedocs(
    modules = [OnlinePackage],
    sitename = "OnlinePackage.jl",
    root = root,
    strict = true
)

deploydocs(
    root = root,
    repo = "github.com/bramtayl/OnlinePackage.jl.git",
)
