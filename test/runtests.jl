using Documenter: makedocs, deploydocs
import OnlinePackage

makedocs(
    sitename = "OnlinePackage.jl",
    strict = true
)

deploydocs(
    repo = "github.com/bramtayl/OnlinePackage.jl.git",
)
