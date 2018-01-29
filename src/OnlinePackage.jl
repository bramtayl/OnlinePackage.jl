module OnlinePackage

import HTTP
import JSON

abstract type Remote end

include("talk_to.jl")
include("github.jl")
include("travis.jl")
include("travis_token.jl")
include("appveyor.jl")
include("ssh_keygen.jl")
include("configure.jl")
include("generate.jl")

end
