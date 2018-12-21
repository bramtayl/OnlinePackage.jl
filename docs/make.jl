using Documenter: makedocs, deploydocs
import OnlinePackage

makedocs(
    modules = [OnlinePackage],
    sitename = "OnlinePackage.jl",
    strict = true
)

deploydocs(
    repo = "github.com/bramtayl/OnlinePackage.jl.git",
)
