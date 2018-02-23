module OnlinePackage

<<<<<<< HEAD
"""
    test_function()

Return 1

```jldoctest
julia> import OnlinePackage

julia> OnlinePackage.test_function()
2
```
"""
test_function() = 1
=======
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
>>>>>>> lost

end
