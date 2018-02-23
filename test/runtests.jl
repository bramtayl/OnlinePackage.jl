<<<<<<< HEAD
using OnlinePackage

import Documenter
Documenter.makedocs(
    modules = [OnlinePackage],
    format = :html,
    sitename = "OnlinePackage.jl",
    root = joinpath(dirname(dirname(@__FILE__)), "docs"),
    pages = Any["Home" => "index.md"],
    strict = true,
    linkcheck = true,
    checkdocs = :exports,
    authors = "Brandon Taylor"
)

using Base.Test

# write your own tests here
@test 1 == 2
=======

>>>>>>> lost
