using OnlinePackage
using Documenter: deploydocs, makedocs

makedocs(sitename = "OnlinePackage.jl", modules = [OnlinePackage], doctest = false)
deploydocs(repo = "github.com/bramtayl/OnlinePackage.jl.git")
