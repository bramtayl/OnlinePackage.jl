module OnlinePackage

import HTTP
import JSON
import JSON: json

abstract type Remote end
const user_agent = "OnlinePackage/0.0.1"

include("talk_to.jl")
include("github.jl")
include("travis.jl")
include("travis_token.jl")
include("appveyor.jl")
include("ssh_keygen.jl")
include("configure.jl")
include("generate.jl")

end
