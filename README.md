# OnlinePackage

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://bramtayl.github.io/OnlinePackage.jl/stable)
[![Build Status](https://travis-ci.org/bramtayl/OnlinePackage.jl.svg?branch=master)](https://travis-ci.org/bramtayl/OnlinePackage.jl)
[![CodeCov](https://codecov.io/gh/bramtayl/OnlinePackage.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/bramtayl/OnlinePackage.jl)

Puts your package on GitHub, Travis, and AppVeyor, and connects GitHub and Travis with SSH keys.

## Basic usage

```julia
set_up(username, github_token, appveyor_token)
generate(repo_name)
```

See documentation [here](https://bramtayl.github.io/OnlinePackage.jl/stable) for more information
