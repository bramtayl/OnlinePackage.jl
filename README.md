# OnlinePackage

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://bramtayl.github.io/OnlinePackage.jl/stable)
[![Build Status](https://travis-ci.org/bramtayl/OnlinePackage.jl.svg?branch=master)](https://travis-ci.org/bramtayl/OnlinePackage.jl)
[![CodeCov](https://codecov.io/gh/bramtayl/OnlinePackage.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/bramtayl/OnlinePackage.jl)

# Basic Usage

```julia
using OnlinePackage

# only do once
set_up(GITHUB_USERNAME, GITHUB_TOKEN)

copy("ModelPackage", "NewPackage")
put_online("NewPackage.jl")
```
